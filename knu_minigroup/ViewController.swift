//
//  ViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/08/23.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var mTextFieldId: UITextField!
    @IBOutlet var mTextFieldPassword: UITextField!
    let mDefaultValues = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if mDefaultValues.string(forKey: "userId") != nil {
            let mainController = storyboard?.instantiateViewController(withIdentifier: "MainController") as! MainController
            
            navigationController?.pushViewController(mainController, animated: false)
        }
    }

    @IBAction func loginClick(_ sender: UIButton) {
        let id = mTextFieldId.text
        let password = mTextFieldPassword.text
        
        if !id!.isEmpty && !password!.isEmpty {
            let mainController = storyboard?.instantiateViewController(withIdentifier: "MainController") as! MainController
            
            mDefaultValues.set(id, forKey: "userId")
            mDefaultValues.set(password, forKey: "password")
            navigationController?.pushViewController(mainController, animated: true)
            dismiss(animated: false, completion: nil)
        } else {
            print("No")
        }
        
    }
    
}

