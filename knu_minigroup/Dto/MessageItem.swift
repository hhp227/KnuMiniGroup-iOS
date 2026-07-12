//
//  MessageItem.swift
//  knu_minigroup
//
//  Android의 dto.MessageItem 대응
//

import Foundation

struct MessageItem {
    var from: String?

    var name: String?

    var message: String?

    var type: String?

    var seen: Bool = false

    var timestamp: Int64 = 0

    init(from: String?, name: String?, message: String?, type: String?, seen: Bool, timestamp: Int64) {
        self.from = from
        self.name = name
        self.message = message
        self.type = type
        self.seen = seen
        self.timestamp = timestamp
    }

    init?(dictionary: [String: Any]?) {
        guard let dictionary = dictionary else {
            return nil
        }
        self.from = dictionary["from"] as? String
        self.name = dictionary["name"] as? String
        self.message = dictionary["message"] as? String
        self.type = dictionary["type"] as? String
        self.seen = dictionary["seen"] as? Bool ?? false
        self.timestamp = dictionary["timestamp"] as? Int64 ?? Int64(dictionary["timestamp"] as? Int ?? 0)
    }

    var dictionary: [String: Any] {
        var map = [String: Any]()

        map["from"] = from
        map["name"] = name
        map["message"] = message
        map["type"] = type
        map["seen"] = seen
        map["timestamp"] = timestamp
        return map
    }
}
