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
    
    @IBOutlet weak var stackViewGroupType: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldGroupTitle.delegate = self
        textViewGroupDescription.placeholder = "그룹 설명을 입력하세요."
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            stackViewGroupType.frame.origin.y -= keyboardHeight
        }
        print("show")
        print({ () -> Bool in
            guard let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow") else {
                return false
            }
                return UIApplication.shared.windows.contains(where: { $0.isKind(of: keyboardWindowClass) })
            }())
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            stackViewGroupType.frame.origin.y += keyboardHeight
        }
        print("hide")
        print({ () -> Bool in
            guard let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow") else {
                return false
            }
                return UIApplication.shared.windows.contains(where: { $0.isKind(of: keyboardWindowClass) })
            }())
    }
}

extension CreateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldGroupTitle {
            textViewGroupDescription.becomeFirstResponder()
        }
        return true
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
            guard let placeholderLabel = viewWithTag(100) as? UILabel else {
                return nil
            }
            return placeholderLabel.text
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
