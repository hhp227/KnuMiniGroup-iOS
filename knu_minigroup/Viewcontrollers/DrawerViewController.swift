//
//  DrawerViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/13.
//  Copyright © 2020 홍희표. All rights reserved.
//
//  네비게이션 드로어 (Android의 activity_main_drawer.xml 대응)
//  ⚠️ 도서관 좌석/통학버스/식단표 화면은 pbxproj 미수정 방침으로 새 파일 대신 이 파일에 정의
//

import UIKit
import Combine

class DrawerViewController: UITableViewController {
    @IBOutlet var drawerTableView: UITableView!

    // Android activity_main_drawer.xml: 메인화면/본관게시판/시간표/도서관 좌석/통학버스 시간표/식단표/로그아웃
    var menus = ["메인화면", "본관게시판", "시간표", "도서관 좌석", "통학버스 시간표", "식단표", "로그아웃"]

    // "chair"는 iOS 16(SF Symbols 4)부터라 iOS 15에선 미표시 — 도서관 좌석은 studentdesk 사용
    var menuIcons = ["house", "doc.text", "clock", "studentdesk", "bus", "fork.knife", "rectangle.portrait.and.arrow.right"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Android DrawerLayout처럼 헤더의 레드 배경이 상태바 뒤 최상단까지 차도록
        tableView.contentInsetAdjustmentBehavior = .never
        // iOS 15가 섹션 헤더 위에 넣는 기본 패딩 제거 — 프로필 헤더 위 흰 띠의 원인
        tableView.sectionHeaderTopPadding = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 로그인 직후에도 프로필 헤더가 현재 사용자로 갱신되도록
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath)

        cell.textLabel?.text = menus[indexPath.row]
        // Android 드로어 아이콘(ic_*_gray_24dp) 대응
        cell.imageView?.image = UIImage(systemName: menuIcons[indexPath.row])
        cell.imageView?.tintColor = .gray
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let drawerController = parent as? DrawerController else { return }

        switch indexPath.row {
        case 0:
            drawerController.mainViewController = storyboard?.instantiateViewController(withIdentifier: "mainNav") as! UINavigationController

            drawerController.setDrawerState(.closed, animated: true)
        case 1:
            drawerController.mainViewController = storyboard?.instantiateViewController(withIdentifier: "univNoticeNav") as! UINavigationController

            drawerController.setDrawerState(.closed, animated: true)
        case 2:
            drawerController.mainViewController = storyboard?.instantiateViewController(withIdentifier: "timetableNav") as! UINavigationController

            drawerController.setDrawerState(.closed, animated: true)
        case 3:
            drawerController.mainViewController = UINavigationController(rootViewController: SeatViewController())

            drawerController.setDrawerState(.closed, animated: true)
        case 4:
            drawerController.mainViewController = UINavigationController(rootViewController: BusViewController())

            drawerController.setDrawerState(.closed, animated: true)
        case 5:
            drawerController.mainViewController = UINavigationController(rootViewController: MealViewController())

            drawerController.setDrawerState(.closed, animated: true)
        case 6:
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            UserDefaults.standard.synchronize()
            navigationController?.popViewController(animated: true)
            dismiss(animated: false, completion: nil)
        default:
            break
        }
    }

    // Android nav_header_main.xml 대응 — colorPrimary 배경 240dp, 하단 정렬: 프로필 75 + 이름(+아이디)
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let avatarImageView = UIImageView()
        let nameLabel = UILabel()
        let idLabel = UILabel()
        let user = PreferenceManager.shared.user

        headerView.backgroundColor = .colorPrimary
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.image = UIImage(named: "user_image_view_circle")
        // Android onProfileImageClick 대응 — 탭하면 프로필 화면으로
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageClick)))
        if let uid = user?.uid {
            avatarImageView.loadImage(EndPoint.USER_IMAGE.replacingOccurrences(of: "{UID}", with: uid), placeholder: UIImage(named: "user_image_view_circle"))
        }
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = user?.name
        nameLabel.font = .systemFont(ofSize: 18) // TextAppearance.AppCompat.Medium
        nameLabel.textColor = .white
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.text = user?.userId
        idLabel.font = .systemFont(ofSize: 14)
        idLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        headerView.addSubview(avatarImageView)
        headerView.addSubview(nameLabel)
        headerView.addSubview(idLabel)
        NSLayoutConstraint.activate([
            // Android: padding 16 + 이미지 marginStart 10
            idLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 26),
            idLabel.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -16),
            idLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 26),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -16),
            nameLabel.bottomAnchor.constraint(equalTo: idLabel.topAnchor, constant: -2),
            avatarImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 26),
            avatarImageView.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 75),
            avatarImageView.heightAnchor.constraint(equalToConstant: 75)
        ])
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 240
    }

    // Android MainActivity.onProfileImageClick 대응 — 드로어 닫고 프로필 화면 push
    @objc private func profileImageClick() {
        guard let drawerController = parent as? DrawerController else {
            return
        }
        (drawerController.mainViewController as? UINavigationController)?.pushViewController(ProfileViewController(), animated: true)
        drawerController.setDrawerState(.closed, animated: true)
    }

}

// MARK: - 드로어 하위 화면 공통 (Android fragment_tabs: Toolbar + TabLayout + ViewPager 대응)

// Android TabLayout 대응 — 레드 배경 + 흰 라벨 + 흰 하단 인디케이터, 탭이 많으면 가로 스크롤
class DrawerSubTabStrip: UIView {
    var onSelect: ((Int) -> Void)?

    private(set) var selectedIndex = 0

    private let scrollView = UIScrollView()

    private let stackView = UIStackView()

    private let indicatorView = UIView()

    private var buttons = [UIButton]()

    init(titles: [String]) {
        super.init(frame: .zero)
        backgroundColor = .colorPrimary
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        indicatorView.backgroundColor = .white
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.addSubview(indicatorView)
        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .system)

            button.setTitle(title, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
        // 탭이 적으면 Android tabMode="fixed"처럼 전체 폭 균등 분할
        if titles.count <= 3 {
            stackView.distribution = .fillEqually
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        }
        updateSelectionAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateIndicatorFrame()
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        select(sender.tag)
        onSelect?(sender.tag)
    }

    func select(_ index: Int) {
        guard index >= 0, index < buttons.count else {
            return
        }
        selectedIndex = index

        updateSelectionAppearance()
        UIView.animate(withDuration: 0.2) {
            self.updateIndicatorFrame()
        }
        scrollView.scrollRectToVisible(buttons[index].frame.insetBy(dx: -16, dy: 0), animated: true)
    }

    private func updateSelectionAppearance() {
        for (index, button) in buttons.enumerated() {
            button.alpha = index == selectedIndex ? 1 : 0.7
        }
    }

    private func updateIndicatorFrame() {
        guard selectedIndex < buttons.count else {
            return
        }
        let buttonFrame = buttons[selectedIndex].frame

        indicatorView.frame = CGRect(x: buttonFrame.minX, y: bounds.height - 2, width: buttonFrame.width, height: 2)
    }
}

// 레드 탭 스트립 + 테이블 구성의 드로어 하위 화면 베이스
class DrawerTabsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView = UITableView(frame: .zero, style: .grouped)

    private(set) var tabStrip: DrawerSubTabStrip!

    private let tabTitles: [String]

    var cancellables = Set<AnyCancellable>()

    init(navTitle: String, tabTitles: [String]) {
        self.tabTitles = tabTitles
        super.init(nibName: nil, bundle: nil)
        title = navTitle
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"), style: .plain, target: self, action: #selector(openDrawer))
        tabStrip = DrawerSubTabStrip(titles: tabTitles)
        tabStrip.translatesAutoresizingMaskIntoConstraints = false
        tabStrip.onSelect = { [weak self] index in
            self?.didSelectTab(index)
        }
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        view.addSubview(tabStrip)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tabStrip.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tabStrip.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabStrip.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabStrip.heightAnchor.constraint(equalToConstant: 44),
            tableView.topAnchor.constraint(equalTo: tabStrip.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        didSelectTab(0)
    }

    @objc private func openDrawer() {
        if let drawerController = navigationController?.parent as? DrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }

    // 서브클래스에서 탭 전환/데이터 로드 처리
    func didSelectTab(_ index: Int) {
    }

    // subtitle 스타일 셀 재사용 (스토리보드 프로토타입 없이 코드로 생성)
    func dequeueSubtitleCell() -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "subtitleCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "subtitleCell")
    }

    func showToastIfNeeded(_ message: String?) {
        if let message = message {
            view.makeToast(message: message)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return dequeueSubtitleCell()
    }
}

// MARK: - 도서관 좌석 (Android의 SeatFragment + Daegu/SangjuSeatFragment 대응)

struct SeatItem {
    let id: Int

    let name: String

    let activeTotal: Int

    let occupied: Int

    let available: Int

    let disable: [String]?
}

// Android의 viewmodel.DaeguSeatViewModel/SangjuSeatViewModel 공통 구현 — 경북대 도서관 좌석 JSON
class LibrarySeatViewModel {
    @Published private(set) var isLoading = false

    @Published private(set) var itemList = [SeatItem]()

    @Published private(set) var message: String?

    private let campusId: String

    init(campusId: String) {
        self.campusId = campusId
    }

    func fetchDataTask() {
        let endPoint = EndPoint.URL_KNULIBRARY_SEAT.replacingOccurrences(of: "{ID}", with: campusId)

        isLoading = true
        HttpClient.request(endPoint) { [weak self] result in
            switch result {
            case .success(let response):
                self?.isLoading = false
                guard let data = response.data(using: .utf8),
                      let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                      let dataObject = json["data"] as? [String: Any],
                      let list = dataObject["list"] as? [[String: Any]] else {
                    self?.message = "좌석 정보를 불러올수 없습니다."
                    return
                }
                self?.itemList = list.map { item in
                    SeatItem(
                        id: item["id"] as? Int ?? 0,
                        name: item["name"] as? String ?? "",
                        activeTotal: item["activeTotal"] as? Int ?? 0,
                        occupied: item["occupied"] as? Int ?? 0,
                        available: item["available"] as? Int ?? 0,
                        disable: (item["disablePeriod"] as? [String: Any]).map {
                            [$0["name"] as? String ?? "", $0["beginTime"] as? String ?? "", $0["endTime"] as? String ?? ""]
                        }
                    )
                }
            case .failure(let error):
                self?.isLoading = false
                self?.message = error.localizedDescription
            }
        }
    }
}

class DaeguSeatViewModel: LibrarySeatViewModel {
    init() {
        super.init(campusId: "1")
    }
}

class SangjuSeatViewModel: LibrarySeatViewModel {
    init() {
        super.init(campusId: "2")
    }
}

class SeatViewController: DrawerTabsViewController {
    private let viewModels: [LibrarySeatViewModel] = [DaeguSeatViewModel(), SangjuSeatViewModel()]

    init() {
        super.init(navTitle: "도서관 좌석", tabTitles: ["대구 열람실", "상주 열람실"])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        for viewModel in viewModels {
            viewModel.$itemList
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.tableView.reloadData()
                }
                .store(in: &cancellables)
            viewModel.$message
                .receive(on: DispatchQueue.main)
                .sink { [weak self] message in
                    self?.showToastIfNeeded(message)
                }
                .store(in: &cancellables)
        }
    }

    override func didSelectTab(_ index: Int) {
        if viewModels[index].itemList.isEmpty {
            viewModels[index].fetchDataTask()
        }
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels[tabStrip.selectedIndex].itemList.count
    }

    // Android seat_item: 열람실명 + (사용중 좌석 [사용/전체] 또는 이용 제한 시간)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueSubtitleCell()
        let item = viewModels[tabStrip.selectedIndex].itemList[indexPath.row]

        cell.selectionStyle = .none
        cell.textLabel?.font = .systemFont(ofSize: 18)
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.font = .systemFont(ofSize: 14)
        cell.detailTextLabel?.textColor = .secondaryLabel
        if let disable = item.disable {
            cell.detailTextLabel?.text = "\(disable[0]) \(disable[1]) ~ \(disable[2])"
        } else {
            cell.detailTextLabel?.text = "사용중 좌석 [\(item.occupied)/\(item.activeTotal)]"
        }
        return cell
    }
}

// MARK: - 통학버스 시간표 (Android의 BusFragment + DC/SCShuttleScheduleFragment 대응)

class BusViewController: DrawerTabsViewController {
    private let dcViewModel = DCShuttleScheduleViewModel()

    private let scViewModel = SCShuttleScheduleViewModel()

    init() {
        super.init(navTitle: "통학버스 시간표", tabTitles: ["학교(대구)", "학교(상주)"])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dcViewModel.$shuttleList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        dcViewModel.$message
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showToastIfNeeded(message)
            }
            .store(in: &cancellables)
        scViewModel.$shuttleList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        scViewModel.$message
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showToastIfNeeded(message)
            }
            .store(in: &cancellables)
    }

    override func didSelectTab(_ index: Int) {
        if index == 0, dcViewModel.shuttleList.isEmpty {
            dcViewModel.fetchShuttleSchedule()
        }
        if index == 1, scViewModel.shuttleList.isEmpty {
            scViewModel.fetchShuttleSchedule()
        }
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tabStrip.selectedIndex == 0 ? dcViewModel.shuttleList.count : scViewModel.shuttleList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueSubtitleCell()

        cell.selectionStyle = .none
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.font = .systemFont(ofSize: 14)
        cell.detailTextLabel?.textColor = .secondaryLabel
        if tabStrip.selectedIndex == 0 {
            // Android shuttle_item: 구분(col1) + 시간(col2)
            let item = dcViewModel.shuttleList[indexPath.row]

            cell.textLabel?.font = item["col2"] == nil ? .boldSystemFont(ofSize: 16) : .systemFont(ofSize: 15)
            cell.textLabel?.text = item["col1"]
            cell.detailTextLabel?.text = item["col2"]
        } else {
            // Android shuttle_sc_item: 회차(col1) + 컬럼별 시간 — 헤더 라벨과 짝지어 표기
            let item = scViewModel.shuttleList[indexPath.row]
            let headers = scViewModel.headers

            cell.textLabel?.font = .boldSystemFont(ofSize: 15)
            cell.textLabel?.text = headers.first.map { "\($0) \(item["col1"] ?? "")" } ?? item["col1"]
            cell.detailTextLabel?.text = (2...7).compactMap { column -> String? in
                guard let value = item["col\(column)"], !value.isEmpty else {
                    return nil
                }
                let label = column - 1 < headers.count ? headers[column - 1] : "col\(column)"

                return "\(label): \(value)"
            }.joined(separator: "\n")
        }
        return cell
    }
}

// MARK: - 식단표 (Android의 MealFragment 대응 — DC/SC 기숙사는 iOS 데이터소스 미구현으로 제외)

class MealViewController: DrawerTabsViewController {
    // Android MealViewModel의 학생식당 페이지 목록과 동일
    private static let studentPages: [(title: String, id: Int)] = [
        ("GP감꽃푸드코트", 46),
        ("GP일청담", 57),
        ("공학관 교직원식당", 85),
        ("공학관 학생식당", 86),
        ("복지관 교직원식당", 36),
        ("복지관 학생식당", 37),
        ("복현회관 교직원식당", 39),
        ("복현회관 학생식당", 56),
        ("정보센터", 35),
        ("상주 학식", 49)
    ]

    private let studentViewModel = StudentMealViewModel()

    private let btlViewModel = BTLDormMealViewModel()

    private var isBTLSelected = false

    init() {
        super.init(navTitle: "식단표", tabTitles: Self.studentPages.map { $0.title } + ["BTL"])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        studentViewModel.$mealList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        studentViewModel.$message
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showToastIfNeeded(message)
            }
            .store(in: &cancellables)
        btlViewModel.$mealList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        btlViewModel.$message
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showToastIfNeeded(message)
            }
            .store(in: &cancellables)
    }

    override func didSelectTab(_ index: Int) {
        isBTLSelected = index == Self.studentPages.count
        if isBTLSelected {
            btlViewModel.fetchMealList()
        } else {
            studentViewModel.fetchMealList(id: Self.studentPages[index].id)
        }
        tableView.reloadData()
    }

    // 아침/점심/저녁 3섹션 (BTL 응답이 3건이 아니면 단일 섹션)
    private var btlHasMealTimeSections: Bool {
        return btlViewModel.mealList.count == 3
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if isBTLSelected {
            return btlHasMealTimeSections ? 3 : 1
        }
        return studentViewModel.mealList.isEmpty ? 0 : 3
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isBTLSelected {
            return btlHasMealTimeSections ? ["아침", "점심", "저녁"][section] : nil
        }
        return ["아침", "점심", "저녁"][section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isBTLSelected {
            return btlHasMealTimeSections ? 1 : btlViewModel.mealList.count
        }
        return sectionMeals(section).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueSubtitleCell()

        cell.selectionStyle = .none
        cell.textLabel?.font = .systemFont(ofSize: 14)
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = nil
        if isBTLSelected {
            cell.textLabel?.text = btlHasMealTimeSections ? btlViewModel.mealList[indexPath.section] : btlViewModel.mealList[indexPath.row]
        } else {
            cell.textLabel?.text = sectionMeals(indexPath.section)[indexPath.row]
        }
        return cell
    }

    private func sectionMeals(_ section: Int) -> [String] {
        let key = [MealRepository.KEY_BREAKFAST, MealRepository.KEY_LAUNCH, MealRepository.KEY_DINNER][section]

        return studentViewModel.mealList.filter { $0.key == key }.map { $0.value }
    }
}

// MARK: - 프로필 (Android의 ProfileActivity 대응 — 조회 전용, 이미지 변경/동기화는 LMS 폐쇄로 미지원)

class ProfileViewController: UIViewController {
    private let scrollView = UIScrollView()

    private let profileImageView = UIImageView()

    private let cardView = UIView()

    private let cardStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "프로필"
        // Android activity_profile: #EEEEEE 배경 + 흰 정보 카드 + 카드 위에 겹치는 프로필 이미지
        view.backgroundColor = .profileBg
        let user = PreferenceManager.shared.user

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .systemBackground
        cardStackView.translatesAutoresizingMaskIntoConstraints = false
        cardStackView.axis = .vertical
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 50
        profileImageView.backgroundColor = .systemGray5
        profileImageView.image = UIImage(named: "user_image_view_circle")
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageClick)))
        if let uid = user?.uid {
            profileImageView.loadImage(EndPoint.USER_IMAGE.replacingOccurrences(of: "{UID}", with: uid), placeholder: UIImage(named: "user_image_view_circle"))
        }
        cardStackView.addArrangedSubview(makeInfoRow(label: "아이디", value: user?.userId))
        cardStackView.addArrangedSubview(makeRowDivider())
        cardStackView.addArrangedSubview(makeInfoRow(label: "접속 IP", value: user?.userIp))
        cardStackView.addArrangedSubview(makeRowDivider())
        cardStackView.addArrangedSubview(makeInfoRow(label: "캠퍼스", value: user?.campus))
        cardStackView.addArrangedSubview(makeCaption("기본 정보"))
        cardStackView.addArrangedSubview(makeInfoRow(label: "이름", value: user?.name))
        cardStackView.addArrangedSubview(makeRowDivider())
        cardStackView.addArrangedSubview(makeInfoRow(label: "소속", value: user?.department))
        cardStackView.addArrangedSubview(makeRowDivider())
        cardStackView.addArrangedSubview(makeInfoRow(label: "학번", value: user?.number))
        cardStackView.addArrangedSubview(makeRowDivider())
        cardStackView.addArrangedSubview(makeInfoRow(label: "학년", value: user?.grade))
        cardStackView.addArrangedSubview(makeCaption("추가 정보"))
        cardStackView.addArrangedSubview(makeInfoRow(label: "이메일", value: user?.email))
        cardStackView.addArrangedSubview(makeRowDivider())
        cardStackView.addArrangedSubview(makeInfoRow(label: "연락처", value: user?.phoneNumber))
        view.addSubview(scrollView)
        scrollView.addSubview(cardView)
        scrollView.addSubview(profileImageView)
        cardView.addSubview(cardStackView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            profileImageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            cardView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 70),
            cardView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            cardStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 60),
            cardStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            cardStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            cardStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
    }

    // Android은 카메라/갤러리 업로드 — LMS 폐쇄로 미지원 (소모임 설정과 동일 방침)
    @objc private func profileImageClick() {
        view.makeToast(message: "이미지 변경은 현재 지원되지 않는 기능입니다.")
    }

    private func makeInfoRow(label: String, value: String?) -> UIView {
        let row = UIView()
        let labelView = UILabel()
        let valueView = UILabel()

        row.translatesAutoresizingMaskIntoConstraints = false
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.font = .systemFont(ofSize: 13)
        labelView.textColor = .secondaryLabel
        labelView.text = label
        valueView.translatesAutoresizingMaskIntoConstraints = false
        valueView.font = .systemFont(ofSize: 14)
        valueView.text = value
        row.addSubview(labelView)
        row.addSubview(valueView)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 35),
            labelView.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            labelView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            labelView.widthAnchor.constraint(equalToConstant: 80),
            valueView.leadingAnchor.constraint(equalTo: labelView.trailingAnchor),
            valueView.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor),
            valueView.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        return row
    }

    private func makeCaption(_ text: String) -> UIView {
        let row = UIView()
        let label = UILabel()

        row.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 14)
        label.text = text
        row.addSubview(label)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 40),
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            label.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -4)
        ])
        return row
    }

    private func makeRowDivider() -> UIView {
        let divider = UIView()

        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .systemGray5
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return divider
    }
}
