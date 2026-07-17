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

    var pushDelegateFunc: ((UIViewController) -> Void)?

    // 드래그/디셀러레이션이 끝나 스크롤이 완전히 멈춘 시점에만 호출 (헤더 snap 트리거용)
    var settledScrollDelegateFunc: ((UIScrollView) -> Void)?

    open override func viewDidLoad() {
        super.viewDidLoad()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollDelegateFunc != nil {
            scrollDelegateFunc!(scrollView)
        }
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            settledScrollDelegateFunc?(scrollView)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        settledScrollDelegateFunc?(scrollView)
    }
}

protocol TabScrollViewDelegate: UIScrollViewDelegate {
    var scrollDelegateFunc: ((UIScrollView) -> Void)? { get set }
}
