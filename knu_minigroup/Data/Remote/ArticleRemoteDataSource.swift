//
//  ArticleRemoteDataSource.swift
//  knu_minigroup
//
//  Android의 data.remote.ArticleRemoteDataSource 대응 (Firebase + LMS 이미지 업로드)
//

import Foundation
import FirebaseDatabase

class ArticleRemoteDataSource {
    private let groupId: String

    private let groupKey: String

    private var lastKey: String? = nil // 마지막으로 가져온 데이터의 키

    private(set) var isStopRequestMore = false

    init(groupId: String, groupKey: String) {
        self.groupId = groupId
        self.groupKey = groupKey
    }

    func setLastKey(_ lastKey: String?) {
        self.lastKey = lastKey
    }

    func getArticleList(cookie: String?, limit: Int, callback: @escaping Callback<[(key: String, value: ArticleItem)]>) {
        let databaseReference = Database.database().reference(withPath: "Articles")
        var query: DatabaseQuery = databaseReference.child(groupKey).queryOrderedByKey().queryLimited(toLast: UInt(limit))

        if let lastKey = lastKey {
            query = query.queryEnding(beforeValue: lastKey)
        }
        callback(.loading)
        query.observeSingleEvent(of: .value, with: { [weak self] dataSnapshot in
            var newLastKey: String? = nil
            var articleItemList = [(key: String, value: ArticleItem)]()

            for case let snapshot as DataSnapshot in dataSnapshot.children {
                if articleItemList.isEmpty {
                    newLastKey = snapshot.key // 마지막 키 저장
                }
                if let value = ArticleItem(dictionary: snapshot.value as? [String: Any]) {
                    articleItemList.insert((snapshot.key, value), at: 0)
                }
            }
            if newLastKey == nil {
                self?.isStopRequestMore = true
            }
            self?.lastKey = newLastKey // 다음 페이지 요청을 위해 키 업데이트
            callback(.success(articleItemList))
        }, withCancel: { error in
            callback(.failure(error))
        })
    }

    func getArticleData(articleKey: String, callback: @escaping Callback<ArticleItem>) {
        let databaseReference = Database.database().reference(withPath: "Articles")

        callback(.loading)
        databaseReference.child(groupKey).child(articleKey).observeSingleEvent(of: .value, with: { dataSnapshot in
            if let value = ArticleItem(dictionary: dataSnapshot.value as? [String: Any]) {
                callback(.success(value))
            }
        }, withCancel: { error in
            callback(.failure(error))
        })
    }

    func addArticle(user: User, title: String, content: String?, imageList: [String], youTubeItem: YouTubeItem?, callback: @escaping Callback<String?>) {
        let databaseReference = Database.database().reference(withPath: "Articles")
        let article = databaseReference.child(groupKey).childByAutoId()
        var map = [String: Any]()

        map["uid"] = user.uid
        map["name"] = user.name
        map["title"] = title
        map["timestamp"] = Int64(Date().timeIntervalSince1970 * 1000)
        map["content"] = (content?.isEmpty ?? true) ? nil : content
        map["images"] = imageList
        map["youtube"] = youTubeItem?.dictionary
        article.setValue(map)
        callback(.success(article.key))
    }

    func setArticle(articleKey: String, title: String, content: String?, imageList: [String], youTubeItem: YouTubeItem?, callback: @escaping Callback<ArticleItem?>) {
        let databaseReference = Database.database().reference(withPath: "Articles")
        let query = databaseReference.child(groupKey).child(articleKey)

        query.observeSingleEvent(of: .value, with: { dataSnapshot in
            if var articleItem = ArticleItem(dictionary: dataSnapshot.value as? [String: Any]) {
                articleItem.title = title
                articleItem.content = (content?.isEmpty ?? true) ? nil : content
                articleItem.images = imageList
                articleItem.youtube = youTubeItem
                query.setValue(articleItem.dictionary)
                callback(.success(articleItem))
            } else {
                callback(.success(nil))
            }
        }, withCancel: { error in
            callback(.failure(error))
        })
    }

    func removeArticle(articleKey: String, callback: @escaping Callback<Bool>) {
        let articlesReference = Database.database().reference(withPath: "Articles")
        let replysReference = Database.database().reference(withPath: "Replys")

        callback(.loading)
        articlesReference.child(groupKey).child(articleKey).removeValue()
        replysReference.child(articleKey).removeValue()
        callback(.success(true))
    }

    // LMS 이미지 업로드 (서버 폐쇄 — Android와 동일하게 요청은 시도하며 실패시 onFailure)
    func addArticleImage(cookie: String?, imageData: Data, callback: @escaping Callback<String>) {
        guard let url = URL(string: EndPoint.IMAGE_UPLOAD) else {
            callback(.failure(AppError(message: "잘못된 URL")))
            return
        }
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        var body = Data()

        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let cookie = cookie {
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(Int64(Date().timeIntervalSince1970 * 1000)).jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    callback(.failure(error))
                    return
                }
                guard let data = data, let responseText = String(data: data, encoding: .utf8),
                      let startRange = responseText.range(of: "/ilosfiles2/"),
                      let endRange = responseText.range(of: "\"", range: startRange.upperBound..<responseText.endIndex) else {
                    callback(.failure(AppError(message: "이미지 업로드에 실패했습니다.")))
                    return
                }
                let imageSrc = EndPoint.BASE_URL + responseText[startRange.lowerBound..<endRange.lowerBound]

                callback(.success(String(imageSrc)))
            }
        }.resume()
    }
}
