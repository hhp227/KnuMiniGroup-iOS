//
//  MainCollectionReusableView.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/23.
//  Copyright © 2020 홍희표. All rights reserved.
//
//  메인 그리드 섹션 헤더 — 코드 기반 UI (Android group_grid_header)
//

import UIKit

class MainCollectionReusableView: UICollectionReusableView {
    let headerLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        // Android group_grid_header: 높이 35, bold 16, colorPrimary, marginStart 15
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = .boldSystemFont(ofSize: 16)
        headerLabel.textColor = .colorPrimary
        addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}
