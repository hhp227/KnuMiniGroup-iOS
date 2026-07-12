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

        setupCollectionView()
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

    func setupCollectionView() {
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(cellMarginSize)
        flow.minimumLineSpacing = CGFloat(cellMarginSize)
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellCount = floor(CGFloat(view.frame.size.width / CGFloat(estimateWidth)))
        let margin = CGFloat(cellMarginSize * 2)
        let width = (view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        return CGSize(width: width, height: width)
    }
}
