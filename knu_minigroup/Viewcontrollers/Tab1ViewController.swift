//
//  Tab1ViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/12/03.
//  Copyright © 2020 홍희표. All rights reserved.
//
//  소모임 게시판 탭 (Android의 Tab1Fragment 대응)
//

import UIKit
import Combine

class Tab1ViewController: TabViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!

    var groupId = ""

    var groupKey = ""

    var data = [ArticleItem]()

    private(set) var viewModel: Tab1ViewModel!

    private var cancellables = Set<AnyCancellable>()

    // FAB(56) + safe area 기준 하단 간격(16) + 마지막 셀과의 여유 간격(16)
    private let bottomContentInset: CGFloat = 88

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = Tab1ViewModel(groupId: groupId, groupKey: groupKey)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInsetAdjustmentBehavior = .never

        addRefreshControl()
        observeViewModel()
        viewModel.fetchNextPage()
    }

    // 마지막 셀의 댓글/공유 버튼이 우측 하단 FAB에 가려지지 않도록 스크롤 여백 확보
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if collectionView.contentInset.bottom != bottomContentInset {
            collectionView.contentInset.bottom = bottomContentInset
            collectionView.verticalScrollIndicatorInsets.bottom = bottomContentInset
        }
    }

    @objc func refreshControlDidChangeValue(refreshControl: UIRefreshControl) {
        viewModel.refresh()
        refreshControl.endRefreshing()
    }

    func addRefreshControl() {
        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action: #selector(refreshControlDidChangeValue), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    func refresh() {
        viewModel.refresh()
    }

    var articleEntries: [(key: String, value: ArticleItem)] {
        return viewModel.articleItemList
    }

    private func observeViewModel() {
        viewModel.$articleItemList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] articleItemList in
                self?.data = articleItemList.map { $0.value }

                self?.collectionView.backgroundView = articleItemList.isEmpty ? self?.makeEmptyStateView() : nil
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

    // Android fragment_tab1 빈 상태: 아이콘 + "등록된 글이 없습니다."
    private func makeEmptyStateView() -> UIView {
        let container = UIView()
        let imageView = UIImageView(image: UIImage(systemName: "plus.square.on.square", withConfiguration: UIImage.SymbolConfiguration(pointSize: 60, weight: .regular)))
        let label = UILabel()

        imageView.tintColor = .colorAccent
        label.text = "등록된 글이 없습니다.\n게시글을 작성하세요."
        label.font = .systemFont(ofSize: 15)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 2

        let stackView = UIStackView(arrangedSubviews: [imageView, label])

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        return container
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "articleCell", for: indexPath) as? ArticleCollectionViewCell else {
            fatalError()
        }
        cell.articleItem = data[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if segueDelegateFunc != nil {
            segueDelegateFunc!("articleDetail", indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 마지막 셀 근처에서 다음 페이지 로드
        if indexPath.row == data.count - 1 && viewModel.hasRequestMore && !viewModel.isLoading {
            viewModel.fetchNextPage()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize() }
        return CGSize(width: collectionView.frame.width - (flowLayout.sectionInset.left + flowLayout.sectionInset.right), height: flowLayout.itemSize.height)
    }
}
