//
//  MainCollectionReusableView.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/23.
//  Copyright © 2020 홍희표. All rights reserved.
//
//  메인 그리드 섹션 헤더 — 코드 기반 UI
//  Android group_grid_view_pager(배너 무한 루프 캐러셀) + group_grid_header(섹션 타이틀) 대응
//

import UIKit

class MainCollectionReusableView: UICollectionReusableView {
    static let bannerHeight: CGFloat = 290 // 배너 270 + 상하 패딩 10

    static let titleHeight: CGFloat = 35 // 타이틀 행

    private static let bannerImages = ["banner01", "banner02"]

    // 배너는 가입중인 그룹이 없을 때만 표시, 있을 때는 섹션 타이틀만 표시
    var showsBanner = true {
        didSet {
            bannerCollectionView.isHidden = !showsBanner
            pageControl.isHidden = !showsBanner
            headerLabel.isHidden = showsBanner
            showsBanner && window != nil ? startTimer() : stopTimer()
        }
    }

    private static let loopMultiplier = 100

    let headerLabel = UILabel()

    private lazy var bannerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()

        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BannerCell.self, forCellWithReuseIdentifier: "bannerCell")
        return collectionView
    }()

    private let pageControl = UIPageControl()

    private var timer: Timer?

    private var didSetInitialOffset = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        // Android LoopViewPager: 높이 290·패딩 10 + 흰 원형 인디케이터 하단 중앙
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = Self.bannerImages.count
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.5)
        pageControl.isUserInteractionEnabled = false
        // Android group_grid_header: 높이 35, bold 16, colorPrimary, marginStart 15
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = .boldSystemFont(ofSize: 16)
        headerLabel.textColor = .colorPrimary
        addSubview(bannerCollectionView)
        addSubview(pageControl)
        addSubview(headerLabel)
        NSLayoutConstraint.activate([
            bannerCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            bannerCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bannerCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bannerCollectionView.heightAnchor.constraint(equalToConstant: 270),
            pageControl.centerXAnchor.constraint(equalTo: bannerCollectionView.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bannerCollectionView.bottomAnchor, constant: -4),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = bannerCollectionView.bounds.size

        guard size.width > 0, let layout = bannerCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        if layout.itemSize != size {
            layout.itemSize = size
            layout.invalidateLayout()
        }
        // 무한 루프: 중앙 인덱스에서 시작
        if !didSetInitialOffset {
            didSetInitialOffset = true
            bannerCollectionView.layoutIfNeeded()
            bannerCollectionView.scrollToItem(at: IndexPath(item: Self.bannerImages.count * Self.loopMultiplier / 2, section: 0), at: .centeredHorizontally, animated: false)
        }
    }

    // 화면 표시 중에만 5초 자동 슬라이드 (재사용/화면 이탈 시 타이머 정리)
    override func didMoveToWindow() {
        super.didMoveToWindow()
        window == nil || !showsBanner ? stopTimer() : startTimer()
    }

    private func startTimer() {
        guard timer == nil else {
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.advance()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private var currentIndex: Int {
        let width = bannerCollectionView.bounds.width

        return width > 0 ? Int(round(bannerCollectionView.contentOffset.x / width)) : 0
    }

    private func advance() {
        let next = currentIndex + 1

        guard next < Self.bannerImages.count * Self.loopMultiplier else {
            return
        }
        bannerCollectionView.scrollToItem(at: IndexPath(item: next, section: 0), at: .centeredHorizontally, animated: true)
    }
}

extension MainCollectionReusableView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Self.bannerImages.count * Self.loopMultiplier
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bannerCell", for: indexPath)

        (cell as? BannerCell)?.imageView.image = UIImage(named: Self.bannerImages[indexPath.item % Self.bannerImages.count])
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = currentIndex % Self.bannerImages.count
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startTimer()
    }
}

private class BannerCell: UICollectionViewCell {
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
