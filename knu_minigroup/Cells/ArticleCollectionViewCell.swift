//
//  ArticleTableViewCell.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/04/08.
//  Copyright © 2021 홍희표. All rights reserved.
//
//  소식 탭 게시글 카드 — Android article_item.xml 대응 (코드 기반 동적 레이아웃)
//

import UIKit

class ArticleCollectionViewCell: UICollectionViewCell {
    private let cardContainerView = UIView()

    private let avatarImageView = UIImageView()

    private let titleLabel = UILabel()

    private let dateLabel = UILabel()

    private let contentLabel = UILabel()

    private let moreLabel = UILabel()

    private let articleImageView = UIImageView()

    private let dividerView = UIView()

    private let shareLabel = UILabel()

    private let replyLabel = UILabel()

    private let actionDividerView = UIView()

    private var articleItem: ArticleItem?

    // Android article_item 치수: 상하 패딩 20, 좌우 패딩 15, 아바타 45, 내용 최대 4줄
    private static let verticalPadding: CGFloat = 20

    private static let horizontalPadding: CGFloat = 15

    private static let avatarSize: CGFloat = 45

    private static let contentFont = UIFont.systemFont(ofSize: 14)

    private static let contentMaxLines = 4

    private static let actionBarHeight: CGFloat = 36

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
        // Android CardView(cornerRadius 4dp, elevation 3dp) 상당 — 카드는 콘텐츠 높이만큼만 그린다
        cardContainerView.backgroundColor = .systemBackground
        cardContainerView.layer.cornerRadius = 4
        cardContainerView.layer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.5)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.24
        layer.masksToBounds = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = Self.avatarSize / 2
        titleLabel.font = .boldSystemFont(ofSize: 15)
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .textTimestamp
        contentLabel.font = Self.contentFont
        contentLabel.numberOfLines = Self.contentMaxLines
        moreLabel.text = "     ...더보기"
        moreLabel.font = Self.contentFont
        moreLabel.textColor = .darkGray
        articleImageView.contentMode = .scaleAspectFill
        articleImageView.clipsToBounds = true
        articleImageView.backgroundColor = .systemGray3
        dividerView.backgroundColor = .systemGray4
        actionDividerView.backgroundColor = .systemGray4
        // Android ll_like/ll_reply: 하단 액션 바 — 터치는 셀 선택으로 흘려보낸다
        shareLabel.text = "공유하기"
        shareLabel.font = .systemFont(ofSize: 14)
        shareLabel.textAlignment = .center
        replyLabel.font = .systemFont(ofSize: 14)
        replyLabel.textAlignment = .center
        contentView.addSubview(cardContainerView)
        [avatarImageView, titleLabel, dateLabel, contentLabel, moreLabel, articleImageView, dividerView, shareLabel, replyLabel, actionDividerView].forEach {
            cardContainerView.addSubview($0)
        }
    }

    func bind(_ item: ArticleItem) {
        setupViews()
        articleItem = item
        titleLabel.text = item.name != nil ? (item.title ?? "") + " - " + (item.name ?? "") : item.title
        dateLabel.text = item.date
        contentLabel.text = item.content
        replyLabel.text = "댓글 \(item.replyCount ?? "0")"
        avatarImageView.loadImage(EndPoint.USER_IMAGE.replacingOccurrences(of: "{UID}", with: item.uid ?? ""), placeholder: UIImage(named: "user_image_view_circle"))
        if let imageUrl = item.images.first {
            articleImageView.isHidden = false
            articleImageView.loadImage(imageUrl)
        } else {
            articleImageView.isHidden = true
        }
        setNeedsLayout()
    }

    // sizeForItemAt(height(for:width:))과 동일한 수치로 프레임을 계산한다
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = contentView.bounds.width
        let textLeading = Self.horizontalPadding + Self.avatarSize + 10
        var y = Self.verticalPadding

        avatarImageView.frame = CGRect(x: Self.horizontalPadding, y: y, width: Self.avatarSize, height: Self.avatarSize)
        titleLabel.frame = CGRect(x: textLeading, y: y + 2, width: width - textLeading - Self.horizontalPadding, height: 18)
        dateLabel.frame = CGRect(x: textLeading, y: y + 22, width: width - textLeading - Self.horizontalPadding, height: 16)
        y += Self.avatarSize
        if let content = articleItem?.content, !content.isEmpty {
            let (textHeight, isTruncated) = Self.contentTextHeight(content, width: width - Self.horizontalPadding * 2)

            y += 10
            contentLabel.isHidden = false
            contentLabel.frame = CGRect(x: Self.horizontalPadding, y: y, width: width - Self.horizontalPadding * 2, height: textHeight)
            y += textHeight + 5
            moreLabel.isHidden = !isTruncated
            if isTruncated {
                moreLabel.frame = CGRect(x: Self.horizontalPadding, y: y, width: width - Self.horizontalPadding * 2, height: Self.moreLineHeight)
                y += Self.moreLineHeight
            }
        } else {
            contentLabel.isHidden = true
            moreLabel.isHidden = true
        }
        if !articleImageView.isHidden {
            y += 10
            articleImageView.frame = CGRect(x: 0, y: y, width: width, height: Self.imageHeight(width: width))
            y += Self.imageHeight(width: width)
        }
        y += Self.verticalPadding
        dividerView.frame = CGRect(x: 0, y: y, width: width, height: 0.5)
        y += 0.5
        shareLabel.frame = CGRect(x: 0, y: y, width: width / 2, height: Self.actionBarHeight)
        actionDividerView.frame = CGRect(x: width / 2, y: y, width: 0.5, height: Self.actionBarHeight)
        replyLabel.frame = CGRect(x: width / 2, y: y, width: width / 2, height: Self.actionBarHeight)
        // 마지막 셀의 하단 여백(safe area) 패딩과 무관하게 카드는 콘텐츠 끝까지만
        cardContainerView.frame = CGRect(x: 0, y: 0, width: width, height: y + Self.actionBarHeight)
        layer.shadowPath = UIBezierPath(roundedRect: cardContainerView.frame, cornerRadius: cardContainerView.layer.cornerRadius).cgPath
    }

    // 셀 전체 높이 — layoutSubviews와 동일 수식 유지
    static func height(for item: ArticleItem, width: CGFloat) -> CGFloat {
        var height = verticalPadding + avatarSize

        if let content = item.content, !content.isEmpty {
            let (textHeight, isTruncated) = contentTextHeight(content, width: width - horizontalPadding * 2)

            height += 10 + textHeight + 5
            if isTruncated {
                height += moreLineHeight
            }
        }
        if item.images.first != nil {
            height += 10 + imageHeight(width: width)
        }
        return height + verticalPadding + 0.5 + actionBarHeight
    }

    // 내용 텍스트 높이(최대 4줄 캡)와 잘림 여부
    private static func contentTextHeight(_ content: String, width: CGFloat) -> (height: CGFloat, isTruncated: Bool) {
        let fullHeight = ceil((content as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: contentFont], context: nil).height)
        let maxHeight = ceil(contentFont.lineHeight * CGFloat(contentMaxLines))

        return (min(fullHeight, maxHeight), fullHeight > maxHeight)
    }

    private static var moreLineHeight: CGFloat {
        return ceil(contentFont.lineHeight)
    }

    // Android는 adjustViewBounds로 원본 비율 — 로드 전 높이를 알 수 없어 16:9 고정 (상세 화면과 동일 방침)
    private static func imageHeight(width: CGFloat) -> CGFloat {
        return floor(width * 9 / 16)
    }
}
