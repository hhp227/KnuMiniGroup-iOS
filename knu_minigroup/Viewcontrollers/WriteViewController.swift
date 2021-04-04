//
//  WriteViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/03/19.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit
import MobileCoreServices

class WriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var toolBarStackView: UIStackView!
    
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    
    var data: Array<Any> = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /*override func viewDidAppear(_ animated: Bool) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        }
    }*/
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: view.window)
    }
    
    @IBAction func actionSend(_ sender: UIBarButtonItem) {
        if let textInputCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? WriteInputTextTableViewCell {
            guard !textInputCell.inputTitleTextView.text.isEmpty else {
                Toast.makeText(view: view, message: "제목을 입력하세요.", duration: Toast.LENGTH_LONG).show()
                print("제목을 입력하세요.")
                return
            }
            guard !textInputCell.inputContentTextView.text.isEmpty else {
                print("내용을 입력하세요.")
                return
            }
            print("title: \(textInputCell.inputTitleTextView.text), content: \(textInputCell.inputContentTextView.text)")
        }
    }
    
    @IBAction func actionImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        let galleryAction = UIAlertAction(title: "갤러리", style: UIAlertAction.Style.default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = true
                
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                self.showAlert(title: "카메라 접근 불가", [UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)])
            }
        }
        let cameraAction = UIAlertAction(title: "카메라", style: UIAlertAction.Style.default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.delegate = self
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = true
                
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                self.showAlert(title: "카메라 접근 불가", [UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)])
            }
        }
        let actions = [galleryAction, cameraAction]
        
        showAlert(title: "이미지 선택", actions)
    }
    
    @IBAction func actionVideo(_ sender: UIButton) {
        let alert = UIAlertController(title: "동영상 선택", message:  nil, preferredStyle: UIAlertController.Style.alert)
        let youtubeAction = UIAlertAction(title: "유튜브", style: UIAlertAction.Style.default, handler: nil)
        
        alert.addAction(youtubeAction)
        present(alert, animated: true, completion: nil)
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
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.stackViewBottomConstraint.constant = isKeyboardShowing ? -keyboardRectangle.height : 0
                
                self.excludeBottomPadding { isKeyboardShowing ? $0 + $1 : $0 * $1 }
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                /*if isKeyboardShowing {
                    let indexPath = IndexPath(item: self.data.count - 1, section: 0)
                    
                    print("Keyboard Showing")
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }*/
            })
        }
    }
    
    /*@objc private func keyboardWillShow(_ notification: Notification) {
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
    }*/
    
    private func excludeBottomPadding(function: (CGFloat, CGFloat) -> CGFloat) {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            
            if let bottomPadding = window?.safeAreaInsets.bottom {
                stackViewBottomConstraint.constant = function(stackViewBottomConstraint.constant, bottomPadding)
            }
        }
    }
    
    private func showAlert(title: String?, message: String? = nil, _ actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        actions.forEach(alert.addAction)
        present(alert, animated: true, completion: nil)
    }
    
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }*/
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.row != 0 ? indexPath : nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath) as? ImageTableViewCell
            
            if data[indexPath.row] is UIImage {
                cell?.contentImageView.image = (data[indexPath.row] as! UIImage)
            }
            cell!.backgroundColor = .systemBlue
            return cell!
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        
        if mediaType.isEqual(to: kUTTypeImage as NSString as String) {
            let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            
            // TODO if flagImageSave {} 작성해줘야함 아마 카메라로 찍었을때 찍은 사진이 포토갤러리에 저장되게 하는 내용을 작성할 예정
            data.append(editedImage!)
            tableView.reloadData() // 임시코드
            //tableView.reloadRows(at: [IndexPath.init(row: data.count - 1, section: 0)], with: UITableView.RowAnimation.automatic)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
