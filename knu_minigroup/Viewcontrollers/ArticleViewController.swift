//
//  ArticleViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/03/08.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {
    @IBOutlet weak var toolbarView: UIView!

    @IBOutlet weak var inputTextView: UITextViewExtension!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    private var data = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputTextView.delegate = self
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        print(data)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler)))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func actionSend(_ sender: UIButton) {
        print("actionSend")
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
    
    private func excludeBottomPadding(function: (CGFloat, CGFloat) -> CGFloat) {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            let bottomPadding = window?.safeAreaInsets.bottom
            toolbarView.frame.origin.y = function(toolbarView.frame.origin.y, bottomPadding!)
        }
    }
    
    private func fetchDataTask(_ id: String) {
        // TODO 통신해서 aricleItem받아오기
        //data.append(articleItem)
        print(id)
    }
    
    func receiveItem(_ articleItem: ArticleItem) {
        //fetchDataTask(articleItem.id)
        data.append(articleItem)
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

extension ArticleViewController: UITextViewExtensionDelegate {
    private func increaseHeight(textView: UITextViewExtension, willChangeHeight height: CGFloat) {
        self.view.layoutIfNeeded()
    }
}
