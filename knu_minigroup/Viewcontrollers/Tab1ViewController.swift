//
//  Tab1ViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/12/03.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class Tab1ViewController: TabViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // TODO Storyboard로 바꿀것
    @IBOutlet weak var collectionView: UICollectionView!
    
    var data = [ArticleItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        data = [ArticleItem.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal, How to make a portal"), ArticleItem.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal"), ArticleItem.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal"), ArticleItem.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal"), ArticleItem.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal"), ArticleItem.init(image: #imageLiteral(resourceName: "knu_minigroup"), message: "How to make a portal")]
        
        // Do any additional setup after loading the view.
        collectionView.layoutSubviews()
        /*if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: collectionView.frame.width - (flowLayout.sectionInset.left + flowLayout.sectionInset.right), height: 100)
        }*/
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "articleCell", for: indexPath) as? ArticleCollectionViewCell else {
            fatalError()
        }
        cell.mainImage = data[indexPath.row].image
        cell.message = data[indexPath.row].message
        
        cell.layoutSubviews()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "articleCell", for: indexPath) as? ArticleCollectionViewCell

        if segueDelegateFunc != nil {
            segueDelegateFunc!("articleDetail", cell!)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize() }
        return CGSize(width: collectionView.frame.width - (flowLayout.sectionInset.left + flowLayout.sectionInset.right), height: flowLayout.itemSize.height)
    }
}
