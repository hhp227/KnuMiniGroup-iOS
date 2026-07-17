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
    
    let tabsTexts = ["소식", "일정", "맴버", "설정"]

    var groupId = ""

    var groupKey = ""

    var groupName = ""

    var groupImage: String?

    var isAdmin = false

    private let headerImageView = UIImageView()

    private let logoImageView = UIImageView(image: UIImage(named: "knu_sotong"))

    private let gradientLayer = CAGradientLayer()

    var headerHeightConstraint: NSLayoutConstraint?
    
    var headerTopConstraint: NSLayoutConstraint?
    
    var tabTopConstraint: NSLayoutConstraint?

    var tabHeightConstraint: NSLayoutConstraint?

    private var lastTabScrollViewOffset: CGPoint = .zero

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
    
    //private var navBarOverlay: UIView?
    
    public var pageMenuController: TabLayout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Android fragment_tab_host_layout: 레드 TabLayout, 흰 라벨, 인디케이터 colorAccent
        let parameters: [TabLayoutOption] = [
            .scrollMenuBackgroundColor(.colorPrimary),
            .viewBackgroundColor(.colorPrimary),
            .bottomMenuHairlineColor(UIColor(red: 20.0 / 255.0, green: 20.0 / 255.0, blue: 20.0 / 255.0, alpha: 0.1)),
            .selectionIndicatorColor(.colorAccent),
            .menuMargin(0.0),
            .menuHeight(48.0),
            .selectedMenuItemLabelColor(.white),
            .unselectedMenuItemLabelColor(.white),
            .useMenuLikeSegmentedControl(true),
            .selectionIndicatorHeight(2.0),
            .menuItemFont(UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.medium)),
            .menuItemWidthBasedOnTitleTextWidth(false)
        ]
        let controllers: [TabViewController] = {
            let array = [
                storyboard?.instantiateViewController(withIdentifier: "Tab1ViewController") as! TabViewController,
                storyboard?.instantiateViewController(withIdentifier: "Tab2ViewController") as! TabViewController,
                storyboard?.instantiateViewController(withIdentifier: "Tab3ViewController") as! TabViewController,
                storyboard?.instantiateViewController(withIdentifier: "Tab4ViewController") as! TabViewController
            ]
            
            if let tab1 = array[0] as? Tab1ViewController {
                tab1.groupId = groupId
                tab1.groupKey = groupKey
            }
            if let tab3 = array[2] as? Tab3ViewController {
                tab3.groupKey = groupKey
            }
            if let tab4 = array[3] as? Tab4ViewController {
                tab4.isAdmin = isAdmin
                tab4.groupId = groupId
                tab4.groupKey = groupKey
            }
            for i in array.indices {
                array[i].scrollDelegateFunc = pleaseScroll
                array[i].segueDelegateFunc = {
                    self.performSegue(withIdentifier: $0, sender: $1)
                }
                array[i].title = tabsTexts[i]
            }
            return array
        }()
        title = groupName
        headerBackgroundColor = .colorPrimary
        //self.navBarTransparancy = 0
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
        tabHeightConstraint = tabMenuContainer.heightAnchor.constraint(equalToConstant: view.frame.height - navBarOffset())
        tabHeightConstraint!.isActive = true
        
        // 탭 레이아웃 추가
        pageMenuController = TabLayout(viewControllers: controllers, frame: CGRect(x: 0, y: 0, width: tabMenuContainer.frame.width, height: tabMenuContainer.frame.height), pageMenuOptions: parameters)
        pageMenuController?.delegate = self
        
        view.addSubview(headerContainer)
        view.addSubview(tabMenuContainer)
        tabMenuContainer.addSubview(pageMenuController!.view)
        view.addSubview(fab)
        setupHeaderContent()
        setupFab()
    }

    // Android CollapsingToolbarLayout 헤더: 그룹 이미지 + 중앙 knu_sotong 로고 + bg_gradient 스크림
    private func setupHeaderContent() {
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        if let groupImage = groupImage, !groupImage.isEmpty {
            headerImageView.loadImage(groupImage)
        }
        headerContainer.addSubview(headerImageView)
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.25).cgColor]
        gradientLayer.locations = [0, 0.5, 1]
        headerContainer.layer.addSublayer(gradientLayer)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        headerContainer.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            headerImageView.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            headerImageView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 170),
            logoImageView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    // Android FAB: colorAccent 배경 + 흰 plus + 은은한 그림자, 소식 탭에서만 표시
    private func setupFab() {
        fab.tintColor = .colorAccent
        fab.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold))?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        fab.layer.shadowColor = UIColor.black.cgColor
        fab.layer.shadowOffset = CGSize(width: 0, height: 2)
        fab.layer.shadowRadius = 3
        fab.layer.shadowOpacity = 0.3
        fab.isHidden = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = headerContainer.bounds
        // viewDidLoad 시점에는 window가 없어 navBarOffset()이 상태바 높이를 0으로 계산한다.
        // 실제 값으로 보정하지 않으면 탭 컨테이너 하단이 화면 밖으로 밀려 피드 마지막 셀이 잘린다.
        let tabHeight = view.frame.height - navBarOffset()

        if view.window != nil, let constraint = tabHeightConstraint, constraint.constant != tabHeight {
            constraint.constant = tabHeight
            pageMenuController?.resize(to: CGSize(width: view.frame.width, height: tabHeight))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 헤더 위에 얹히도록 이 화면에서만 네비바 투명 (iOS 15 appearance 방식)
        if let navBar = navigationController?.navigationBar {
            let transparent = UINavigationBarAppearance()

            transparent.configureWithTransparentBackground()
            transparent.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBar.standardAppearance = transparent
            navBar.scrollEdgeAppearance = transparent
            navBar.compactAppearance = transparent
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 전역(레드 opaque) appearance 복원
        if let navBar = navigationController?.navigationBar {
            navBar.standardAppearance = UINavigationBar.appearance().standardAppearance
            navBar.scrollEdgeAppearance = UINavigationBar.appearance().scrollEdgeAppearance
            navBar.compactAppearance = UINavigationBar.appearance().compactAppearance
        }
    }
    
    public func updateNavBarAccordingToScrollPosition(minY: CGFloat, maxY: CGFloat, currentY: CGFloat) {
        let alphaOffset: CGFloat = (minY - maxY) * 0.3 // alpha start changing at 1/3 of the way up
        var alpha = (currentY + alphaOffset - minY) / (maxY + alphaOffset - minY)
        
        if currentY > minY - alphaOffset {
            alpha = 0
        }
        
        //self.navBarTransparancy = alpha
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "articleDetail" {
            if let tab1ViewController = pageMenuController?.controllerArray[0] as? Tab1ViewController,
               let indexPath = sender as? IndexPath {
                let entry = tab1ViewController.articleEntries[indexPath.row]

                (segue.destination as? ArticleViewController)?.receiveItem(groupId: groupId, groupKey: groupKey, articleKey: entry.key, articleItem: entry.value)
            }
        } else if let writeViewController = segue.destination as? WriteViewController {
            writeViewController.groupId = groupId
            writeViewController.groupKey = groupKey
        } else if let chatViewController = segue.destination as? ChatViewController {
            chatViewController.receiver = groupKey
            chatViewController.isGroupChat = true
        }
    }

    public func setNavBarRightItems(items: [UIBarButtonItem]) {
        navigationItem.rightBarButtonItems = items
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    public func setNavbarTitleTransparency(alpha: CGFloat) {
        if let navBar = navigationController?.navigationBar {
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(alpha)]

            navBar.standardAppearance.titleTextAttributes = attributes
            navBar.scrollEdgeAppearance?.titleTextAttributes = attributes
            navBar.compactAppearance?.titleTextAttributes = attributes
        }
    }
    
    public func setNavBarLeftItems(items: [UIBarButtonItem]) {
        navigationItem.leftBarButtonItems = items
        navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    public func pleaseScroll(_ scrollView: UIScrollView) {
        var delta = scrollView.contentOffset.y - lastTabScrollViewOffset.y
        
        // Vertical bounds
        let maxY: CGFloat = navBarOffset()
        let minY: CGFloat = headerHeight
        
        guard tabTopConstraint != nil else {
            return
        }
        //if tabTopConstraint == nil { return }
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
    
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        fab.isHidden = index != 0
    }
    
    func headerDidScroll(minY: CGFloat, maxY: CGFloat, currentY: CGFloat) {
        updateNavBarAccordingToScrollPosition(minY: minY, maxY: maxY, currentY: currentY)
        updateHeaderPositionAccordingToScrollPosition(minY: minY, maxY: maxY, currentY: currentY)
        updateHeaderAlphaAccordingToScrollPosition(minY: minY, maxY: maxY, currentY: currentY)
    }
    
    func navBarOffset() -> CGFloat {
        return (navigationController?.navigationBar.bounds.height ?? 0) + (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0)
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

