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
    
    @IBOutlet weak var articleImageView: UIImageView!
    
    @IBOutlet weak var articleTextView: UITextView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let message = message {
            articleTextView.text = message
        }
        /*if let image = mainImage {
            articleImageView.image = image
        }*/
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
