//
//  ReplyCollectionViewCell.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/06/01.
//  Copyright © 2021 홍희표. All rights reserved.
//
//  댓글 셀 — 코드 기반 UI
//

import UIKit

class ReplyCollectionViewCell: UICollectionViewCell {
    let avatarImageView = UIImageView()

    let nameLabel = UILabel()

    let replyLabel = UILabel()

    let dateLabel = UILabel()

    private var isConfigured = false

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }

    // Android reply_item.xml: 패딩 8, 아바타 45, 이름 bold 15, 날짜 12 #888888 우하단
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
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .boldSystemFont(ofSize: 15)
        replyLabel.translatesAutoresizingMaskIntoConstraints = false
        replyLabel.font = .systemFont(ofSize: 14)
        replyLabel.numberOfLines = 0
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .replyTimestamp
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(replyLabel)
        contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            avatarImageView.widthAnchor.constraint(equalToConstant: 45),
            avatarImageView.heightAnchor.constraint(equalToConstant: 45),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            replyLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            replyLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            replyLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: replyLabel.bottomAnchor, constant: 2),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func bind(_ replyItem: ReplyItem) {
        setupViews()
        nameLabel.text = replyItem.name
        replyLabel.text = replyItem.reply
        dateLabel.text = replyItem.date
        avatarImageView.loadImage(EndPoint.USER_IMAGE.replacingOccurrences(of: "{UID}", with: replyItem.uid ?? ""), placeholder: UIImage(named: "user_image_view_circle"))
    }
}
