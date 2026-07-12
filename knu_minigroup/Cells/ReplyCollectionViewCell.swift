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
    let nameLabel = UILabel()

    let replyLabel = UILabel()

    let dateLabel = UILabel()

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
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .boldSystemFont(ofSize: 14)
        replyLabel.translatesAutoresizingMaskIntoConstraints = false
        replyLabel.font = .systemFont(ofSize: 14)
        replyLabel.numberOfLines = 0
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel
        contentView.addSubview(nameLabel)
        contentView.addSubview(replyLabel)
        contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            replyLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            replyLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            replyLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: replyLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func bind(_ replyItem: ReplyItem) {
        setupViews()
        nameLabel.text = replyItem.name
        replyLabel.text = replyItem.reply
        dateLabel.text = replyItem.date
    }
}
