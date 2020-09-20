//
//  UnivNoticeViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/13.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class UnivNoticeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func barButtonItemClick(_ sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parent as? DrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
}
