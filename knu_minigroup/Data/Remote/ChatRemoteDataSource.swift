//
//  ChatRemoteDataSource.swift
//  knu_minigroup
//
//  Android의 data.remote.ChatRemoteDataSource 대응 (Firebase)
//

import Foundation
import FirebaseDatabase

class ChatRemoteDataSource {
    private let databaseReference = Database.database().reference(withPath: "Messages")

    func fetchMessageList(currentUserUid: String, receiver: String, isGroupChat: Bool, cursor: String?, limit: Int, callback: @escaping Callback<[(key: String, value: MessageItem)]>) {
        var query: DatabaseQuery = isGroupChat
            ? databaseReference.child(receiver).queryOrderedByKey().queryLimited(toLast: UInt(limit))
            : databaseReference.child(currentUserUid).child(receiver).queryOrderedByKey().queryLimited(toLast: UInt(limit))

        if let cursor = cursor {
            query = query.queryEnding(atValue: cursor)
        }
        callback(.loading)
        query.observeSingleEvent(of: .value, with: { dataSnapshot in
            var messageItemList = [(key: String, value: MessageItem)]()

            for case let snapshot as DataSnapshot in dataSnapshot.children {
                if let value = MessageItem(dictionary: snapshot.value as? [String: Any]) {
                    messageItemList.append((snapshot.key, value))
                }
            }
            callback(.success(messageItemList))
        }, withCancel: { error in
            callback(.failure(error))
        })
    }

    func sendMessage(user: User, receiver: String, isGroupChat: Bool, text: String) {
        var map = [String: Any]()

        map["from"] = user.uid
        map["name"] = user.name
        map["message"] = text
        map["type"] = "text"
        map["seen"] = false
        map["timestamp"] = Int64(Date().timeIntervalSince1970 * 1000)
        if isGroupChat {
            databaseReference.child(receiver).childByAutoId().setValue(map)
        } else {
            guard let uid = user.uid, let pushId = databaseReference.child(uid).child(receiver).childByAutoId().key else {
                return
            }
            let receiverPath = receiver + "/" + uid + "/"
            let senderPath = uid + "/" + receiver + "/"
            var messageMap = [String: Any]()

            messageMap[receiverPath + pushId] = map
            messageMap[senderPath + pushId] = map
            databaseReference.updateChildValues(messageMap)
        }
    }
}
