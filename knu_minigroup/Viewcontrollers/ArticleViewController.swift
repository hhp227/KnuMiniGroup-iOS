//
//  ArticleViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/03/08.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {
    @IBOutlet weak var viewToolbar: UIView!
    
    @IBOutlet weak var textViewInput: TextViewExtension!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)*/
        let sendLabel = UILabel()
        
        viewToolbar.backgroundColor = .gray
        sendLabel.text = "send"
        
        textViewInput.delegate = self
        textViewInput.layer.cornerRadius = 5
        textViewInput.isAnimate = true                                               //에니메이션 사용여부
        textViewInput.maxLength = 200                                                //최대 글자수
        textViewInput.maxHeight = 100                                                //최대 높이 제한
        textViewInput.placeHolder = "메세지를 입력해주세요."                               //플레이스홀더
        textViewInput.placeHolderColor = UIColor(white: 0.8, alpha: 1.0)             //플레이스홀더 색상
        textViewInput.font = UIFont.systemFont(ofSize: 17)
     
        viewToolbar.translatesAutoresizingMaskIntoConstraints = false
        textViewInput.translatesAutoresizingMaskIntoConstraints = false
        sendLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(viewToolbar)
        viewToolbar.addSubview(textViewInput)
        viewToolbar.addSubview(sendLabel)

        if #available(iOS 11.0, *) {
            viewToolbar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            bottomConstraint = viewToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            viewToolbar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        } else {
            viewToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            bottomConstraint = viewToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            viewToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
        bottomConstraint?.isActive = true
        
        sendLabel.bottomAnchor.constraint(equalTo: viewToolbar.bottomAnchor).isActive = true
        sendLabel.trailingAnchor.constraint(equalTo: viewToolbar.trailingAnchor, constant: -8).isActive = true
        sendLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        sendLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        textViewInput.topAnchor.constraint(equalTo: viewToolbar.topAnchor, constant: 8).isActive = true
        textViewInput.leadingAnchor.constraint(equalTo: viewToolbar.leadingAnchor, constant: 8).isActive = true
        textViewInput.trailingAnchor.constraint(equalTo: sendLabel.leadingAnchor, constant: -8).isActive = true
        textViewInput.bottomAnchor.constraint(equalTo: viewToolbar.bottomAnchor, constant: -8).isActive = true
    
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        view.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        let endFrame = ((notification as NSNotification).userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        bottomConstraint?.constant = -(view.bounds.height - endFrame.origin.y)
        self.view.layoutIfNeeded()
    }

    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        /*NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: view.window)*/
    }
    
    /*@objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            viewToolbar.frame.origin.y -= keyboardHeight
            
            excludeBottomPadding { $0 + $1 }
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
            viewToolbar.frame.origin.y += keyboardHeight
            
            excludeBottomPadding { $0 - $1 }
        }
        print("hide")
        print({ () -> Bool in
            guard let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow") else {
                return false
            }
                return UIApplication.shared.windows.contains(where: { $0.isKind(of: keyboardWindowClass) })
            }())
    }*/
    
    private func excludeBottomPadding(function: (CGFloat, CGFloat) -> CGFloat) {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            let bottomPadding = window?.safeAreaInsets.bottom
            viewToolbar.frame.origin.y = function(viewToolbar.frame.origin.y, bottomPadding!)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ArticleViewController: TextViewMasterDelegate {
    private func growingTextView(growingTextView: TextViewExtension, willChangeHeight height: CGFloat) {
        self.view.layoutIfNeeded()
    }
}
