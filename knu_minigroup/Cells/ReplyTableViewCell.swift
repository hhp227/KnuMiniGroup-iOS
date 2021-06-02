//
//  ReplyTableViewCell.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/06/01.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

class ReplyTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var reply: UILabel!
    
    @IBOutlet weak var timestamp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
