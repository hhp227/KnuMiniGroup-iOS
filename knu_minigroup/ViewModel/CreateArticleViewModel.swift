//
//  CreateArticleViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.CreateArticleViewModel 대응 — 게시글 작성/수정
//

import Foundation
import Combine

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

    func actionSend(title: String, content: String) {
        guard let user = user else {
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
        isLoading = true
        if let articleKey = articleKey {
            articleRepository.setArticle(articleKey: articleKey, title: title, content: content, imageList: [], youTubeItem: youTubeItem) { [weak self] result in
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
            articleRepository.addArticle(user: user, title: title, content: content, imageList: [], youTubeItem: youTubeItem) { [weak self] result in
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
