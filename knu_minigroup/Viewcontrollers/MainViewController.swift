//
//  MainController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/08/30.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet var mLabelId: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaultValues = UserDefaults.standard
        
        if let id = defaultValues.string(forKey: "userId") {
            mLabelId.text = id
        }
    }
    
    @IBAction func barButtonItemClick(_ sender: UIBarButtonItem) {
        if let drawerController = parent as? DrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
    @IBAction func logoutClick(_ sender: UIButton) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        navigationController?.popViewController(animated: true)
        dismiss(animated: false, completion: nil)
    }
}
