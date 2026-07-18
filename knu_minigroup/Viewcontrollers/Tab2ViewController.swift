//
//  Tab2ViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/12/03.
//  Copyright © 2020 홍희표. All rights reserved.
//
//  일정 탭 — 학사일정 (Android의 Tab2Fragment 대응)
//

import UIKit
import Combine

class Tab2ViewController: TabViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    private let viewModel = Tab2ViewModel()

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Tab1과 동일 — 탭 호스트 안에서 자동 인셋이 붙어 캘린더 위에 여백이 생기는 것 방지
        tableView.contentInsetAdjustmentBehavior = .never
        // iOS 15부터 plain 테이블 상단에 기본 패딩이 생겨 캘린더가 아래로 밀림 — 제거
        tableView.sectionHeaderTopPadding = 0

        tableView.register(CalendarTableViewCell.self, forCellReuseIdentifier: "calendarCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "scheduleCell")
        observeViewModel()
    }

    private func observeViewModel() {
        // Android Tab2Fragment처럼 calendar 관찰 → 해당 월 학사일정 요청 (최초 구독 시에도 1회 발화)
        viewModel.$calendar
            .receive(on: DispatchQueue.main)
            .sink { [weak self] calendar in
                self?.viewModel.fetchDataTask(calendar)
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        viewModel.$itemList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
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

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemList.count
    }

    // 첫 행은 캘린더 (Android CalendarAdapter의 TYPE_CALENDAR 대응 — itemList[0]은 빈 placeholder)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath) as? CalendarTableViewCell else {
                fatalError()
            }
            cell.onPrevClick = { [weak self] in
                self?.viewModel.previousMonth()
            }
            cell.onNextClick = { [weak self] in
                self?.viewModel.nextMonth()
            }
            cell.bind(viewModel.calendar)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath)
        let item = viewModel.itemList[indexPath.row]
        var config = cell.defaultContentConfiguration()

        config.text = item["내용"]
        config.secondaryText = item["날짜"]
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Android header_calendar: ExtendedCalendarView 높이 266dp
        return indexPath.row == 0 ? 266 : UITableView.automaticDimension
    }
}

// Android calendar.ExtendedCalendarView 대응 — 월 이동 바 + 요일/날짜 7열 그리드
class CalendarTableViewCell: UITableViewCell {
    var onPrevClick: (() -> Void)?

    var onNextClick: (() -> Void)?

    private let monthLabel = UILabel()

    private let prevButton = UIButton(type: .system)

    private let nextButton = UIButton(type: .system)

    private let gridStackView = UIStackView()

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()

        // Android: "2026 " + getDisplayName(MONTH, LONG) — ko 로케일이면 "2026 7월"
        formatter.dateFormat = "yyyy MMMM"
        return formatter
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        selectionStyle = .none
        // 월 이동 바: 빨간 chevron(ic_navigate_before/next_red_36dp 대응) + 월 라벨 20pt
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        prevButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        prevButton.tintColor = .colorPrimary
        prevButton.addTarget(self, action: #selector(prevButtonTapped), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextButton.tintColor = .colorPrimary
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.font = .systemFont(ofSize: 20)
        monthLabel.textAlignment = .center
        gridStackView.translatesAutoresizingMaskIntoConstraints = false
        gridStackView.axis = .vertical
        gridStackView.distribution = .fillEqually
        gridStackView.spacing = 4
        contentView.addSubview(prevButton)
        contentView.addSubview(monthLabel)
        contentView.addSubview(nextButton)
        contentView.addSubview(gridStackView)
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            monthLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            prevButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            prevButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            prevButton.widthAnchor.constraint(equalToConstant: 36),
            prevButton.heightAnchor.constraint(equalToConstant: 36),
            nextButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            nextButton.widthAnchor.constraint(equalToConstant: 36),
            nextButton.heightAnchor.constraint(equalToConstant: 36),
            gridStackView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 6),
            gridStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            gridStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            gridStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    @objc private func prevButtonTapped() {
        onPrevClick?()
    }

    @objc private func nextButtonTapped() {
        onNextClick?()
    }

    func bind(_ components: DateComponents) {
        guard let year = components.year, let month = components.month else {
            return
        }
        var firstDayComponents = DateComponents()

        firstDayComponents.year = year
        firstDayComponents.month = month
        firstDayComponents.day = 1
        let calendar = Calendar.current

        guard let firstDate = calendar.date(from: firstDayComponents) else {
            return
        }
        let leadingBlankCount = calendar.component(.weekday, from: firstDate) - 1 // 일요일 시작
        let dayCount = calendar.range(of: .day, in: .month, for: firstDate)?.count ?? 30
        let today = calendar.dateComponents([.year, .month, .day], from: Date())

        monthLabel.text = Self.monthFormatter.string(from: firstDate)
        gridStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        gridStackView.addArrangedSubview(makeWeekRow(["일", "월", "화", "수", "목", "금", "토"].map(makeDayOfWeekLabel)))
        var dayCells = (0..<leadingBlankCount).map { _ in makeDayCell(nil, isToday: false) }

        for day in 1...dayCount {
            let isToday = today.year == year && today.month == month && today.day == day

            dayCells.append(makeDayCell(day, isToday: isToday))
        }
        while dayCells.count % 7 != 0 {
            dayCells.append(makeDayCell(nil, isToday: false))
        }
        for weekStart in stride(from: 0, to: dayCells.count, by: 7) {
            gridStackView.addArrangedSubview(makeWeekRow(Array(dayCells[weekStart..<weekStart + 7])))
        }
    }

    private func makeWeekRow(_ views: [UIView]) -> UIStackView {
        let row = UIStackView(arrangedSubviews: views)

        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 4
        return row
    }

    private func makeDayOfWeekLabel(_ text: String) -> UILabel {
        let label = UILabel()

        label.text = text
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }

    // Android calendar_day_view 대응 — 오늘이면 회색(#CBCBCB) 원(calendar_today) 배경
    private func makeDayCell(_ day: Int?, isToday: Bool) -> UIView {
        let container = UIView()
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = day.map(String.init)
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        if isToday {
            label.backgroundColor = UIColor(white: 203/255, alpha: 1) // #CBCBCB
            label.layer.cornerRadius = 14
            label.clipsToBounds = true
        }
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: 28),
            label.heightAnchor.constraint(equalToConstant: 28)
        ])
        return container
    }
}
