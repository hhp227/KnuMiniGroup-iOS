//
//  GroupTableViewCell.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/04/15.
//  Copyright © 2021 홍희표. All rights reserved.
//
//  소모임 찾기/가입신청 목록 셀
//

import UIKit

class GroupTableViewCell: UITableViewCell {
    var messsage: String?

    var mainImage: UIImage?

    var messageView: UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isUserInteractionEnabled = false
        return textView
    }()

    var mainImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(mainImageView)
        addSubview(messageView)
        mainImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        mainImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        mainImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mainImageView.bottomAnchor.constraint(equalTo: messageView.topAnchor).isActive = true
        messageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        messageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        messageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let text = messsage {
            messageView.text = text
        }
        if let image = mainImage {
            mainImageView.image = image
        }
    }

    func bind(_ groupItem: GroupItem) {
        messsage = (groupItem.name ?? "") + "\n" + (groupItem.groupDescription ?? groupItem.info ?? "")
        messageView.text = messsage
        mainImageView.loadImage(groupItem.image, placeholder: UIImage(named: "knu_minigroup"))
    }
}
