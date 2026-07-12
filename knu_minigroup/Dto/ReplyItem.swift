//
//  ReplyItem.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/05/25.
//  Copyright © 2021 홍희표. All rights reserved.
//
//  Android의 dto.ReplyItem 대응
//

import Foundation

struct ReplyItem {
    var auth: Bool = false

    var timestamp: Int64 = 0

    var id: String?

    var uid: String?

    var name: String?

    var reply: String?

    var date: String {
        return DateUtil.getPeriodTime(timestamp)
    }

    init() {
    }

    init?(dictionary: [String: Any]?) {
        guard let dictionary = dictionary else {
            return nil
        }
        self.id = dictionary["id"] as? String
        self.uid = dictionary["uid"] as? String
        self.name = dictionary["name"] as? String
        self.reply = dictionary["reply"] as? String
        self.auth = dictionary["auth"] as? Bool ?? false
        self.timestamp = dictionary["timestamp"] as? Int64 ?? Int64(dictionary["timestamp"] as? Int ?? 0)
    }

    var dictionary: [String: Any] {
        var map = [String: Any]()

        map["id"] = id
        map["uid"] = uid
        map["name"] = name
        map["reply"] = reply
        map["timestamp"] = timestamp
        return map
    }
}
