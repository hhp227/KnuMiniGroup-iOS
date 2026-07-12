//
//  ReplyRemoteDataSource.swift
//  knu_minigroup
//
//  Android의 data.remote.ReplyRemoteDataSource 대응 (Firebase)
//

import Foundation
import FirebaseDatabase

class ReplyRemoteDataSource {
    private let articleKey: String

    init(articleKey: String) {
        self.articleKey = articleKey
    }

    func getReplyList(callback: @escaping Callback<[(key: String, value: ReplyItem)]>) {
        let databaseReference = Database.database().reference(withPath: "Replys")

        databaseReference.child(articleKey).observeSingleEvent(of: .value, with: { dataSnapshot in
            var replyItemList = [(key: String, value: ReplyItem)]()

            for case let snapshot as DataSnapshot in dataSnapshot.children {
                if let value = ReplyItem(dictionary: snapshot.value as? [String: Any]) {
                    replyItemList.append((snapshot.key, value))
                }
            }
            callback(.success(replyItemList))
        }, withCancel: { error in
            callback(.failure(error))
        })
    }

    func addReply(user: User, text: String, callback: @escaping Callback<Bool>) {
        let databaseReference = Database.database().reference(withPath: "Replys")
        var replyItem = ReplyItem()

        callback(.loading)
        replyItem.uid = user.uid
        replyItem.name = user.name
        replyItem.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        replyItem.reply = text
        databaseReference.child(articleKey).childByAutoId().setValue(replyItem.dictionary)
        callback(.success(true))
    }

    func setReply(replyKey: String, text: String, callback: @escaping Callback<String>) {
        let databaseReference = Database.database().reference(withPath: "Replys")
        let query = databaseReference.child(articleKey).child(replyKey)

        query.observeSingleEvent(of: .value, with: { dataSnapshot in
            if var replyItem = ReplyItem(dictionary: dataSnapshot.value as? [String: Any]) {
                replyItem.reply = text + "\n"

                query.setValue(replyItem.dictionary)
            }
            callback(.success(text))
        }, withCancel: { error in
            callback(.failure(error))
        })
        callback(.loading)
    }

    func removeReply(replyKey: String, callback: @escaping Callback<Bool>) {
        let databaseReference = Database.database().reference(withPath: "Replys")

        callback(.loading)
        databaseReference.child(articleKey).child(replyKey).removeValue()
        callback(.success(true))
    }
}
