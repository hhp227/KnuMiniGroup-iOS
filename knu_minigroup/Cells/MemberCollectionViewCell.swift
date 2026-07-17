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

        // Android member_item: 셀 폭 정사각 사진(#EEEEEE) + 이름 9pt 중앙
        contentView.subviews.forEach { $0.removeFromSuperview() }
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .profileBg
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 9)
        nameLabel.textAlignment = .center
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            profileImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    func bind(_ memberItem: MemberItem) {
        setupViews()
        nameLabel.text = memberItem.name
        profileImageView.loadImage(EndPoint.USER_IMAGE.replacingOccurrences(of: "{UID}", with: memberItem.uid ?? ""), placeholder: UIImage(named: "profile_img_square"))
    }
}
