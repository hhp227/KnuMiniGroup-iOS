//
//  GroupItem.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/04/15.
//  Copyright © 2021 홍희표. All rights reserved.
//
//  Android의 dto.GroupItem 대응
//

import Foundation

struct GroupItem {
    var isAd: Bool = false

    var isAdmin: Bool = false

    var memberCount: Int = 0

    var timestamp: Int64 = 0

    var id: String?

    var author: String?

    var authorUid: String?

    var image: String?

    var name: String?

    var info: String?

    var groupDescription: String?

    var joinType: String?

    var members: [String: Bool]?

    init() {
    }

    init?(dictionary: [String: Any]?) {
        guard let dictionary = dictionary else {
            return nil
        }
        self.id = dictionary["id"] as? String
        self.author = dictionary["author"] as? String
        self.authorUid = dictionary["authorUid"] as? String
        self.image = dictionary["image"] as? String
        self.name = dictionary["name"] as? String
        self.info = dictionary["info"] as? String
        self.groupDescription = dictionary["description"] as? String
        self.joinType = dictionary["joinType"] as? String
        self.members = dictionary["members"] as? [String: Bool]
        self.memberCount = dictionary["memberCount"] as? Int ?? 0
        self.timestamp = dictionary["timestamp"] as? Int64 ?? Int64(dictionary["timestamp"] as? Int ?? 0)
        self.isAdmin = dictionary["admin"] as? Bool ?? false
    }

    var dictionary: [String: Any] {
        var map = [String: Any]()

        map["id"] = id
        map["author"] = author
        map["authorUid"] = authorUid
        map["image"] = image
        map["name"] = name
        map["info"] = info
        map["description"] = groupDescription
        map["joinType"] = joinType
        map["members"] = members
        map["memberCount"] = memberCount
        map["timestamp"] = timestamp
        return map
    }
}
