//
//  MainController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/08/30.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITabBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet var mTabBar: UITabBar!
    @IBOutlet var mFindTabBarItem: UITabBarItem!
    @IBOutlet var mRequestTabBarItem: UITabBarItem!
    @IBOutlet var mCreateTabBarItem: UITabBarItem!
    @IBOutlet var mCollectionView: UICollectionView!
    var estimateWidth = 160.0
    var cellMarginSize = 16.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mTabBar.delegate = self
        mCollectionView.delegate = self
        mCollectionView.dataSource = self
        
        mCollectionView.reloadData()
        setupCollectionView()
    }
    
    @IBAction func barButtonItemClick(_ sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parent as? DrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
    func setupCollectionView() {
        let flow = mCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(cellMarginSize)
        flow.minimumLineSpacing = CGFloat(cellMarginSize)
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item {
        case mFindTabBarItem:
            let findViewController = storyboard?.instantiateViewController(withIdentifier: "FindViewController") as! FindViewController
            
            navigationController?.pushViewController(findViewController, animated: true)
        case mRequestTabBarItem:
            let requestViewController = storyboard?.instantiateViewController(withIdentifier: "RequestViewController") as! RequestViewController
            
            navigationController?.pushViewController(requestViewController, animated: true)
        case mCreateTabBarItem:
            let createViewController = storyboard?.instantiateViewController(withIdentifier: "CreateViewController") as! CreateViewController
            
            navigationController?.pushViewController(createViewController, animated: true)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width / 3 - 0, height: collectionView.bounds.size.height / 3 - 0)
    }*/
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "GroupCollectionViewHeader", for: indexPath) as? MainCollectionReusableView
        header?.headerLabel.text = "가입중인 그룹"
        return header!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWidth()
        return CGSize(width: width, height: width)
    }
    
    func calculateWidth() -> CGFloat {
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        return width
    }
}
