//
//  ArticleViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/03/08.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {
    @IBOutlet weak var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            toolbar.frame.origin.y -= keyboardHeight
            
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.windows.first { $0.isKeyWindow }
                let bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
                toolbar.frame.origin.y += bottomPadding
            }
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
            toolbar.frame.origin.y += keyboardHeight
            
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.windows.first { $0.isKeyWindow }
                let bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
                toolbar.frame.origin.y -= bottomPadding
                
            }
        }
        print("hide")
        print({ () -> Bool in
            guard let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow") else {
                return false
            }
                return UIApplication.shared.windows.contains(where: { $0.isKind(of: keyboardWindowClass) })
            }())
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
