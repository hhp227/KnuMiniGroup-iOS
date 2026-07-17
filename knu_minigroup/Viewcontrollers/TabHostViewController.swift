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

    // Android CollapsingToolbarLayout의 contentScrim(?attr/colorPrimary) 대응 — 완전히 접히면 불투명해진다
    private let scrimView = UIView()

    var headerTopConstraint: NSLayoutConstraint?

    var tabTopConstraint: NSLayoutConstraint?

    private var lastTabScrollViewOffset: CGPoint = .zero

    // Android fragment_tab_host_layout: CollapsingToolbarLayout 200dp 안에 TabLayout(48pt, gravity=bottom)이
    // 겹쳐 들어가 있는 구조와 동일하게, 헤더 자체의 펼침 높이는 200 - 48(탭 바 높이) = 152로 잡는다.
    // 탭 바는 별도로 얹히는 게 아니라 이 152 바로 아래에서 시작해 총합이 200이 되도록 한다.
    public let headerHeight: CGFloat = 152
    
    public var headerBackgroundColor: UIColor? {
        get {
            return headerContainer.backgroundColor
        }
        set(value) {
            headerContainer.backgroundColor = value
        }
    }
    
    //private var navBarOverlay: UIView?
    
    public var pageMenuController: TabLayout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Android fragment_tab_host_layout: 레드 TabLayout, 흰 라벨, 인디케이터 colorAccent
        let parameters: [TabLayoutOption] = [
            .scrollMenuBackgroundColor(.colorPrimary),
            // 빨간색은 탭 바에만 사용한다. 페이지 크기가 갱신되는 레이아웃 경계에서
            // 컨테이너 배경이 잠시 노출되더라도 빨간 띠로 보이지 않게 한다.
            .viewBackgroundColor(.systemBackground),
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
                array[i].pushDelegateFunc = { [weak self] in
                    self?.navigationController?.pushViewController($0, animated: true)
                }
                array[i].settledScrollDelegateFunc = { [weak self] _ in
                    self?.snapHeaderIfNeeded()
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
        lastTabScrollViewOffset = CGPoint(x: CGFloat(0), y: navBarOffset())
        tabMenuContainer.frame = CGRect(x: 0, y: headerHeight, width: view.frame.width, height: view.frame.height - navBarOffset())
        tabMenuContainer.translatesAutoresizingMaskIntoConstraints = false
        tabMenuContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tabMenuContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tabTopConstraint = tabMenuContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: headerHeight)
        tabTopConstraint!.isActive = true
        // 헤더가 접히며 top이 바뀌어도 컨테이너의 하단은 항상 화면 끝에 붙인다.
        // 높이를 초기 nav/status bar 값으로 계산하면 첫 레이아웃 시점의 safe area 값과 달라져
        // 접힌 상태에서 루트 뷰의 빨간 배경이 하단에 노출될 수 있다.
        tabMenuContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        // 헤더 하단을 tabMenuContainer 상단에 직접 고정 — 별도 height 제약을 스크롤마다 수동으로
        // 맞추는 대신 Auto Layout이 둘을 항상 정확히 맞닿게 보장하므로 그 사이로 red 배경이 드러날 수 없다.
        headerContainer.bottomAnchor.constraint(equalTo: tabMenuContainer.topAnchor).isActive = true
        
        // 탭 레이아웃 추가
        pageMenuController = TabLayout(viewControllers: controllers, frame: CGRect(x: 0, y: 0, width: tabMenuContainer.frame.width, height: tabMenuContainer.frame.height), pageMenuOptions: parameters)
        pageMenuController?.delegate = self
        
        view.addSubview(headerContainer)
        view.addSubview(tabMenuContainer)
        addChild(pageMenuController!)
        tabMenuContainer.addSubview(pageMenuController!.view)
        pageMenuController!.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageMenuController!.view.topAnchor.constraint(equalTo: tabMenuContainer.topAnchor),
            pageMenuController!.view.leadingAnchor.constraint(equalTo: tabMenuContainer.leadingAnchor),
            pageMenuController!.view.trailingAnchor.constraint(equalTo: tabMenuContainer.trailingAnchor),
            pageMenuController!.view.bottomAnchor.constraint(equalTo: tabMenuContainer.bottomAnchor)
        ])
        pageMenuController!.didMove(toParent: self)
        view.addSubview(fab)
        setupHeaderContent()
        setupFab()
    }

    // Android TabHostLayoutFragment: 그룹 이미지가 있으면 사진+그라데이션을 보여주고 로고를 숨기고,
    // 없으면(share_nophoto) 사진 없이 로고만 보여주고 그라데이션은 숨긴다 (headerContainer 자체가 이미 colorPrimary라 별도 배경 불필요)
    private func setupHeaderContent() {
        let hasGroupImage = groupImage.map { !$0.isEmpty && !$0.contains("share_nophoto") } ?? false

        headerContainer.clipsToBounds = true
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        headerContainer.addSubview(headerImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.isHidden = hasGroupImage
        headerContainer.addSubview(logoImageView)
        // Android bg_gradient(angle 270): 상단 50% 블랙 → 중앙 투명 → 하단 25% 블랙. 로고 위에 얹혀야 하므로 addSubview(logoImageView) 다음에 추가
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.25).cgColor]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.isHidden = !hasGroupImage
        headerContainer.layer.addSublayer(gradientLayer)
        if hasGroupImage {
            headerImageView.loadImage(groupImage)
        }
        // contentScrim: 평소 투명, 완전히 접히면 불투명 red로 덮여 헤더가 접힌 툴바처럼 보인다 (이미지 유무와 무관하게 항상 동작)
        scrimView.translatesAutoresizingMaskIntoConstraints = false
        scrimView.backgroundColor = .colorPrimary
        scrimView.alpha = 0
        scrimView.isUserInteractionEnabled = false
        headerContainer.addSubview(scrimView)
        NSLayoutConstraint.activate([
            headerImageView.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            headerImageView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 170),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            scrimView.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            scrimView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            scrimView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            scrimView.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor)
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
        // 탭 컨테이너는 top/bottom 제약에 따라 헤더 접힘만큼 높이가 변한다.
        // 수동 프레임 기반인 각 탭 페이지도 실제 컨테이너 크기에 맞춰 갱신한다.
        let tabSize = tabMenuContainer.bounds.size

        if tabSize.width > 0, tabSize.height > 0 {
            pageMenuController?.resize(to: tabSize)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 헤더 위에 얹히도록 이 화면에서만 네비바 투명 (iOS 15 appearance 방식)
        if let navBar = navigationController?.navigationBar {
            let transparent = UINavigationBarAppearance()

            transparent.configureWithTransparentBackground()
            // Android CollapsingToolbarLayout처럼 헤더가 펼쳐진 동안엔 타이틀을 숨기고(로고와 중복 방지) 완전히 접혔을 때만 페이드인
            transparent.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0)]
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
    
    // Android CollapsingToolbarLayout의 타이틀 페이드인: 접히는 마지막 구간에서만 흰 타이틀이 나타난다
    public func updateNavBarAccordingToScrollPosition(minY: CGFloat, maxY: CGFloat, currentY: CGFloat) {
        let alphaOffset: CGFloat = (minY - maxY) * 0.3 // alpha start changing at 1/3 of the way up
        var alpha = (currentY + alphaOffset - minY) / (maxY + alphaOffset - minY)

        if currentY > minY - alphaOffset {
            alpha = 0
        }

        setNavbarTitleTransparency(alpha: alpha)
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
        var didMoveHeader = false
        
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
            didMoveHeader = true
        }
        
        //we expand the top view
        if delta < 0 {
            if tabTopConstraint!.constant < minY && scrollView.contentOffset.y < 0 {
                if tabTopConstraint!.constant - delta > minY {
                    delta = tabTopConstraint!.constant - minY
                }
                tabTopConstraint!.constant -= delta
                scrollView.contentOffset.y -= delta
                didMoveHeader = true
            }
        }

        // top 제약만 먼저 바뀌고 내부 페이지의 수동 프레임 갱신이 다음 프레임으로
        // 밀리면, 접힘 방향에서 늘어난 컨테이너 하단이 배경색으로 노출된다.
        // 같은 스크롤 이벤트 안에서 제약과 탭 페이지 크기를 함께 반영한다.
        if didMoveHeader {
            view.layoutIfNeeded()
        }
        
        lastTabScrollViewOffset = scrollView.contentOffset

        if pageMenuController?.currentPageIndex == 0 {
            updateFeedFabVisibility(for: scrollView)
        }
        
        headerDidScroll(minY: minY, maxY: maxY, currentY: tabTopConstraint!.constant)
    }
    
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        guard index == 0, let tab1 = controller as? Tab1ViewController else {
            fab.isHidden = true
            return
        }

        updateFeedFabVisibility(for: tab1.collectionView)
    }

    // 고정 contentInset으로 FAB 공간을 만들면 마지막 아이템 뒤에 흰 여백이 생긴다.
    // 대신 현재 보이는 게시글의 액션 버튼과 FAB가 실제로 겹치는 동안에만 FAB를 숨긴다.
    private func updateFeedFabVisibility(for scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else {
            fab.isHidden = false
            return
        }

        let fabCollisionFrame = fab.frame.insetBy(dx: -4, dy: -4)
        fab.isHidden = collectionView.visibleCells
            .compactMap { $0 as? ArticleCollectionViewCell }
            .contains { cell in
                let shareFrame = cell.shareButton.convert(cell.shareButton.bounds, to: view)
                let replyFrame = cell.replyButton.convert(cell.replyButton.bounds, to: view)

                return fabCollisionFrame.intersects(shareFrame) || fabCollisionFrame.intersects(replyFrame)
            }
    }
    
    // 헤더 height는 headerContainer.bottomAnchor == tabMenuContainer.topAnchor 제약으로 Auto Layout이
    // tabTopConstraint 변화에 맞춰 자동으로 따라오므로, 여기서는 알파/타이틀 페이드만 처리하면 된다.
    func headerDidScroll(minY: CGFloat, maxY: CGFloat, currentY: CGFloat) {
        updateNavBarAccordingToScrollPosition(minY: minY, maxY: maxY, currentY: currentY)
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
    
    // Android contentScrim 페이드인: 헤더 자체를 투명하게 지우면 뒤의 red 배경이 드러나므로
    // scrimView를 위에 덧씌우는 방식으로 처리한다 (headerContainer는 항상 완전 불투명 유지)
    open func updateHeaderAlphaAccordingToScrollPosition(minY: CGFloat, maxY: CGFloat, currentY: CGFloat) {
        let alphaOffset: CGFloat = (minY - maxY) * 0.3 // alpha start changing at 1/3 of the way up
        let headerAlpha = currentY > minY - alphaOffset ? 1 : 1 - (currentY + alphaOffset - minY) / (maxY + alphaOffset - minY)

        scrimView.alpha = 1 - headerAlpha
    }

    // Android layout_scrollFlags의 "snap": 손을 뗐을 때 반쯤 접힌 상태로 멈추지 않고
    // 가까운 쪽(완전히 펼침/완전히 접힘)으로 애니메이션한다
    private func snapHeaderIfNeeded() {
        guard let constraint = tabTopConstraint else {
            return
        }
        let minY = headerHeight
        let maxY = navBarOffset()

        guard constraint.constant > maxY, constraint.constant < minY else {
            return
        }
        let target: CGFloat = (constraint.constant - maxY) < (minY - constraint.constant) ? maxY : minY

        UIView.animate(withDuration: 0.25) {
            constraint.constant = target
            self.headerDidScroll(minY: minY, maxY: maxY, currentY: target)
            self.view.layoutIfNeeded()
        }
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
