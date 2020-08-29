//
//  MainController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/08/30.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class MainController: UIViewController {
    @IBOutlet var mLabelId: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaultValues = UserDefaults.standard
        
        if let id = defaultValues.string(forKey: "userId") {
            mLabelId.text = id
        }
    }
    
    @IBAction func logoutClick(_ sender: UIButton) {
        let loginController = storyboard?.instantiateViewController(identifier: "ViewController") as! ViewController
        
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        navigationController?.pushViewController(loginController, animated: true)
        dismiss(animated: false, completion: nil)
    }
}
