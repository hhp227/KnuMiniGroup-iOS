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
        
        // Do any additional setup after loading the view.
        fetchArticleList()
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
    
    func fetchArticleList() {
        data = [ArticleItem.init(auth: false, timestamp: 0, id: "0", uid: "0", name: "hhp227", title: "Hello World", content: "Hello World this is an article", date: "2021.04.20", replyCount: "3", images: [], youtube: nil), ArticleItem.init(auth: false, timestamp: 0, id: "0", uid: "0", name: "test", title: "Second Item", content: "Have a nice day", date: "2021.04.20", replyCount: "2", images: [#imageLiteral(resourceName: "knu_minigroup")], youtube: nil), ArticleItem.init(auth: false, timestamp: 0, id: "0", uid: "0", name: "hhp227", title: "Hello World", content: "Hello world Hello world Hello world Hello world Hello world Hello world Hello world Hello world Hello world \n Hello world \n Hello world \n Hello world \n Hello world", date: "2021.04.20", replyCount: "6", images: [], youtube: nil)]
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "articleCell", for: indexPath) as? ArticleCollectionViewCell else {
            fatalError()
        }
        cell.articleItem = data[indexPath.row]
        
        cell.layoutSubviews()
        cell.cardView()
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
