//
//  Tab1ViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.Tab1ViewModel 대응 — 소모임 게시판 (페이징)
//

import Foundation
import Combine

class Tab1ViewModel {
    private static let LIMIT = 10

    @Published private(set) var isLoading = false

    @Published private(set) var articleItemList = [(key: String, value: ArticleItem)]()

    @Published private(set) var message: String?

    private(set) var hasRequestMore = true

    private let articleRepository: ArticleRepository

    private let preferenceManager = PreferenceManager.shared

    let groupId: String

    let groupKey: String

    var user: User? {
        return preferenceManager.user
    }

    init(groupId: String, groupKey: String) {
        self.groupId = groupId
        self.groupKey = groupKey
        self.articleRepository = ArticleRepository(groupId: groupId, key: groupKey)
    }

    func fetchNextPage() {
        guard hasRequestMore else {
            return
        }
        articleRepository.getArticleList(cookie: nil, limit: Tab1ViewModel.LIMIT) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .loading:
                self.isLoading = true
            case .success(let articleItemList):
                self.isLoading = false
                self.articleItemList += articleItemList
                self.hasRequestMore = !self.articleRepository.isStopRequestMore
            case .failure(let error):
                self.isLoading = false
                self.message = error.localizedDescription
            }
        }
    }

    func refresh() {
        hasRequestMore = true

        articleRepository.setLastKey(nil)
        articleItemList = []
        fetchNextPage()
    }
}
