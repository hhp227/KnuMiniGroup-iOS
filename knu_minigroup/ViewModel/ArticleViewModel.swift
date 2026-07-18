//
//  ArticleViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.ArticleViewModel 대응 — 게시글 상세 + 댓글
//

import Foundation
import Combine

class ArticleViewModel {
    @Published private(set) var isLoading = false

    @Published private(set) var articleItem: ArticleItem?

    @Published private(set) var replyItemList = [(key: String, value: ReplyItem)]()

    @Published private(set) var isArticleRemoved = false

    @Published private(set) var message: String?

    let groupId: String

    let groupKey: String

    let articleKey: String

    private let articleRepository: ArticleRepository

    private let replyRepository: ReplyRepository

    private let preferenceManager = PreferenceManager.shared

    var user: User? {
        return preferenceManager.user
    }

    init(groupId: String, groupKey: String, articleKey: String) {
        self.groupId = groupId
        self.groupKey = groupKey
        self.articleKey = articleKey
        self.articleRepository = ArticleRepository(groupId: groupId, key: groupKey)
        self.replyRepository = ReplyRepository(articleKey: articleKey)
    }

    func fetchArticleData() {
        articleRepository.getArticleData(articleKey: articleKey) { [weak self] result in
            switch result {
            case .loading:
                self?.isLoading = true
            case .success(let articleItem):
                self?.isLoading = false
                self?.articleItem = articleItem
            case .failure(let error):
                self?.isLoading = false
                self?.message = error.localizedDescription
            }
        }
    }

    func fetchReplyList() {
        replyRepository.getReplyList { [weak self] result in
            switch result {
            case .loading:
                break
            case .success(let replyItemList):
                self?.replyItemList = replyItemList
            case .failure(let error):
                self?.message = error.localizedDescription
            }
        }
    }

    func addReply(text: String) {
        guard let user = user else {
            return
        }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            message = "내용을 입력하세요."
            return
        }
        replyRepository.addReply(user: user, text: trimmed) { [weak self] result in
            switch result {
            case .loading:
                break
            case .success:
                self?.fetchReplyList()
            case .failure(let error):
                self?.message = error.localizedDescription
            }
        }
    }

    func removeArticle() {
        articleRepository.removeArticle(articleKey: articleKey) { [weak self] result in
            switch result {
            case .loading:
                self?.isLoading = true
            case .success:
                self?.isLoading = false
                self?.isArticleRemoved = true
            case .failure(let error):
                self?.isLoading = false
                self?.message = error.localizedDescription
            }
        }
    }

    func removeReply(replyKey: String) {
        replyRepository.removeReply(replyKey: replyKey) { [weak self] result in
            switch result {
            case .loading:
                break
            case .success:
                self?.fetchReplyList()
            case .failure(let error):
                self?.message = error.localizedDescription
            }
        }
    }

    func refresh() {
        fetchArticleData()
        fetchReplyList()
    }
}
