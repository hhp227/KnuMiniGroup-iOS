//
//  GroupTableViewCell.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/04/15.
//  Copyright © 2021 홍희표. All rights reserved.
//
//  소모임 찾기/가입신청 목록 셀
//

import UIKit

class GroupTableViewCell: UITableViewCell {
    // Android group_list_item: 썸네일 150×100 fitXY 마진 2 + 이름 16(2줄) + 가입방식 13
    let thumbImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .profileBg
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 2
        return label
    }()

    let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    private var isConfigured = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }

    // nib 로드(Find)와 class 등록(Request) 양쪽에서 동작
    private func setupViews() {
        guard !isConfigured else {
            return
        }
        isConfigured = true

        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.addSubview(thumbImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(infoLabel)
        NSLayoutConstraint.activate([
            thumbImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            thumbImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            thumbImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            thumbImageView.widthAnchor.constraint(equalToConstant: 150),
            thumbImageView.heightAnchor.constraint(equalToConstant: 100),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: thumbImageView.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            infoLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }

    func bind(_ groupItem: GroupItem) {
        setupViews()
        nameLabel.text = groupItem.name
        infoLabel.text = groupItem.info ?? "가입방식: \(groupItem.joinType == "0" ? "자동 승인" : "운영자 승인 확인")"
        thumbImageView.loadImage(groupItem.image, placeholder: UIImage(named: "knu_minigroup"))
    }
}
