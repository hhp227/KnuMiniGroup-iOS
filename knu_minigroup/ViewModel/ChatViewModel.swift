//
//  ChatViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.ChatViewModel 대응 — 그룹 채팅/1:1 채팅
//

import Foundation
import Combine

class ChatViewModel {
    private static let LIMIT = 20

    @Published private(set) var isLoading = false

    @Published private(set) var messageItemList = [(key: String, value: MessageItem)]()

    @Published private(set) var message: String?

    let receiver: String

    let isGroupChat: Bool

    private var cursor: String?

    private let chatRepository = ChatRepository()

    private let preferenceManager = PreferenceManager.shared

    var user: User? {
        return preferenceManager.user
    }

    init(receiver: String, isGroupChat: Bool) {
        self.receiver = receiver
        self.isGroupChat = isGroupChat
    }

    func fetchMessageList() {
        guard let uid = user?.uid else {
            return
        }
        let previousCursor = cursor

        chatRepository.fetchMessageList(currentUserUid: uid, receiver: receiver, isGroupChat: isGroupChat, cursor: previousCursor, limit: ChatViewModel.LIMIT) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .loading:
                self.isLoading = true
            case .success(let messageItemList):
                var newList = messageItemList

                self.isLoading = false
                if previousCursor != nil && !newList.isEmpty {
                    newList.removeLast() // 커서와 중복되는 마지막 메시지 제거
                }
                self.cursor = newList.first?.key
                self.messageItemList = newList + self.messageItemList
            case .failure(let error):
                self.isLoading = false
                self.message = error.localizedDescription
            }
        }
    }

    func sendMessage(text: String) {
        guard let user = user else {
            return
        }
        let trimmedMessage = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedMessage.isEmpty else {
            return
        }
        chatRepository.sendMessage(user: user, receiver: receiver, isGroupChat: isGroupChat, text: trimmedMessage)
    }
}
