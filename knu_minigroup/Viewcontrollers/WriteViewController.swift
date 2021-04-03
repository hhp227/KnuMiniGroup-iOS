//
//  WriteViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/03/19.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

class WriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var toolBarStackView: UIStackView!
    
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    
    let data = [["Apple", "OSX", "iOS"], ["One", "Two", "Three", "Four"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: view.window)
    }
    
    @IBAction func actionSend(_ sender: UIBarButtonItem) {
        print("Send")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func handleKeyboardNotification(_ notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.stackViewBottomConstraint.constant = isKeyboardShowing ? -keyboardFrame!.height : 0
                
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                /*if isKeyboardShowing {
                    let indexPath = NSIndexPath(forItem: self.messages!.count - 1, inSection: 0)
                     
                    self.collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)*/
            })
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            toolBarStackView.frame.origin.y -= keyboardHeight
            
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
            toolBarStackView.frame.origin.y += keyboardHeight
            
            excludeBottomPadding { $0 - $1 }
        }
        print("hide")
        print({ () -> Bool in
            guard let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow") else {
                return false
            }
                return UIApplication.shared.windows.contains(where: { $0.isKind(of: keyboardWindowClass) })
            }())
    }
    
    private func excludeBottomPadding(function: (CGFloat, CGFloat) -> CGFloat) {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            let bottomPadding = window?.safeAreaInsets.bottom
            toolBarStackView.frame.origin.y = function(toolBarStackView.frame.origin.y, bottomPadding!)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0, let inputTextCell = tableView.dequeueReusableCell(withIdentifier: "inputText", for: indexPath) as? WriteInputTextTableViewCell {
            inputTextCell.heightDelegateFunc = { (cell, textView) -> Void in
                let size = textView.bounds.size
                let newSize = tableView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
                
                if size.height != newSize.height {
                    UIView.setAnimationsEnabled(false)
                    tableView.beginUpdates()
                    tableView.endUpdates()
                    UIView.setAnimationsEnabled(true)
                    if let thisIndexPath = tableView.indexPath(for: cell) {
                        tableView.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
                    }
                }
            }
            return inputTextCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath)
            cell.textLabel?.text = data[indexPath.section][indexPath.row]
            cell.backgroundColor = .systemBlue
            return cell
        }
    }
}
