//
//  HeaderedTabScrollViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/11/30.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

open class HeaderedTabScrollViewController: UIViewController {
    private let headerContainer = UIView()

    private var headerHeightConstraint: NSLayoutConstraint?

    private var lastTabScrollViewOffset: CGPoint = .zero

    //private var navBarOverlay: UIView?

    var headerTopConstraint: NSLayoutConstraint?
    
    var tabTopConstraint: NSLayoutConstraint?
    
    public var headerView: UIView? {
        didSet {
            if headerView != nil {
                headerContainer.subviews.forEach { $0.removeFromSuperview() }
                headerContainer.addSubview(headerView!)
                headerView!.translatesAutoresizingMaskIntoConstraints = false
                headerView!.topAnchor.constraint(equalTo: headerContainer.topAnchor).isActive = true
                headerView!.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor).isActive = true
                headerView!.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor).isActive = true
                headerView!.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor).isActive = true
            }
            
        }
    }

    public var headerHeight: CGFloat = 240 {
        didSet {
            if let constraint = headerHeightConstraint {
                constraint.constant = headerHeight
            }
        }
    }
    
    /*public var navBarTransparancy: CGFloat {
        get {
            if navBarOverlay != nil {
                return navBarOverlay!.backgroundColor!.cgColor.alpha
            } else {
                return 0
            }
            
        } set(value) {
            if navBarOverlay != nil {
                navBarOverlay!.backgroundColor = navBarColor.withAlphaComponent(value)
            }
        }
    }
    
    public var navBarColor: UIColor = .black {
        didSet {
            if navBarOverlay != nil {
                navBarOverlay!.backgroundColor = navBarColor.withAlphaComponent(navBarTransparancy)
            }
        }
    }*/

    public var headerBackgroundColor: UIColor? {
        get {
            return self.view.backgroundColor
        }
        set(value) {
            self.view.backgroundColor = value
        }
    }
    
    public var navBarItemsColor: UIColor = .white {
        didSet {
            if let navCtrl = self.navigationController {
                navCtrl.navigationBar.tintColor = navBarItemsColor
            }
        }
    }
    
    public var navBarTitleColor: UIColor = .white {
        didSet {
            if let navCtrl = self.navigationController {
                navCtrl.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: navBarTitleColor]
            }
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Header
        self.view.addSubview(headerContainer)
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerTopConstraint = headerContainer.topAnchor.constraint(equalTo: self.view.topAnchor)
        headerTopConstraint!.isActive = true
        headerContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        headerContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        headerHeightConstraint = headerContainer.heightAnchor.constraint(equalToConstant: self.headerHeight)
        headerHeightConstraint!.isActive = true
        lastTabScrollViewOffset = CGPoint(x: CGFloat(0), y: navBarOffset())
    }
    
    /*override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //setupNavBar()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let navCtrl = self.navigationController {
            let navBar = navCtrl.navigationBar
            navBar.setBackgroundImage(nil, for: UIBarMetrics.default)
            navBar.shadowImage = nil
            //navBarOverlay?.removeFromSuperview()
            navCtrl.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:self.navBarItemsColor.withAlphaComponent(1)]
        }
    }
    
    private func setupNavBar() {
        if let navCtrl = self.navigationController {
            let navBar = navCtrl.navigationBar
            // Make the navBar transparent
            navBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            navBar.shadowImage = UIImage()
            if navBarOverlay == nil {
                navBarOverlay = UIView.init(frame: CGRect.init(x: 0, y: 0, width: navBar.bounds.width, height: self.navBarOffset()))
            }
        
            navBarOverlay!.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
            navBar.subviews.first?.insertSubview(navBarOverlay!, at: 0)
            navBarOverlay!.backgroundColor = navBarColor.withAlphaComponent(0.0)
        }
    }*/
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func setNavBarRightItems(items: [UIBarButtonItem]) {
        self.navigationItem.rightBarButtonItems = items
        self.navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    public func setNavbarTitleTransparency(alpha: CGFloat) {
        if let navCtrl = self.navigationController {
            let navBar = navCtrl.navigationBar
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white.withAlphaComponent(alpha)]
        }
    }
    
    public func setNavBarLeftItems(items: [UIBarButtonItem]) {
        self.navigationItem.leftBarButtonItems = items
        self.navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    public func pleaseScroll(_ scrollView: UIScrollView) {
        var delta = scrollView.contentOffset.y - lastTabScrollViewOffset.y
        
        // Vertical bounds
        let maxY: CGFloat = navBarOffset()
        let minY: CGFloat = self.headerHeight
        
        if tabTopConstraint == nil { return }
        //we compress the top view
        if delta > 0 && tabTopConstraint!.constant > maxY && scrollView.contentOffset.y > 0 {
            if tabTopConstraint!.constant - delta < maxY {
                delta = tabTopConstraint!.constant - maxY
            }
            tabTopConstraint!.constant -= delta
            scrollView.contentOffset.y -= delta
        }
        
        //we expand the top view
        if delta < 0 {
            if tabTopConstraint!.constant < minY && scrollView.contentOffset.y < 0 {
                if tabTopConstraint!.constant - delta > minY {
                    delta = tabTopConstraint!.constant - minY
                }
                tabTopConstraint!.constant -= delta
                scrollView.contentOffset.y -= delta
            }
        }
        
        lastTabScrollViewOffset = scrollView.contentOffset
        headerDidScroll(minY: minY, maxY: maxY, currentY: tabTopConstraint!.constant)
    }
    
    open func headerDidScroll(minY: CGFloat, maxY: CGFloat, currentY: CGFloat) {
        // Change de opacity of the navBar
        updateNavBarAccordingToScrollPosition(minY: minY, maxY: maxY, currentY: tabTopConstraint!.constant)
        updateHeaderPositionAccordingToScrollPosition(minY: minY, maxY: maxY, currentY: tabTopConstraint!.constant)
        updateHeaderAlphaAccordingToScrollPosition(minY: minY, maxY: maxY, currentY: tabTopConstraint!.constant)
    }
    
    func navBarOffset() -> CGFloat {
        return (self.navigationController?.navigationBar.bounds.height ?? 0) + UIApplication.shared.statusBarFrame.height
    }
    
    open func updateNavBarAccordingToScrollPosition(minY: CGFloat, maxY: CGFloat, currentY: CGFloat) {
        let alphaOffset: CGFloat = (minY - maxY) * 0.3 // alpha start changing at 1/3 of the way up
        var alpha = (currentY + alphaOffset - minY) / (maxY + alphaOffset - minY)
        if currentY > minY - alphaOffset {
            alpha = 0
        }
        
        /*if (navBarOverlay != nil) {
            navBarOverlay!.backgroundColor = navBarColor.withAlphaComponent(alpha)
        }*/
        // Only the title's color is updated here
        navBarTitleColor = navBarTitleColor.withAlphaComponent(alpha)
        // do the following to update items too:
        // navBarItemsColor = navBarItemsColor.withAlphaComponent(alpha)
        
    }
    
    open func updateHeaderPositionAccordingToScrollPosition(minY: CGFloat, maxY: CGFloat, currentY: CGFloat) {
        if let constraint = headerTopConstraint {
            let paralaxCoef: CGFloat = 0.3 // i.e. if the tabScrollView goas up by 1, the header goes up by this coefficient
            let tabScrollViewTravelPercent = -(currentY - minY) / (minY - maxY)
            let headerTravelPercent = tabScrollViewTravelPercent * paralaxCoef
            let headerTargetY = headerTravelPercent * (minY - maxY)
            constraint.constant = -headerTargetY
        }
    }
    
    open func updateHeaderAlphaAccordingToScrollPosition(minY: CGFloat, maxY: CGFloat, currentY: CGFloat) {
        let alphaOffset: CGFloat = (minY - maxY) * 0.3 // alpha start changing at 1/3 of the way up
        var alpha = 1 - (currentY + alphaOffset - minY) / (maxY + alphaOffset - minY)
        if currentY > minY - alphaOffset {
            alpha = 1
        }
        
        headerContainer.alpha = alpha
    }
}
