//
//  PlaceholderViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/12/03.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class PlaceholderViewController: UIViewController {
    var scrollDelegateFunc: ((UIScrollView) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.scrollDelegateFunc != nil {
            self.scrollDelegateFunc!(scrollView)
        }
    }
}
