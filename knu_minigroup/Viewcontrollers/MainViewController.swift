//
//  MainController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/08/30.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITabBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet var tabBar: UITabBar!
    
    @IBOutlet var findTabBarItem: UITabBarItem!
    
    @IBOutlet var requestTabBarItem: UITabBarItem!
    
    @IBOutlet var createTabBarItem: UITabBarItem!
    
    @IBOutlet var collectionView: UICollectionView!
    
    var estimateWidth = 160.0
    
    var cellMarginSize = 16.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.reloadData()
        setupCollectionView()
        addRefreshControl()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCollectionView()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func barButtonItemClick(_ sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parent as? DrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
    @objc func refreshControlDidChangeValue(refreshControl: UIRefreshControl) {
        collectionView.reloadData()
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
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
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
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width / 3 - 0, height: collectionView.bounds.size.height / 3 - 0)
    }*/
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        cell.cardView()
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
