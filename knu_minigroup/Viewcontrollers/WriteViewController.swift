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
    
    let data = [["Apple", "OSX", "iOS"], ["One", "Two", "Three", "Four"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
    
    // 일반 textView 길이 조절하는것
    /*func textViewDidChange(_ textView: UITextView) {
        print(textView.text!)
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimateSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimateSize.height
            }
        }
    }*/
}
