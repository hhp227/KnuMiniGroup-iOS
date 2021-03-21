//
//  CreateViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/22.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class CreateViewController: UIViewController {
    @IBOutlet weak var textFieldGroupTitle: UITextField!
    
    @IBOutlet weak var textViewGroupDescription: UITextView!
    
    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var buttonTitleReset: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textViewGroupDescription.placeholder = "그룹 설명을 입력하세요."
    }

    @IBAction func actionSend(_ sender: UIBarButtonItem) {
        guard let title = textFieldGroupTitle.text, !title.isEmpty else {
            print("그룹 이름을 입력하세요.")
            return
        }
        guard let description = textViewGroupDescription.text, !description.isEmpty else {
            print("그룹 설명을 입력하세요.")
            return
        }
        print(textViewGroupDescription.text!)
        
    }
    
    @IBAction func actionTitleReset(_ sender: UIButton) {
        textFieldGroupTitle.text = nil
    }
}

extension UITextView: UITextViewDelegate {
    override open var bounds: CGRect {
        didSet {
            resizePlaceholder()
        }
    }
    
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            return placeholderText
        }
        set {
            if let placeholderLabel = viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                
                placeholderLabel.sizeToFit()
            } else {
                let placeholderLabel = UILabel()
                placeholderLabel.text = newValue
                placeholderLabel.font = font
                placeholderLabel.textColor = UIColor.lightGray
                placeholderLabel.tag = 100
                placeholderLabel.isHidden = !text.isEmpty
                
                placeholderLabel.sizeToFit()
                addSubview(placeholderLabel)
                resizePlaceholder()
                delegate = self
            }
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }
    
    private func resizePlaceholder() {
        if let placeholderLabel = viewWithTag(100) as! UILabel? {
            let labelX = textContainer.lineFragmentPadding
            let labelY = textContainerInset.top
            let labelWidth = frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
}
