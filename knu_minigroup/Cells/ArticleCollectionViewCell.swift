//
//  ArticleTableViewCell.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/04/08.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

class ArticleCollectionViewCell: UICollectionViewCell {
    var message: String?
    
    var mainImage: UIImage?
    
    var articleItem: ArticleItem?
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var articleImageView: UIImageView!
    
    @IBOutlet weak var articleTextView: UITextView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var replyButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let item = articleItem {
            titleLabel.text = item.title
            dateLabel.text = item.date
            articleTextView.text = item.content
            articleTextView.isScrollEnabled = false
            articleTextView.translatesAutoresizingMaskIntoConstraints = true
            
            if !item.images.isEmpty {
                articleImageView.image = item.images[0]
            } else {
                articleImageView.isHidden = true
            }
        }
        articleTextView.sizeToFit()
     
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func actionShare(_ sender: UIButton) {
        print("Share")
    }
}
