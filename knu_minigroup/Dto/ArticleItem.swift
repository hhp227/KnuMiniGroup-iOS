//
//  ArticleItem.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/04/15.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

struct ArticleItem {
    let auth: Bool
    
    let timestamp: Int
    
    let id, uid, name, title, content, date, replyCount: String
    
    let images: [UIImage]
    
    let youtube: String?
}
