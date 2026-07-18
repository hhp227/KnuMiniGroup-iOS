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
        collectionView.contentInsetAdjustmentBehavior = .never

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

        (cell as? MemberCollectionViewCell)?.bind(viewModel.memberItemList[indexPath.row].value)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.memberItemList.count
    }
}

extension Tab3ViewController: UICollectionViewDelegateFlowLayout {
    // Android fragment_tab3: 4열 정사각 사진 + 이름
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize() }
        let margin = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        let side = (collectionView.frame.width - margin - flowLayout.minimumInteritemSpacing * 3) / 4
        return CGSize(width: side, height: side + 18)
    }
}
