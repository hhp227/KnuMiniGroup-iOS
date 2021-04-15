//
//  TabViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/02/21.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

open class TabViewController: UIViewController, TabScrollViewDelegate {
    var scrollDelegateFunc: ((UIScrollView) -> Void)?
    
    var segueDelegateFunc: ((String, Any) -> Void)?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollDelegateFunc != nil {
            scrollDelegateFunc!(scrollView)
        }
    }
}

protocol TabScrollViewDelegate: UIScrollViewDelegate {
    var scrollDelegateFunc: ((UIScrollView) -> Void)? { get set }
}
