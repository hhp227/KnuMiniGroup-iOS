//
//  ViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/08/23.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var mTextFieldId: UITextField!
    @IBOutlet var mTextFieldPassword: UITextField!
    let mDefaultValues = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if mDefaultValues.string(forKey: "userId") != nil {
            let drawerController = storyboard?.instantiateViewController(withIdentifier: "DrawerController") as! DrawerController
            
            navigationController?.pushViewController(drawerController, animated: false)
        }
    }

    @IBAction func loginClick(_ sender: UIButton) {
        guard let id = mTextFieldId.text else { return }
        guard let password = mTextFieldPassword.text else { return }
        
        if !id.isEmpty && !password.isEmpty {
            let drawerController = storyboard?.instantiateViewController(withIdentifier: "DrawerController") as! DrawerController
            
            mDefaultValues.set(id, forKey: "userId")
            mDefaultValues.set(password, forKey: "password")
            navigationController?.pushViewController(drawerController, animated: true)
            dismiss(animated: false, completion: nil)
        } else {
            print("No")
        }
        
    }
    
}

