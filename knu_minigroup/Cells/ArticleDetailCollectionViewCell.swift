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

    let nameLabel = UILabel()

    let dateLabel = UILabel()

    let titleLabel = UILabel()

    let contentLabel = UILabel()

    let articleImageView = UIImageView()

    private var isConfigured = false

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }

    private func setupViews() {
        guard !isConfigured else {
            return
        }
        isConfigured = true

        contentView.subviews.forEach { $0.removeFromSuperview() }
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 14)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.font = .systemFont(ofSize: 15)
        contentLabel.numberOfLines = 0
        articleImageView.translatesAutoresizingMaskIntoConstraints = false
        articleImageView.contentMode = .scaleAspectFit
        contentView.addSubview(titleLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(articleImageView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            contentLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            articleImageView.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 10),
            articleImageView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            articleImageView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            articleImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func bind(_ articleItem: ArticleItem) {
        setupViews()
        self.articleItem = articleItem

        titleLabel.text = articleItem.title
        nameLabel.text = articleItem.name
        dateLabel.text = articleItem.date
        contentLabel.text = articleItem.content
        if let imageUrl = articleItem.images.first {
            articleImageView.loadImage(imageUrl)
        } else {
            articleImageView.image = nil
        }
    }
}
