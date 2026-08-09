//
//  CreateArticleViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.CreateArticleViewModel 대응 — 게시글 작성/수정
//

import Foundation
import Combine
import UIKit

class CreateArticleViewModel {
    @Published private(set) var isLoading = false

    @Published private(set) var isDone = false

    @Published private(set) var message: String?

    let groupId: String

    let groupKey: String

    // 수정 모드일 경우에만 값이 있음
    var articleKey: String?

    var youTubeItem: YouTubeItem?

    private let articleRepository: ArticleRepository

    private let preferenceManager = PreferenceManager.shared

    var user: User? {
        return preferenceManager.user
    }

    init(groupId: String, groupKey: String, articleKey: String? = nil) {
        self.groupId = groupId
        self.groupKey = groupKey
        self.articleKey = articleKey
        self.articleRepository = ArticleRepository(groupId: groupId, key: groupKey)
    }

    /// - Parameter contents: 작성 화면의 항목들. 첨부된 이미지는 순서대로 업로드한 뒤 URL 목록으로 넘긴다.
    func actionSend(title: String, content: String, contents: [WriteItem] = []) {
        guard user != nil else {
            return
        }
        guard !title.isEmpty else {
            message = "제목을 입력하세요."
            return
        }
        guard !content.isEmpty || youTubeItem != nil else {
            message = "내용을 입력하세요."
            return
        }
        let images = contents.compactMap { item -> UIImage? in
            if case let .ImageItem(image) = item {
                return image
            }
            return nil
        }

        isLoading = true
        uploadImages(images, uploaded: []) { [weak self] imageList in
            self?.submit(title: title, content: content, imageList: imageList)
        }
    }

    /// Android의 uploadProcess처럼 한 장씩 순서대로 올린다. 순서를 지켜야 본문의 이미지 순서가 유지된다.
    private func uploadImages(_ images: [UIImage], uploaded: [String], completion: @escaping ([String]) -> Void) {
        guard let image = images.first else {
            completion(uploaded)
            return
        }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            uploadImages(Array(images.dropFirst()), uploaded: uploaded, completion: completion)
            return
        }
        articleRepository.addArticleImage(cookie: preferenceManager.user?.uid, imageData: imageData) { [weak self] result in
            switch result {
            case .loading:
                break
            case .success(let imageUrl):
                self?.uploadImages(Array(images.dropFirst()), uploaded: uploaded + [imageUrl], completion: completion)
            case .failure(let error):
                self?.isLoading = false
                self?.message = error.localizedDescription
            }
        }
    }

    private func submit(title: String, content: String, imageList: [String]) {
        guard let user = user else {
            return
        }
        if let articleKey = articleKey {
            articleRepository.setArticle(articleKey: articleKey, title: title, content: content, imageList: imageList, youTubeItem: youTubeItem) { [weak self] result in
                switch result {
                case .loading:
                    break
                case .success:
                    self?.isLoading = false
                    self?.isDone = true
                case .failure(let error):
                    self?.isLoading = false
                    self?.message = error.localizedDescription
                }
            }
        } else {
            articleRepository.addArticle(user: user, title: title, content: content, imageList: imageList, youTubeItem: youTubeItem) { [weak self] result in
                switch result {
                case .loading:
                    break
                case .success:
                    self?.isLoading = false
                    self?.isDone = true
                case .failure(let error):
                    self?.isLoading = false
                    self?.message = error.localizedDescription
                }
            }
        }
    }
}
