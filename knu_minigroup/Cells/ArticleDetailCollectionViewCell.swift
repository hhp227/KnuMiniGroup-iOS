//
//  ArticleDetailCollectionViewCell.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/05/31.
//  Copyright © 2021 홍희표. All rights reserved.
//
//  게시글 상세 헤더 셀 — Android article_detail.xml 대응 (코드 기반 동적 레이아웃)
//  본문 링크 클릭 가능, 첨부 이미지는 전부 세로로 나열
//

import UIKit

class ArticleDetailCollectionViewCell: UICollectionViewCell {
    var articleItem: ArticleItem?

    let avatarImageView = UIImageView()

    let dateLabel = UILabel()

    let titleLabel = UILabel()

    let contentTextView = UITextView()

    private var articleImageViews = [UIImageView]()

    private let separatorView = UIView()

    private var isConfigured = false

    // Android article_detail.xml: 마진 10 + 패딩 5 = 15, 아바타 45, 본문 위 10/아래 5, 이미지 위 10
    private static let horizontalInset: CGFloat = 15

    private static let contentFont = UIFont.systemFont(ofSize: 14)

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
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 22.5
        titleLabel.font = .boldSystemFont(ofSize: 15)
        titleLabel.numberOfLines = 1
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .textTimestamp
        // Android tv_content: autoLink="web" — 링크 클릭 가능한 UITextView 사용
        contentTextView.font = Self.contentFont
        contentTextView.isEditable = false
        contentTextView.isSelectable = true
        contentTextView.isScrollEnabled = false
        contentTextView.dataDetectorTypes = [.link]
        contentTextView.textContainerInset = .zero
        contentTextView.textContainer.lineFragmentPadding = 0
        contentTextView.backgroundColor = .clear
        // 게시글과 댓글 목록 사이 구분선 (Android ListView divider 대응)
        separatorView.backgroundColor = .systemGray4
        contentView.addSubview(avatarImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(contentTextView)
        contentView.addSubview(separatorView)
    }

    func bind(_ articleItem: ArticleItem) {
        setupViews()
        self.articleItem = articleItem

        titleLabel.text = (articleItem.title ?? "") + " - " + (articleItem.name ?? "")
        dateLabel.text = articleItem.date
        contentTextView.text = articleItem.content
        avatarImageView.loadImage(EndPoint.USER_IMAGE.replacingOccurrences(of: "{UID}", with: articleItem.uid ?? ""), placeholder: UIImage(named: "user_image_view_circle"))
        // Android ll_image(imageList 바인딩): 첨부 이미지 전부 세로 나열 — 이미지 뷰 재사용/증설
        while articleImageViews.count < articleItem.images.count {
            let imageView = UIImageView()

            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.backgroundColor = .systemGray5
            articleImageViews.append(imageView)
            contentView.addSubview(imageView)
        }
        for (index, imageView) in articleImageViews.enumerated() {
            imageView.isHidden = index >= articleItem.images.count
            if index < articleItem.images.count {
                imageView.loadImage(articleItem.images[index])
            }
        }
        setNeedsLayout()
    }

    // height(for:width:)와 동일한 수치로 프레임을 계산한다
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = contentView.bounds.width
        let textLeading = Self.horizontalInset + 45 + 10
        var y: CGFloat = 10

        avatarImageView.frame = CGRect(x: Self.horizontalInset, y: y, width: 45, height: 45)
        titleLabel.frame = CGRect(x: textLeading, y: y + 2, width: width - textLeading - Self.horizontalInset, height: 18)
        dateLabel.frame = CGRect(x: textLeading, y: y + 24, width: width - textLeading - Self.horizontalInset, height: 16)
        y += 45
        if let content = articleItem?.content, !content.isEmpty {
            let textHeight = Self.textHeight(content, width: width - Self.horizontalInset * 2)

            y += 10
            contentTextView.isHidden = false
            contentTextView.frame = CGRect(x: Self.horizontalInset, y: y, width: width - Self.horizontalInset * 2, height: textHeight)
            y += textHeight + 5
        } else {
            contentTextView.isHidden = true
        }
        for imageView in articleImageViews where !imageView.isHidden {
            y += 10
            imageView.frame = CGRect(x: Self.horizontalInset, y: y, width: width - Self.horizontalInset * 2, height: Self.imageHeight(width: width))
            y += Self.imageHeight(width: width)
        }
        separatorView.frame = CGRect(x: 0, y: contentView.bounds.height - 0.5, width: width, height: 0.5)
    }

    // 셀 전체 높이 — layoutSubviews와 동일 수식 유지
    static func height(for item: ArticleItem, width: CGFloat) -> CGFloat {
        var height: CGFloat = 10 + 45

        if let content = item.content, !content.isEmpty {
            height += 10 + textHeight(content, width: width - horizontalInset * 2) + 5
        }
        height += CGFloat(item.images.count) * (10 + imageHeight(width: width))
        return height + 12
    }

    private static func textHeight(_ text: String, width: CGFloat) -> CGFloat {
        return ceil((text as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: contentFont], context: nil).height)
    }

    // Android는 원본 비율(adjustViewBounds) — 로드 전 높이를 알 수 없어 16:9 고정 (피드 카드와 동일 방침)
    private static func imageHeight(width: CGFloat) -> CGFloat {
        return floor((width - horizontalInset * 2) * 9 / 16)
    }
}
