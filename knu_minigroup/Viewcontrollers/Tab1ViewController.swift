//
//  Tab1ViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/12/03.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class Tab1ViewController: TabViewController, UITableViewDelegate, UITableViewDataSource {
    
    // TODO Storyboard로 바꿀것
    @IBOutlet weak var tableView: UITableView!
    
    var data = [CellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        data = [CellData.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal"), CellData.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal"), CellData.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal"), CellData.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal"), CellData.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal"), CellData.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal")]
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as? ArticleTableViewCell else {
            fatalError()
        }
        cell.mainImage = data[indexPath.row].image
        cell.message = data[indexPath.row].message
        
        cell.layoutSubviews()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as? ArticleTableViewCell

        if segueDelegateFunc != nil {
            segueDelegateFunc!("articleDetail", cell!)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

struct CellData {
    let image: UIImage?
    let message: String
}
