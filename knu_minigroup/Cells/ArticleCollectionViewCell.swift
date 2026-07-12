//
//  ArticleTableViewCell.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/04/08.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

class ArticleCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var articleImageView: UIImageView!

    @IBOutlet weak var contentLabel: UILabel!

    @IBOutlet weak var moreLabel: UILabel!

    @IBOutlet weak var shareButton: UIButton!

    @IBOutlet weak var replyButton: UIButton!

    var message: String?

    var mainImage: UIImage?

    var articleItem: ArticleItem?

    override func layoutSubviews() {
        super.layoutSubviews()
        if let item = articleItem {
            titleLabel.text = (item.title ?? "") + " - " + (item.name ?? "")
            dateLabel.text = item.date
            contentLabel.text = item.content

            if let content = item.content, !content.isEmpty, contentLabel.getLineCount() > contentLabel.numberOfLines {
                moreLabel.isHidden = false
            } else {
                moreLabel.isHidden = true
            }
            if let imageUrl = item.images.first {
                articleImageView.isHidden = false

                articleImageView.loadImage(imageUrl)
            } else {
                articleImageView.isHidden = true
            }
            replyButton.setTitle("댓글 \(item.replyCount ?? "0")", for: .normal)
        }
        contentLabel.sizeToFit()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        cardView()
    }

    @IBAction func actionShare(_ sender: UIButton) {
        print("Share")
    }
}
