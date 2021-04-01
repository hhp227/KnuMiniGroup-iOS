//
//  TimetableViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/03/28.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

class TimetableViewController: UIViewController {
    
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
