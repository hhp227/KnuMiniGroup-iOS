//
//  TabNavigationController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/03/10.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

open class TabNavigationController: UINavigationController, TabScrollViewDelegate {
    var scrollDelegateFunc: ((UIScrollView) -> Void)?
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollDelegateFunc != nil {
            scrollDelegateFunc!(scrollView)
        }
    }

}
