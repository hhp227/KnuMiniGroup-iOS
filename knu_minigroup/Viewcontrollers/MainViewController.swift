//
//  MainController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/08/30.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit
import Combine

class MainViewController: UIViewController, UITabBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet var tabBar: UITabBar!

    @IBOutlet var findTabBarItem: UITabBarItem!

    @IBOutlet var requestTabBarItem: UITabBarItem!

    @IBOutlet var createTabBarItem: UITabBarItem!

    @IBOutlet var collectionView: UICollectionView!

    var estimateWidth = 160.0

    var cellMarginSize = 16.0

    private let viewModel = MainViewModel()

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self

        setupTabBar()
        setupCollectionView()
        collectionView.register(MainCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "GroupCollectionViewHeader")
        addRefreshControl()
        observeViewModel()
        viewModel.fetchGroupList()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchGroupList()
    }

    @IBAction func barButtonItemClick(_ sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parent as? DrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }

    @objc func refreshControlDidChangeValue(refreshControl: UIRefreshControl) {
        viewModel.fetchGroupList()
        refreshControl.endRefreshing()
    }

    // Android fragment_group_main: 2열 그리드, 가로 간격 14, 세로 간격 10
    func setupCollectionView() {
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = 14
        flow.minimumLineSpacing = 10
        flow.sectionInset = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
    }

    // Android BottomNavigationView 스타일: 흰 배경, 회색 아이템(선택 시 colorPrimary)
    private func setupTabBar() {
        let tabAppearance = UITabBarAppearance()

        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = .white
        // 라벨은 appearance 파이프라인으로만 조정 가능(실기기 확인) — 기본 10pt → 12pt
        let titleFont = UIFont.systemFont(ofSize: 12)

        [tabAppearance.stackedLayoutAppearance, tabAppearance.inlineLayoutAppearance, tabAppearance.compactInlineLayoutAppearance].forEach {
            $0.normal.iconColor = .gray
            $0.normal.titleTextAttributes = [.foregroundColor: UIColor.gray, .font: titleFont]
            $0.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10)
            $0.selected.iconColor = .colorPrimary
            $0.selected.titleTextAttributes = [.foregroundColor: UIColor.colorPrimary, .font: titleFont]
            $0.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -10)
        }
        tabBar.standardAppearance = tabAppearance
        tabBar.scrollEdgeAppearance = tabAppearance
        // 탭바가 아이콘 이미지를 항상 중앙에 고정하므로, 이미지 하단에 투명 여백을 구워 넣어
        // 보이는 글리프만 위로 올린다 (인셋/appearance API와 무관하게 확실히 동작)
        // 심볼 스케일 한 단계 업(.large) — Android itemIconSize 36dp 대응
        tabBar.items?.forEach {
            let enlarged = $0.image?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large)) ?? $0.image

            $0.image = raisedImage(enlarged, by: 4)
        }
    }

    // 글리프를 offset만큼 올린 이미지 생성 — 캔버스를 아래로 offset*2 늘리고 원본을 상단에 그린다
    private func raisedImage(_ image: UIImage?, by offset: CGFloat) -> UIImage? {
        guard let image = image else {
            return nil
        }
        let format = UIGraphicsImageRendererFormat()

        format.scale = image.scale
        let size = CGSize(width: image.size.width, height: image.size.height + offset * 2)
        let raised = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(at: .zero)
        }

        return raised.withRenderingMode(.alwaysTemplate)
    }

    func addRefreshControl() {
        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action: #selector(refreshControlDidChangeValue), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    private func observeViewModel() {
        viewModel.$groupItemList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        viewModel.$message
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message = message {
                    self?.view.makeToast(message: message)
                }
            }
            .store(in: &cancellables)
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item {
        case findTabBarItem:
            performSegue(withIdentifier: "findGroup", sender: item)
        case requestTabBarItem:
            performSegue(withIdentifier: "requestJoin", sender: item)
        case createTabBarItem:
            performSegue(withIdentifier: "createGroup", sender: item)
        default:
            break
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.groupItemList.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let entry = viewModel.groupItemList[indexPath.row]

        guard let tabHostViewController = storyboard?.instantiateViewController(withIdentifier: "TabHostViewController") as? TabHostViewController else {
            return
        }
        tabHostViewController.groupId = entry.value.id ?? ""
        tabHostViewController.groupKey = entry.key
        tabHostViewController.groupName = entry.value.name ?? ""
        tabHostViewController.groupImage = entry.value.image
        tabHostViewController.isAdmin = entry.value.authorUid == viewModel.user?.uid
        navigationController?.pushViewController(tabHostViewController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        (cell as? MainCollectionViewCell)?.bind(viewModel.groupItemList[indexPath.row].value)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "GroupCollectionViewHeader", for: indexPath) as? MainCollectionReusableView
        header?.headerLabel.text = "가입중인 그룹"
        header?.showsBanner = viewModel.showsEmptyBanner
        header?.onFindGroup = { [weak self] in
            self?.performSegue(withIdentifier: "findGroup", sender: nil)
        }
        header?.onCreateGroup = { [weak self] in
            self?.performSegue(withIdentifier: "createGroup", sender: nil)
        }
        return header!
    }

    // Android group_grid_item: 이미지 100 + 타이틀 영역 65 = 높이 165, 2열
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 14 * 3) / 2
        return CGSize(width: width, height: 165)
    }

    // 배너는 로딩 완료 후 가입중인 그룹이 없다고 확정된 경우에만 노출 — 최초 로딩 중에는 헤더를 그리지 않는다 (Android 대응)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height = !viewModel.groupItemList.isEmpty ? MainCollectionReusableView.titleHeight
            : viewModel.showsEmptyBanner ? MainCollectionReusableView.bannerHeight : 0
        return CGSize(width: collectionView.frame.width, height: height)
    }
}

// 메인 하단 내비 전용 탭바 — iOS 15에서 UITabBarAppearance가 설정되면 per-item imageInsets가
// 무시되어 아이콘을 움직일 수 없으므로, 버튼 자체를 transform으로 올려 63pt 바의 하단(표준
// 49pt 슬롯)에 붙는 콘텐츠를 수직 중앙으로 이동시킨다 (Android BottomNavigationView 대응)
class MainTabBar: UITabBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        let shift = max(0, (bounds.height - 49) / 2)

        for case let button as UIControl in subviews {
            button.transform = CGAffineTransform(translationX: 0, y: -shift)
        }
    }
}
