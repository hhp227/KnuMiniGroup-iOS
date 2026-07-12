//
//  ArticleRepository.swift
//  knu_minigroup
//
//  Android의 data.ArticleRepository 대응 — RemoteDataSource로 위임하는 얇은 계층
//

import Foundation

class ArticleRepository {
    private let articleRemoteDataSource: ArticleRemoteDataSource

    init(groupId: String, key: String) {
        self.articleRemoteDataSource = ArticleRemoteDataSource(groupId: groupId, groupKey: key)
    }

    var isStopRequestMore: Bool {
        return articleRemoteDataSource.isStopRequestMore
    }

    func setLastKey(_ lastKey: String?) {
        articleRemoteDataSource.setLastKey(lastKey)
    }

    func getArticleList(cookie: String?, limit: Int, callback: @escaping Callback<[(key: String, value: ArticleItem)]>) {
        articleRemoteDataSource.getArticleList(cookie: cookie, limit: limit, callback: callback)
    }

    func getArticleData(articleKey: String, callback: @escaping Callback<ArticleItem>) {
        articleRemoteDataSource.getArticleData(articleKey: articleKey, callback: callback)
    }

    func addArticle(user: User, title: String, content: String?, imageList: [String], youTubeItem: YouTubeItem?, callback: @escaping Callback<String?>) {
        articleRemoteDataSource.addArticle(user: user, title: title, content: content, imageList: imageList, youTubeItem: youTubeItem, callback: callback)
    }

    func setArticle(articleKey: String, title: String, content: String?, imageList: [String], youTubeItem: YouTubeItem?, callback: @escaping Callback<ArticleItem?>) {
        articleRemoteDataSource.setArticle(articleKey: articleKey, title: title, content: content, imageList: imageList, youTubeItem: youTubeItem, callback: callback)
    }

    func removeArticle(articleKey: String, callback: @escaping Callback<Bool>) {
        articleRemoteDataSource.removeArticle(articleKey: articleKey, callback: callback)
    }

    func addArticleImage(cookie: String?, imageData: Data, callback: @escaping Callback<String>) {
        articleRemoteDataSource.addArticleImage(cookie: cookie, imageData: imageData, callback: callback)
    }
}
