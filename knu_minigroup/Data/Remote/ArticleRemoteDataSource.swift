//
//  ArticleRemoteDataSource.swift
//  knu_minigroup
//
//  Android의 data.remote.ArticleRemoteDataSource 대응 (Firebase Database + Storage)
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

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
        if lastKey == nil {
            isStopRequestMore = false // 새로고침 시 페이징 재개
        }
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
                // 덮어쓰기 전에 기존 목록을 떠둔다. 수정 화면에서 빠진 이미지는 이 차집합으로만 알 수 있다.
                let oldImageList = articleItem.images

                articleItem.title = title
                articleItem.content = (content?.isEmpty ?? true) ? nil : content
                articleItem.images = imageList
                articleItem.youtube = youTubeItem
                query.setValue(articleItem.dictionary) { error, _ in
                    // 수정이 실제로 반영된 뒤에 지워야 실패 시 파일만 날아가는 일이 없다.
                    if error == nil {
                        StorageCleaner.deleteRemoved(oldUrls: oldImageList, newUrls: imageList)
                    }
                }
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
        let articleReference = articlesReference.child(groupKey).child(articleKey)
        let removeArticleData = {
            articleReference.removeValue()
            replysReference.child(articleKey).removeValue()
            callback(.success(true))
        }

        callback(.loading)

        // 글을 지우고 나면 이미지 목록을 알 수 없으므로 먼저 읽어둔다.
        articleReference.observeSingleEvent(of: .value, with: { dataSnapshot in
            let articleItem = ArticleItem(dictionary: dataSnapshot.value as? [String: Any])

            removeArticleData()
            StorageCleaner.delete(articleItem?.images)
        }, withCancel: { _ in
            // 이미지 목록을 못 읽어도 글 삭제 자체는 진행한다.
            removeArticleData()
        })
    }

    /// LMS 서버가 닫혀 이미지 업로드 엔드포인트를 쓸 수 없으므로 Firebase Storage에 올리고 다운로드 URL을 돌려준다.
    /// 상위 계층은 URL 문자열만 받으므로 기존 계약은 그대로다. (Android ArticleRemoteDataSource와 동일)
    /// - Parameter cookie: 로그인 시 저장해둔 Firebase uid
    func addArticleImage(cookie: String?, imageData: Data, callback: @escaping Callback<String>) {
        let storageReference = Storage.storage()
            .reference(withPath: "article_images")
            .child(Self.resolveUid(cookie))
            .child("\(Int64(Date().timeIntervalSince1970 * 1000)).jpg")

        callback(.loading)
        storageReference.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                callback(.failure(error))
                return
            }
            storageReference.downloadURL { url, error in
                DispatchQueue.main.async {
                    if let url = url {
                        callback(.success(url.absoluteString))
                    } else {
                        callback(.failure(error ?? AppError(message: "이미지 업로드에 실패했습니다.")))
                    }
                }
            }
        }
    }

    /// 저장 경로를 유저별로 나누기 위한 uid. 값이 없으면 현재 로그인 세션에서 채운다.
    static func resolveUid(_ cookie: String?) -> String {
        if let cookie = cookie, !cookie.isEmpty {
            return cookie
        }
        return Auth.auth().currentUser?.uid ?? "anonymous"
    }
}
