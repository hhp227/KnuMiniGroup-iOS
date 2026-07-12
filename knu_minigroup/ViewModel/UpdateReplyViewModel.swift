//
//  UpdateReplyViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.UpdateReplyViewModel 대응 — 댓글 수정
//

import Foundation
import Combine

class UpdateReplyViewModel {
    @Published private(set) var isLoading = false

    @Published private(set) var updatedReply: String?

    @Published private(set) var message: String?

    let articleKey: String

    let replyKey: String

    private let replyRepository: ReplyRepository

    init(articleKey: String, replyKey: String) {
        self.articleKey = articleKey
        self.replyKey = replyKey
        self.replyRepository = ReplyRepository(articleKey: articleKey)
    }

    func setReply(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            message = "내용을 입력하세요."
            return
        }
        replyRepository.setReply(replyKey: replyKey, text: trimmed) { [weak self] result in
            switch result {
            case .loading:
                self?.isLoading = true
            case .success(let reply):
                self?.isLoading = false
                self?.updatedReply = reply
            case .failure(let error):
                self?.isLoading = false
                self?.message = error.localizedDescription
            }
        }
    }
}
