//
//  ReplyRepository.swift
//  knu_minigroup
//
//  Android의 data.ReplyRepository 대응
//

import Foundation

class ReplyRepository {
    private let replyRemoteDataSource: ReplyRemoteDataSource

    init(articleKey: String) {
        self.replyRemoteDataSource = ReplyRemoteDataSource(articleKey: articleKey)
    }

    func getReplyList(callback: @escaping Callback<[(key: String, value: ReplyItem)]>) {
        replyRemoteDataSource.getReplyList(callback: callback)
    }

    func addReply(user: User, text: String, callback: @escaping Callback<Bool>) {
        replyRemoteDataSource.addReply(user: user, text: text, callback: callback)
    }

    func setReply(replyKey: String, text: String, callback: @escaping Callback<String>) {
        replyRemoteDataSource.setReply(replyKey: replyKey, text: text, callback: callback)
    }

    func removeReply(replyKey: String, callback: @escaping Callback<Bool>) {
        replyRemoteDataSource.removeReply(replyKey: replyKey, callback: callback)
    }
}
