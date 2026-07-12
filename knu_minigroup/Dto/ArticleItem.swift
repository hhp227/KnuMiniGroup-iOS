//
//  ArticleItem.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/04/15.
//  Copyright © 2021 홍희표. All rights reserved.
//
//  Android의 dto.ArticleItem 대응 (images는 URL 문자열 리스트)
//

import Foundation

struct ArticleItem {
    var auth: Bool = false

    var timestamp: Int64 = 0

    var id: String?

    var uid: String?

    var name: String?

    var title: String?

    var content: String?

    var replyCount: String?

    var images: [String] = []

    var youtube: YouTubeItem?

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
        self.title = dictionary["title"] as? String
        self.content = dictionary["content"] as? String
        self.replyCount = dictionary["replyCount"] as? String
        self.images = dictionary["images"] as? [String] ?? []
        self.youtube = YouTubeItem(dictionary: dictionary["youtube"] as? [String: Any])
        self.auth = dictionary["auth"] as? Bool ?? false
        self.timestamp = dictionary["timestamp"] as? Int64 ?? Int64(dictionary["timestamp"] as? Int ?? 0)
    }

    var dictionary: [String: Any] {
        var map = [String: Any]()

        map["id"] = id
        map["uid"] = uid
        map["name"] = name
        map["title"] = title
        map["content"] = content
        map["images"] = images.isEmpty ? nil : images
        map["youtube"] = youtube?.dictionary
        map["timestamp"] = timestamp
        return map
    }
}
