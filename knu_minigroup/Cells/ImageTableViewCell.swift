//
//  ImageTableViewCell.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/04/04.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    @IBOutlet weak var contentImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
