//
//  HeaderedCAPSPageMenuViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/12/02.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

open class HeaderedCAPSPageMenuViewController: HeaderedTabScrollViewController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // 탭레이아웃
        self.view.addSubview(pageMenuContainer)
        pageMenuContainer.frame = CGRect(x: 0, y: headerHeight, width: self.view.frame.width, height: self.view.frame.height - navBarOffset())
        pageMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        pageMenuContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        pageMenuContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tabTopConstraint = pageMenuContainer.topAnchor.constraint(equalTo: self.view.topAnchor, constant: headerHeight)
        tabTopConstraint!.isActive = true
        pageMenuContainer.heightAnchor.constraint(equalToConstant: self.view.frame.height - navBarOffset()).isActive = true
    }
    public func addPageMenu(menu: CAPSPageMenu) {
        pageMenuController = menu
        
        pageMenuContainer.addSubview(pageMenuController!.view)
    }
    
    public var pageMenuController: CAPSPageMenu?
    public let pageMenuContainer = UIView()
}

