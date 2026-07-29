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
    static let bannerHeight: CGFloat = 290 // Android LoopViewPager 높이 그대로 — 패딩 없이 꽉 채움

    static let titleHeight: CGFloat = 35 // 타이틀 행

    // Android LoopPagerAdapter 페이지 구성 ["메인", "이미지1", "이미지2"] — 메인은 로고+그룹 찾기/생성 버튼
    private static let bannerPages: [BannerPage] = [.main, .image("banner01"), .image("banner02")]

    private enum BannerPage {
        case main
        case image(String)
    }

    // 메인 페이지 그룹 찾기/생성 버튼 탭 (Android b_find/b_create onClickListener 대응)
    var onFindGroup: (() -> Void)?

    var onCreateGroup: (() -> Void)?

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
        collectionView.register(EmptyGroupBannerCell.self, forCellWithReuseIdentifier: "emptyGroupCell")
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
        // Android LoopViewPager: 높이 290 + 흰 원형 인디케이터 하단 중앙
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = Self.bannerPages.count
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
            bannerCollectionView.topAnchor.constraint(equalTo: topAnchor),
            bannerCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bannerCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bannerCollectionView.heightAnchor.constraint(equalToConstant: 290),
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
            bannerCollectionView.scrollToItem(at: IndexPath(item: Self.bannerPages.count * Self.loopMultiplier / 2, section: 0), at: .centeredHorizontally, animated: false)
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

        guard next < Self.bannerPages.count * Self.loopMultiplier else {
            return
        }
        bannerCollectionView.scrollToItem(at: IndexPath(item: next, section: 0), at: .centeredHorizontally, animated: true)
    }
}

extension MainCollectionReusableView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Self.bannerPages.count * Self.loopMultiplier
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Self.bannerPages[indexPath.item % Self.bannerPages.count] {
        case .main:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyGroupCell", for: indexPath)

            (cell as? EmptyGroupBannerCell)?.onFindGroup = onFindGroup
            (cell as? EmptyGroupBannerCell)?.onCreateGroup = onCreateGroup
            return cell
        case .image(let imageName):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bannerCell", for: indexPath)

            (cell as? BannerCell)?.configure(imageName: imageName)
            return cell
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = currentIndex % Self.bannerPages.count
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

    // Android fragment_main_pager tv_type1/tv_type2 — banner01=우하단 흰색, banner02=좌상단 #FFCC66
    private let bottomTrailingCaptionLabel = UILabel()

    private let topLeadingCaptionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        bottomTrailingCaptionLabel.text = "같은 취향을 가진 사람들과 \n취미생활을 공유하세요."
        bottomTrailingCaptionLabel.textColor = .white
        topLeadingCaptionLabel.text = "동아리, 조별과제 모임을 만들어보세요"
        topLeadingCaptionLabel.textColor = .bannerCaption
        [bottomTrailingCaptionLabel, topLeadingCaptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .boldSystemFont(ofSize: 16)
            $0.numberOfLines = 0
        }
        contentView.addSubview(imageView)
        contentView.addSubview(bottomTrailingCaptionLabel)
        contentView.addSubview(topLeadingCaptionLabel)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            // 반대편 여백은 하한만 — 좁은 화면(320pt)에서 캡션이 잘리는 대신 줄바꿈되도록
            bottomTrailingCaptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
            bottomTrailingCaptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            bottomTrailingCaptionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 25),
            topLeadingCaptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            topLeadingCaptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            topLeadingCaptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -25)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(imageName: String) {
        imageView.image = UIImage(named: imageName)
        bottomTrailingCaptionLabel.isHidden = imageName != "banner01"
        topLeadingCaptionLabel.isHidden = imageName != "banner02"
    }
}

// Android fragment_main_pager rl_type_main 대응 — 로고 + 안내 문구 3줄 + 그룹 찾기/생성 버튼
private class EmptyGroupBannerCell: UICollectionViewCell {
    var onFindGroup: (() -> Void)?

    var onCreateGroup: (() -> Void)?

    private let logoImageView = UIImageView(image: UIImage(named: "knu_minigroup"))

    private let emptyLabel = UILabel()

    private let joinGuideLabel = UILabel()

    private let createGuideLabel = UILabel()

    private let findButton = UIButton(type: .system)

    private let createButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 로고 186×110 + 문구는 중앙 기준, 버튼은 전폭 (Android RelativeLayout 배치 미러)
    private func setupViews() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        emptyLabel.text = "가입한 그룹이 없습니다."
        joinGuideLabel.text = "그룹찾기를 통해 가입하거나"
        createGuideLabel.text = "새로운 모임을 생성하세요."
        [emptyLabel, joinGuideLabel, createGuideLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .black
            contentView.addSubview($0)
        }
        setupDefaultButton(findButton, title: "그룹 찾기", action: #selector(findButtonClick))
        setupDefaultButton(createButton, title: "그룹 생성", action: #selector(createButtonClick))
        contentView.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            joinGuideLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            joinGuideLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emptyLabel.bottomAnchor.constraint(equalTo: joinGuideLabel.topAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: joinGuideLabel.topAnchor, constant: -20),
            logoImageView.widthAnchor.constraint(equalToConstant: 186),
            logoImageView.heightAnchor.constraint(equalToConstant: 110),
            createGuideLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            createGuideLabel.topAnchor.constraint(equalTo: joinGuideLabel.bottomAnchor, constant: 3),
            findButton.topAnchor.constraint(equalTo: createGuideLabel.bottomAnchor, constant: 8),
            findButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            findButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            findButton.heightAnchor.constraint(equalToConstant: 40),
            createButton.topAnchor.constraint(equalTo: findButton.bottomAnchor, constant: 8),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // AppCompat 기본 버튼 대응: 회색 배경 + 검정 텍스트, 눌림 시 #AAAAAA
    private func setupDefaultButton(_ button: UIButton, title: String, action: Selector) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.setBackgroundImage(UIImage(color: .buttonDefaultBg), for: .normal)
        button.setBackgroundImage(UIImage(color: .colorAccent), for: .highlighted)
        button.layer.cornerRadius = 2
        button.clipsToBounds = true
        button.addTarget(self, action: action, for: .touchUpInside)
        contentView.addSubview(button)
    }

    @objc private func findButtonClick() {
        onFindGroup?()
    }

    @objc private func createButtonClick() {
        onCreateGroup?()
    }
}
