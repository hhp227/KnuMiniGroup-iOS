//
//  ArticleViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/03/08.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {
    
    // 명칭UIname식으로 변수선언할것
    @IBOutlet weak var viewToolbar: UIView!
    
    @IBOutlet weak var textViewInput: TextViewExtension!
    
    @IBOutlet weak var buttonSend: UIButton!
    
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textViewInput.delegate = self
        textViewInput.translatesAutoresizingMaskIntoConstraints = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler)))
    }
    
    @IBAction func actionSend(_ sender: UIButton) {
        print("send")
        print(textViewInput.frame.height)
        print(viewToolbar.frame.height)
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            toolbarBottomConstraint?.constant = {
                var keyboardHeight = view.bounds.height - endFrame.origin.y
                
                if #available(iOS 11.0, *) {
                    if keyboardHeight > 0 {
                        keyboardHeight -= view.safeAreaInsets.bottom
                    }
                }
                return -(keyboardHeight)
            }()
        }
        view.layoutIfNeeded()
    }

    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
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
extension ArticleViewController: TextViewExtensionDelegate {
    private func growingTextView(growingTextView: TextViewExtension, willChangeHeight height: CGFloat) {
        self.view.layoutIfNeeded()
    }
}
