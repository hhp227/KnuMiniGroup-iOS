//
//  MainController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/08/30.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func barButtonItemClick(_ sender: UIBarButtonItem) {
        if let drawerController = parent as? DrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
    
}
