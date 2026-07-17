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

        // Android group_grid_item: 이미지 폭×100 fitXY + 타이틀 15pt #4C4C4C 패딩 10
        contentView.subviews.forEach { $0.removeFromSuperview() }
        groupImageView.translatesAutoresizingMaskIntoConstraints = false
        groupImageView.contentMode = .scaleToFill
        groupImageView.clipsToBounds = true
        groupImageView.backgroundColor = .profileBg
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 15)
        nameLabel.textColor = .gridTitle
        nameLabel.textAlignment = .left
        nameLabel.numberOfLines = 1
        contentView.addSubview(groupImageView)
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            groupImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            groupImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            groupImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            groupImageView.heightAnchor.constraint(equalToConstant: 100),
            nameLabel.topAnchor.constraint(equalTo: groupImageView.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }

    func bind(_ groupItem: GroupItem) {
        setupViews()
        nameLabel.text = groupItem.name
        groupImageView.loadImage(groupItem.image, placeholder: UIImage(named: "knu_minigroup"))
    }
}
