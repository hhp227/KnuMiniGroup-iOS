//
//  ReplyCollectionViewCell.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/06/01.
//  Copyright © 2021 홍희표. All rights reserved.
//
//  댓글 셀 — 코드 기반 UI. 본인 댓글은 왼쪽으로 스와이프하면 수정/삭제 버튼 노출
//

import UIKit

class ReplyCollectionViewCell: UICollectionViewCell {
    let avatarImageView = UIImageView()

    let nameLabel = UILabel()

    let replyLabel = UILabel()

    let dateLabel = UILabel()

    var onEditClick: (() -> Void)?

    var onDeleteClick: (() -> Void)?

    // 콘텐츠를 통째로 밀어 뒤의 액션 버튼을 드러내는 컨테이너
    private let swipeContainerView = UIView()

    private let editButton = UIButton(type: .system)

    private let deleteButton = UIButton(type: .system)

    // 댓글 사이 구분선 (Android ListView divider 대응)
    private let separatorView = UIView()

    private var isSwipeEnabled = false

    private var isSwipeOpen = false

    private static let actionButtonWidth: CGFloat = 60

    private var isConfigured = false

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setSwipeOpen(false, animated: false)
        onEditClick = nil
        onDeleteClick = nil
    }

    // Android reply_item.xml: 패딩 8, 아바타 45, 이름 bold 15, 날짜 12 #888888 우하단
    private func setupViews() {
        guard !isConfigured else {
            return
        }
        isConfigured = true

        contentView.subviews.forEach { $0.removeFromSuperview() }
        // 스와이프 시 드러나는 액션 버튼 (콘텐츠 뒤에 깔림)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        editButton.tintColor = .white
        editButton.backgroundColor = .colorAccent
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .white
        deleteButton.backgroundColor = .systemRed
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        swipeContainerView.translatesAutoresizingMaskIntoConstraints = false
        swipeContainerView.backgroundColor = .systemBackground
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
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .systemGray4
        contentView.addSubview(deleteButton)
        contentView.addSubview(editButton)
        contentView.addSubview(swipeContainerView)
        swipeContainerView.addSubview(avatarImageView)
        swipeContainerView.addSubview(nameLabel)
        swipeContainerView.addSubview(replyLabel)
        swipeContainerView.addSubview(dateLabel)
        swipeContainerView.addSubview(separatorView)
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: Self.actionButtonWidth),
            editButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            editButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            editButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor),
            editButton.widthAnchor.constraint(equalToConstant: Self.actionButtonWidth),
            swipeContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            swipeContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            swipeContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            swipeContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            avatarImageView.topAnchor.constraint(equalTo: swipeContainerView.topAnchor, constant: 8),
            avatarImageView.leadingAnchor.constraint(equalTo: swipeContainerView.leadingAnchor, constant: 8),
            avatarImageView.widthAnchor.constraint(equalToConstant: 45),
            avatarImageView.heightAnchor.constraint(equalToConstant: 45),
            nameLabel.topAnchor.constraint(equalTo: swipeContainerView.topAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: swipeContainerView.trailingAnchor, constant: -8),
            replyLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            replyLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            replyLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: replyLabel.bottomAnchor, constant: 2),
            dateLabel.trailingAnchor.constraint(equalTo: swipeContainerView.trailingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(lessThanOrEqualTo: swipeContainerView.bottomAnchor, constant: -8),
            separatorView.leadingAnchor.constraint(equalTo: swipeContainerView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: swipeContainerView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: swipeContainerView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_:)))
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(_:)))

        leftSwipeGesture.direction = .left
        rightSwipeGesture.direction = .right
        swipeContainerView.addGestureRecognizer(leftSwipeGesture)
        swipeContainerView.addGestureRecognizer(rightSwipeGesture)
    }

    func bind(_ replyItem: ReplyItem, isMine: Bool = false) {
        setupViews()
        isSwipeEnabled = isMine
        nameLabel.text = replyItem.name
        replyLabel.text = replyItem.reply
        dateLabel.text = replyItem.date
        avatarImageView.loadImage(EndPoint.USER_IMAGE.replacingOccurrences(of: "{UID}", with: replyItem.uid ?? ""), placeholder: UIImage(named: "user_image_view_circle"))
        setSwipeOpen(false, animated: false)
    }

    @objc private func swipeHandler(_ gesture: UISwipeGestureRecognizer) {
        guard isSwipeEnabled else {
            return
        }
        setSwipeOpen(gesture.direction == .left, animated: true)
    }

    private func setSwipeOpen(_ isOpen: Bool, animated: Bool) {
        isSwipeOpen = isOpen
        let transform = isOpen ? CGAffineTransform(translationX: -Self.actionButtonWidth * 2, y: 0) : .identity

        if animated {
            UIView.animate(withDuration: 0.25) {
                self.swipeContainerView.transform = transform
            }
        } else {
            swipeContainerView.transform = transform
        }
    }

    @objc private func editButtonTapped() {
        setSwipeOpen(false, animated: true)
        onEditClick?()
    }

    @objc private func deleteButtonTapped() {
        setSwipeOpen(false, animated: true)
        onDeleteClick?()
    }
}
