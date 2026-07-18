//
//  ChatRepository.swift
//  knu_minigroup
//
//  Android의 data.ChatRepository 대응
//

import Foundation

class ChatRepository {
    private let chatRemoteDataSource = ChatRemoteDataSource()

    func fetchMessageList(currentUserUid: String, receiver: String, isGroupChat: Bool, cursor: String?, limit: Int, callback: @escaping Callback<[(key: String, value: MessageItem)]>) {
        chatRemoteDataSource.fetchMessageList(currentUserUid: currentUserUid, receiver: receiver, isGroupChat: isGroupChat, cursor: cursor, limit: limit, callback: callback)
    }

    func observeNewMessages(currentUserUid: String, receiver: String, isGroupChat: Bool, afterKey: String?, onMessageAdded: @escaping (String, MessageItem) -> Void) {
        chatRemoteDataSource.observeNewMessages(currentUserUid: currentUserUid, receiver: receiver, isGroupChat: isGroupChat, afterKey: afterKey, onMessageAdded: onMessageAdded)
    }

    func removeMessageObserver() {
        chatRemoteDataSource.removeMessageObserver()
    }

    func sendMessage(user: User, receiver: String, isGroupChat: Bool, text: String) {
        chatRemoteDataSource.sendMessage(user: user, receiver: receiver, isGroupChat: isGroupChat, text: text)
    }
}
