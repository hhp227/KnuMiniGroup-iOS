//
//  ViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/08/23.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var idTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    let defaultValues = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        idTextField.delegate = self
        passwordTextField.delegate = self
        
        if defaultValues.string(forKey: "userId") != nil {
            let drawerController = storyboard?.instantiateViewController(withIdentifier: "DrawerController") as! DrawerController
            
            navigationController?.pushViewController(drawerController, animated: false)
        }
    }

    @IBAction func loginClick(_ sender: UIButton) {
        guard let id = idTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        if !id.isEmpty && !password.isEmpty {
            let drawerController = storyboard?.instantiateViewController(withIdentifier: "DrawerController") as! DrawerController
            
            defaultValues.set(id, forKey: "userId")
            defaultValues.set(password, forKey: "password")
            navigationController?.pushViewController(drawerController, animated: true)
            dismiss(animated: false, completion: nil)
        } else {
            print("No")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

