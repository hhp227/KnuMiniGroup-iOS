//
//  TabHostViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/10/12.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class TabHostViewController: UIViewController, TabLayoutDelegate {
    @IBOutlet weak var headerContainer: UIView!
    
    @IBOutlet weak var tabMenuContainer: UIView!
    
    @IBOutlet weak var fab: UIButton!

    private var lastTabScrollViewOffset: CGPoint = .zero
    
    let tabsTexts = ["소식", "일정", "맴버", "설정"]
    
    var headerHeightConstraint: NSLayoutConstraint?
    
    var headerTopConstraint: NSLayoutConstraint?
    
    var tabTopConstraint: NSLayoutConstraint?

    public var headerHeight: CGFloat = 240 {
        didSet {
            if let constraint = headerHeightConstraint {
                constraint.constant = oldValue
            }
        }
    }
    
    public var headerBackgroundColor: UIColor? {
        get {
            return view.backgroundColor
        }
        set(value) {
            view.backgroundColor = value
        }
    }
    
    public var navBarItemsColor: UIColor = .white {
        didSet {
            if let navCtrl = navigationController {
                navCtrl.navigationBar.tintColor = navBarItemsColor
            }
        }
    }
    
    public var navBarTitleColor: UIColor = .white {
        didSet {
            if let navCtrl = navigationController {
                navCtrl.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: navBarTitleColor]
            }
        }
    }
    
    //private var navBarOverlay: UIView?
    
    public var pageMenuController: TabLayout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let parameters: [TabLayoutOption] = [
            .scrollMenuBackgroundColor(#colorLiteral(red: 0.07058823529, green: 0.09411764706, blue: 0.1019607843, alpha: 0.5)),
            .viewBackgroundColor(#colorLiteral(red: 0.07058823529, green: 0.09411764706, blue: 0.1019607843, alpha: 0.5)),
            .bottomMenuHairlineColor(UIColor(red: 20.0 / 255.0, green: 20.0 / 255.0, blue: 20.0 / 255.0, alpha: 0.1)),
            .selectionIndicatorColor(#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)),
            .menuMargin(0.0),
            .menuHeight(48.0),
            .selectedMenuItemLabelColor(.white),
            .unselectedMenuItemLabelColor(.white),
            .useMenuLikeSegmentedControl(true),
            .selectionIndicatorHeight(2.0),
            .menuItemFont(UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.light)),
            .menuItemWidthBasedOnTitleTextWidth(false)
        ]
        let controllers: [TabViewController] = {
            let array = [
                storyboard?.instantiateViewController(withIdentifier: "Tab1ViewController") as! TabViewController,
                storyboard?.instantiateViewController(withIdentifier: "Tab2ViewController") as! TabViewController,
                storyboard?.instantiateViewController(withIdentifier: "Tab3ViewController") as! TabViewController,
                storyboard?.instantiateViewController(withIdentifier: "Tab4ViewController") as! TabViewController
            ]
            
            for i in array.indices {
                array[i].scrollDelegateFunc = pleaseScroll
                array[i].segueDelegateFunc = {
                    self.performSegue(withIdentifier: $0, sender: $1)
                    print("Test \(i)")
                }
                array[i].title = tabsTexts[i]
            }
            return array
        }()
        headerBackgroundColor = #colorLiteral(red: 0.07058823529, green: 0.09411764706, blue: 0.1019607843, alpha: 1)
        //self.navBarTransparancy = 0
        navBarItemsColor = .white
        headerTopConstraint = headerContainer.topAnchor.constraint(equalTo: view.topAnchor)
        headerTopConstraint!.isActive = true
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        headerHeightConstraint = headerContainer.heightAnchor.constraint(equalToConstant: headerHeight)
        headerHeightConstraint!.isActive = true
        lastTabScrollViewOffset = CGPoint(x: CGFloat(0), y: navBarOffset())
        tabMenuContainer.frame = CGRect(x: 0, y: headerHeight, width: view.frame.width, height: view.frame.height - navBarOffset())
        tabMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        tabMenuContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tabMenuContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tabTopConstraint = tabMenuContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: headerHeight)
        tabTopConstraint!.isActive = true
        tabMenuContainer.heightAnchor.constraint(equalToConstant: view.frame.height - navBarOffset()).isActive = true
        
        // 탭 레이아웃 추가
        pageMenuController = TabLayout(viewControllers: controllers, frame: CGRect(x: 0, y: 0, width: tabMenuContainer.frame.width, height: tabMenuContainer.frame.height), pageMenuOptions: parameters)
        //pageMenuController?.tabSelectedDelegateFunc = { self.fab.isHidden = $0 != 0 }
        pageMenuController?.delegate = self
        
        view.addSubview(headerContainer)
        view.addSubview(tabMenuContainer)
        tabMenuContainer.addSubview(pageMenuController!.view)
        view.addSubview(fab)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Knu MiniGroup"
        if let navController = self.navigationController {
            let navBar = navController.navigationBar
            navBar.shadowImage = UIImage()
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.thin)]
            
            // navBar 투명하게 해줌
            navBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            /*if navBarOverlay == nil {
                navBarOverlay = UIView.init(frame: CGRect.init(x: 0, y: 0, width: navBar.bounds.width, height: self.navBarOffset()))
            }
            navBarOverlay!.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
            navBar.subviews.first?.insertSubview(navBarOverlay!, at: 0)
            navBarOverlay!.backgroundColor = navBarColor.withAlphaComponent(0.0)*/
        }
        
        //self.navBarColor = #colorLiteral(red: 0.07159858197, green: 0.09406698495, blue: 0.1027848646, alpha: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let navCtrl = self.navigationController {
            let navBar = navCtrl.navigationBar
            navBar.shadowImage = nil
            navCtrl.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:self.navBarItemsColor.withAlphaComponent(1)]
            
            navBar.setBackgroundImage(nil, for: UIBarMetrics.default)
            //navBarOverlay?.removeFromSuperview()
        }
    }
    
    @IBAction func fabClick(_ sender: UIButton) {
        print("FAB 클릭")
    }
    
    public func updateNavBarAccordingToScrollPosition(minY: CGFloat, maxY: CGFloat, currentY: CGFloat) {
        let alphaOffset: CGFloat = (minY - maxY) * 0.3 // alpha start changing at 1/3 of the way up
        var alpha = (currentY + alphaOffset - minY) / (maxY + alphaOffset - minY)
        
        if currentY > minY - alphaOffset {
            alpha = 0
        }
        
        //self.navBarTransparancy = alpha
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // HeaderedTabScrollViewController
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
    
    func willMoveToPage(_ controller: UIViewController, index: Int) {
        fab.isHidden = index != 0
    }
    
    func headerDidScroll(minY: CGFloat, maxY: CGFloat, currentY: CGFloat) {
        updateNavBarAccordingToScrollPosition(minY: minY, maxY: maxY, currentY: currentY)
        updateHeaderPositionAccordingToScrollPosition(minY: minY, maxY: maxY, currentY: currentY)
        updateHeaderAlphaAccordingToScrollPosition(minY: minY, maxY: maxY, currentY: currentY)
    }
    
    func navBarOffset() -> CGFloat {
        return (self.navigationController?.navigationBar.bounds.height ?? 0) + (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0)
    }
    
    /*open func updateNavBarAccordingToScrollPosition(minY: CGFloat, maxY: CGFloat, currentY: CGFloat) {
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
        
    }*/
    
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
        headerContainer.alpha = currentY > minY - alphaOffset ? 1 : 1 - (currentY + alphaOffset - minY) / (maxY + alphaOffset - minY)
    }
}

public enum TabLayoutOption {
    case selectionIndicatorHeight(CGFloat)
    case menuItemSeparatorWidth(CGFloat)
    case scrollMenuBackgroundColor(UIColor)
    case viewBackgroundColor(UIColor)
    case bottomMenuHairlineColor(UIColor)
    case selectionIndicatorColor(UIColor)
    case menuItemSeparatorColor(UIColor)
    case menuMargin(CGFloat)
    case menuItemMargin(CGFloat)
    case menuHeight(CGFloat)
    case selectedMenuItemLabelColor(UIColor)
    case unselectedMenuItemLabelColor(UIColor)
    case useMenuLikeSegmentedControl(Bool)
    case menuItemSeparatorRoundEdges(Bool)
    case menuItemFont(UIFont)
    case menuItemSeparatorPercentageHeight(CGFloat)
    case menuItemWidth(CGFloat)
    case enableHorizontalBounce(Bool)
    case addBottomMenuHairline(Bool)
    case menuItemWidthBasedOnTitleTextWidth(Bool)
    case titleTextSizeBasedOnMenuItemWidth(Bool)
    case scrollAnimationDurationOnMenuItemTap(Int)
    case centerMenuItems(Bool)
    case hideTopMenuBar(Bool)
}

