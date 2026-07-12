//
//  MainCollectionViewCell.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/23.
//  Copyright © 2020 홍희표. All rights reserved.
//
//  가입중인 소모임 그리드 셀 — 코드 기반 UI
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
    let groupImageView = UIImageView()

    let nameLabel = UILabel()

    private var isConfigured = false

    override func layoutSubviews() {
        super.layoutSubviews()
        cardView()
    }

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
        groupImageView.translatesAutoresizingMaskIntoConstraints = false
        groupImageView.contentMode = .scaleAspectFill
        groupImageView.clipsToBounds = true
        groupImageView.backgroundColor = .systemGray5
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 14)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 1
        contentView.addSubview(groupImageView)
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            groupImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            groupImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            groupImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.topAnchor.constraint(equalTo: groupImageView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            nameLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    func bind(_ groupItem: GroupItem) {
        setupViews()
        nameLabel.text = groupItem.name
        groupImageView.loadImage(groupItem.image, placeholder: UIImage(named: "knu_minigroup"))
    }
}
