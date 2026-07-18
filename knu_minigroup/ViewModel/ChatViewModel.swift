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

    private(set) var hasRequestMore = true

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

    deinit {
        chatRepository.removeMessageObserver()
    }

    func fetchMessageList() {
        guard let uid = user?.uid, !isLoading, hasRequestMore else {
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
                // 페이지가 꽉 차지 않으면 더 이전 메시지 없음
                if messageItemList.count < ChatViewModel.LIMIT {
                    self.hasRequestMore = false
                }
                if previousCursor != nil && !newList.isEmpty {
                    newList.removeLast() // 커서와 중복되는 마지막 메시지 제거
                }
                if let firstKey = newList.first?.key {
                    self.cursor = firstKey
                }
                self.messageItemList = newList + self.messageItemList
                // 최초 로드 후 마지막 메시지 이후를 실시간 구독 (Android ChildEventListener 대응)
                if previousCursor == nil {
                    self.observeNewMessages()
                }
            case .failure(let error):
                self.isLoading = false
                self.message = error.localizedDescription
            }
        }
    }

    private func observeNewMessages() {
        guard let uid = user?.uid else {
            return
        }
        chatRepository.observeNewMessages(currentUserUid: uid, receiver: receiver, isGroupChat: isGroupChat, afterKey: messageItemList.last?.key) { [weak self] key, messageItem in
            guard let self = self, self.messageItemList.last?.key != key else {
                return
            }
            self.messageItemList.append((key, messageItem))
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
