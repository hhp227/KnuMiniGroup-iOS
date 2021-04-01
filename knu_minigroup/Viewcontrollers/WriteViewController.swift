//
//  WriteViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/03/19.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

class WriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let data = [["Apple", "OSX", "iOS"], ["One", "Two", "Three", "Four"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = {
            let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 150))
            let textView = UITextView(frame: header.bounds)
            header.backgroundColor = .systemOrange
            header.addSubview(textView)
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.leadingAnchor.constraint(equalTo: header.leadingAnchor).isActive = true
            textView.trailingAnchor.constraint(equalTo: header.trailingAnchor).isActive = true
            textView.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
            textView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            textView.delegate = self
            textView.isScrollEnabled = false
            return header
        }()
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "inputText", for: indexPath)
            //print(cell.viewWithTag(0))
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath)
            cell.textLabel?.text = data[indexPath.section][indexPath.row]
            cell.backgroundColor = .systemBlue
        }
        return cell
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print(textView.text!)
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimateSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimateSize.height
                tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: estimateSize.height)
            }
        }
    }
}
