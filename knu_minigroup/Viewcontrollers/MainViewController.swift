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
        [tabAppearance.stackedLayoutAppearance, tabAppearance.inlineLayoutAppearance, tabAppearance.compactInlineLayoutAppearance].forEach {
            $0.normal.iconColor = .gray
            $0.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
            $0.selected.iconColor = .colorPrimary
            $0.selected.titleTextAttributes = [.foregroundColor: UIColor.colorPrimary]
        }
        tabBar.standardAppearance = tabAppearance
        tabBar.scrollEdgeAppearance = tabAppearance
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
        return header!
    }

    // Android group_grid_item: 이미지 100 + 타이틀 영역 65 = 높이 165, 2열
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 14 * 3) / 2
        return CGSize(width: width, height: 165)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: MainCollectionReusableView.height)
    }
}
