//
//  ArticleDetailCollectionViewCell.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/05/31.
//  Copyright © 2021 홍희표. All rights reserved.
//
//  게시글 상세 헤더 셀 — 코드 기반 UI
//

import UIKit

class ArticleDetailCollectionViewCell: UICollectionViewCell {
    var articleItem: ArticleItem?

    let avatarImageView = UIImageView()

    let dateLabel = UILabel()

    let titleLabel = UILabel()

    let contentLabel = UILabel()

    let articleImageView = UIImageView()

    private var isConfigured = false

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }

    // Android article_detail.xml: 아바타 45 + 타이틀 bold 15 + 타임스탬프 13 #A0A3A7
    private func setupViews() {
        guard !isConfigured else {
            return
        }
        isConfigured = true

        contentView.subviews.forEach { $0.removeFromSuperview() }
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 22.5
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 15)
        titleLabel.numberOfLines = 1
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .textTimestamp
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.numberOfLines = 0
        articleImageView.translatesAutoresizingMaskIntoConstraints = false
        articleImageView.contentMode = .scaleAspectFit
        contentView.addSubview(avatarImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(articleImageView)
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 45),
            avatarImageView.heightAnchor.constraint(equalToConstant: 45),
            titleLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            articleImageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10),
            articleImageView.leadingAnchor.constraint(equalTo: contentLabel.leadingAnchor),
            articleImageView.trailingAnchor.constraint(equalTo: contentLabel.trailingAnchor),
            articleImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func bind(_ articleItem: ArticleItem) {
        setupViews()
        self.articleItem = articleItem

        titleLabel.text = (articleItem.title ?? "") + " - " + (articleItem.name ?? "")
        dateLabel.text = articleItem.date
        contentLabel.text = articleItem.content
        avatarImageView.loadImage(EndPoint.USER_IMAGE.replacingOccurrences(of: "{UID}", with: articleItem.uid ?? ""), placeholder: UIImage(named: "user_image_view_circle"))
        if let imageUrl = articleItem.images.first {
            articleImageView.loadImage(imageUrl)
        } else {
            articleImageView.image = nil
        }
    }
}
