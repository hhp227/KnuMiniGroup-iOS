//
//  CreateViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/22.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class CreateViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setRightBarButton(UIBarButtonItem(title: "전송", style: .done, target: self, action: #selector(actionSend)), animated: true)
    }
    
    @objc func actionSend() {
        print("전송")
    }

}
