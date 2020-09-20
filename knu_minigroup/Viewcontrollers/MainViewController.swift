//
//  MainController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/08/30.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITabBarDelegate {
    @IBOutlet var mTabBar: UITabBar!
    @IBOutlet var mFindTabBarItem: UITabBarItem!
    @IBOutlet var mRequestTabBarItem: UITabBarItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mTabBar.delegate = self
    }
    
    @IBAction func barButtonItemClick(_ sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parent as? DrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item {
        case mFindTabBarItem:
            let findViewController = storyboard?.instantiateViewController(withIdentifier: "FindViewController") as! FindViewController
            
            navigationController?.pushViewController(findViewController, animated: true)
        case mRequestTabBarItem:
            let requestViewController = storyboard?.instantiateViewController(withIdentifier: "RequestViewController") as! RequestViewController
            
            navigationController?.pushViewController(requestViewController, animated: true)
        default:
            break
        }
    }
}
