//
//  PopularGroupSectionView.swift
//  knu_minigroup
//
//  가입한 그룹이 없을 때 메인 헤더의 배너 아래에 붙는 인기 모임 섹션 — 코드 기반 UI
//  Android group_grid_header(섹션 타이틀) + group_grid_view_pager(카드 페이저) + group_pager_item(카드) 대응
//

import UIKit

class PopularGroupSectionView: UIView {
    // Android group_grid_header 높이 35 + view_pager paddingTop 10 + ViewPager 높이 200
    static let titleHeight: CGFloat = 35

    static let pagerTopSpacing: CGFloat = 10

    static let pagerHeight: CGFloat = 200

    static var height: CGFloat {
        return titleHeight + pagerTopSpacing + pagerHeight
    }

    // Android ViewPager의 좌우 padding 120px / pageMargin 30px에 대응하는 값 (px → pt)
    private static let peek: CGFloat = 40

    private static let spacing: CGFloat = 10

    // Android group_pager_item CardView의 상하 margin 10 — 카드는 페이저보다 20 낮다
    private static let cardVerticalMargin: CGFloat = 10

    var items = [GroupItem]() {
        didSet {
            collectionView.reloadData()
            collectionView.setContentOffset(.zero, animated: false)
        }
    }

    private let titleLabel = UILabel()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()

        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = PopularGroupSectionView.spacing
        layout.minimumInteritemSpacing = PopularGroupSectionView.spacing
        layout.sectionInset = UIEdgeInsets(top: PopularGroupSectionView.cardVerticalMargin, left: PopularGroupSectionView.peek, bottom: PopularGroupSectionView.cardVerticalMargin, right: PopularGroupSectionView.peek)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false // 카드 그림자가 잘리지 않도록
        collectionView.decelerationRate = .fast
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PopularGroupCell.self, forCellWithReuseIdentifier: "popularGroupCell")
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // Android group_grid_header: 높이 35, bold 16, colorPrimary, marginStart 15
    private func setupViews() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "인기 모임"
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .colorPrimary
        addSubview(titleLabel)
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            titleLabel.heightAnchor.constraint(equalToConstant: Self.titleHeight),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Self.pagerTopSpacing),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: Self.pagerHeight)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        let itemSize = CGSize(width: max(0, bounds.width - Self.peek * 2), height: Self.pagerHeight - Self.cardVerticalMargin * 2)

        if layout.itemSize != itemSize {
            layout.itemSize = itemSize
            layout.invalidateLayout()
        }
    }

    // 좌우 여백이 있는 페이저는 isPagingEnabled를 쓸 수 없어 감속 지점을 카드 단위로 직접 맞춘다
    private var pageWidth: CGFloat {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return 0
        }
        return layout.itemSize.width + Self.spacing
    }
}

extension PopularGroupSectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "popularGroupCell", for: indexPath)

        (cell as? PopularGroupCell)?.bind(items[indexPath.item])
        return cell
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard pageWidth > 0, !items.isEmpty else {
            return
        }
        let page = (targetContentOffset.pointee.x / pageWidth).rounded()

        targetContentOffset.pointee.x = min(max(0, page), CGFloat(items.count - 1)) * pageWidth
    }
}

// Android group_pager_item: 커버 꽉 채움 + 하단 그라데이션 + 흰색 굵은 이름 (좌하단)
private class PopularGroupCell: UICollectionViewCell {
    private let groupImageView = UIImageView()

    private let gradientLayer = CAGradientLayer()

    private let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        groupImageView.translatesAutoresizingMaskIntoConstraints = false
        groupImageView.contentMode = .scaleAspectFill
        groupImageView.clipsToBounds = true
        groupImageView.backgroundColor = .profileBg
        // bg_gradient_group: 위 절반은 투명, 아래로 갈수록 #80000000
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.5).cgColor]
        gradientLayer.locations = [0, 0.5, 1]
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .boldSystemFont(ofSize: 20)
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 1
        contentView.addSubview(groupImageView)
        contentView.layer.addSublayer(gradientLayer)
        contentView.addSubview(nameLabel)
        // CardView cardCornerRadius 4 + elevation 3 — 모서리는 contentView가, 그림자는 셀이 그린다
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 3
        NSLayoutConstraint.activate([
            groupImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            groupImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            groupImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            groupImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // CALayer는 오토레이아웃을 타지 않으므로 프레임을 직접 맞춘다.
        // 암시적 애니메이션을 끄지 않으면 셀 재사용 때 그라데이션이 밀려 들어오는 게 보인다.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = contentView.bounds
        CATransaction.commit()
    }

    func bind(_ groupItem: GroupItem) {
        nameLabel.text = groupItem.name
        groupImageView.loadImage(groupItem.image, placeholder: UIImage(named: "knu_minigroup"))
    }
}
