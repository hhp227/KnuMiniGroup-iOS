//
//  YouTubeItem.swift
//  knu_minigroup
//
//  Android의 dto.YouTubeItem 대응
//

import Foundation

struct YouTubeItem {
    var position: Int = 0

    var videoId: String?

    var publishedAt: String?

    var title: String?

    var thumbnail: String?

    var channelTitle: String?

    init(videoId: String?, publishedAt: String?, title: String?, thumbnail: String?, channelTitle: String?) {
        self.videoId = videoId
        self.publishedAt = publishedAt
        self.title = title
        self.thumbnail = thumbnail
        self.channelTitle = channelTitle
    }

    init?(dictionary: [String: Any]?) {
        guard let dictionary = dictionary else {
            return nil
        }
        self.position = dictionary["position"] as? Int ?? 0
        self.videoId = dictionary["videoId"] as? String
        self.publishedAt = dictionary["publishedAt"] as? String
        self.title = dictionary["title"] as? String
        self.thumbnail = dictionary["thumbnail"] as? String
        self.channelTitle = dictionary["channelTitle"] as? String
    }

    var dictionary: [String: Any] {
        var map = [String: Any]()

        map["position"] = position
        map["videoId"] = videoId
        map["publishedAt"] = publishedAt
        map["title"] = title
        map["thumbnail"] = thumbnail
        map["channelTitle"] = channelTitle
        return map
    }
}
