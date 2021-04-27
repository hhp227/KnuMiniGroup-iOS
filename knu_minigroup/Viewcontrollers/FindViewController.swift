//
//  FindViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/20.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class FindViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var data = [GroupItem.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal"), GroupItem.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal"), GroupItem.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal"), GroupItem.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal"), GroupItem.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal"), GroupItem.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal"), GroupItem.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal"), GroupItem.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        addRefreshControl()
    }
    
    @objc func refreshControlDidChangeValue(refreshControl: UIRefreshControl) {
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(refreshControlDidChangeValue), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as? GroupTableViewCell else {
            fatalError()
        }
        cell.mainImage = data[indexPath.row].image
        cell.messsage = data[indexPath.row].message
        
        cell.layoutSubviews()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
}
