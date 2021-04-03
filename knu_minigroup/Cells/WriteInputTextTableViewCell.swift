//
//  WriteInputTextTableViewCell.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/04/02.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

class WriteInputTextTableViewCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var inputTitleTextView: UITextView!
    
    @IBOutlet weak var inputContentTextView: UITextView!
    
    var heightDelegateFunc: ((WriteInputTextTableViewCell, UITextView) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputTitleTextView.textContainer.maximumNumberOfLines = 1
        inputContentTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func textViewDidChange(_ textView: UITextView) {
        if let updateHeightOfRow = heightDelegateFunc {
            updateHeightOfRow(self, textView)
        }
    }
}
