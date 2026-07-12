//
//  MemberCollectionViewCell.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/04/23.
//  Copyright © 2021 홍희표. All rights reserved.
//
//  소모임 멤버 셀 — 코드 기반 UI
//

import UIKit

class MemberCollectionViewCell: UICollectionViewCell {
    let profileImageView = UIImageView()

    let nameLabel = UILabel()

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
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 24
        profileImageView.backgroundColor = .systemGray5
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 12)
        nameLabel.textAlignment = .center
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            profileImageView.heightAnchor.constraint(equalToConstant: 48),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    func bind(_ memberItem: MemberItem) {
        setupViews()
        nameLabel.text = memberItem.name
        profileImageView.loadImage(EndPoint.USER_IMAGE.replacingOccurrences(of: "{UID}", with: memberItem.uid ?? ""), placeholder: UIImage(named: "knu_minigroup"))
    }
}
