//
//  Tab3ViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/12/03.
//  Copyright © 2020 홍희표. All rights reserved.
//
//  멤버 탭 (Android의 Tab3Fragment 대응)
//

import UIKit
import Combine

class Tab3ViewController: TabViewController, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!

    var groupKey = ""

    private(set) var viewModel: Tab3ViewModel!

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = Tab3ViewModel(groupKey: groupKey)
        collectionView.delegate = self
        collectionView.dataSource = self

        observeViewModel()
        viewModel.fetchUserList()
    }

    private func observeViewModel() {
        viewModel.$memberItemList
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
}

extension Tab3ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.layer.cornerRadius = 10.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 4.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        (cell as? MemberCollectionViewCell)?.bind(viewModel.memberItemList[indexPath.row].value)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.memberItemList.count
    }
}

extension Tab3ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize() }
        let cellCount = floor(CGFloat(4))
        let margin = CGFloat((flowLayout.sectionInset.left + flowLayout.sectionInset.right))
        let width = (view.frame.size.width - margin * (cellCount - 1) - margin) / cellCount
        return CGSize(width: width, height: width)
    }
}
