//
//  TimetableViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/03/28.
//  Copyright © 2021 홍희표. All rights reserved.
//
//  시간표 (Android의 TimetableFragment 대응) — 학기시간표 / 모의시간표 작성 탭
//

import UIKit
import Combine

class TimetableViewController: UIViewController {
    private let semesterViewModel = SemesterTimeTableViewModel()

    private let mockViewModel = MockTimeTableViewModel()

    private var cancellables = Set<AnyCancellable>()

    private var tabStrip: DrawerSubTabStrip!

    private let scrollView = UIScrollView()

    private let cardView = UIView()

    private let gridStackView = UIStackView()

    // Android MockTimeTableViewModel의 dayLine/timeLine
    private let dayLine = ["시간", "월", "화", "수", "목", "금"]

    private let timeLine = ["1교시\n09:00", "2교시\n10:00", "3교시\n11:00", "4교시\n12:00", "5교시\n13:00", "6교시\n14:00", "7교시\n15:00", "8교시\n16:00", "9교시\n17:00", "10교시\n18:00"]

    // Android TimetableView 셀 색상
    private static let dayCellColor = UIColor(red: 250/255, green: 244/255, blue: 192/255, alpha: 1) // #FAF4C0

    private static let timeCellColor = UIColor(white: 234/255, alpha: 1) // #EAEAEA

    override func viewDidLoad() {
        super.viewDidLoad()
        // Android fragment_mock_timetable: #EEEEEE 배경 + 카드 안 그리드
        view.backgroundColor = .profileBg
        tabStrip = DrawerSubTabStrip(titles: ["학기시간표", "모의시간표 작성"])
        tabStrip.translatesAutoresizingMaskIntoConstraints = false
        tabStrip.onSelect = { [weak self] index in
            self?.didSelectTab(index)
        }
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 4
        cardView.clipsToBounds = true
        gridStackView.translatesAutoresizingMaskIntoConstraints = false
        gridStackView.axis = .vertical
        gridStackView.spacing = 1
        view.addSubview(tabStrip)
        view.addSubview(scrollView)
        scrollView.addSubview(cardView)
        cardView.addSubview(gridStackView)
        NSLayoutConstraint.activate([
            tabStrip.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tabStrip.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabStrip.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabStrip.heightAnchor.constraint(equalToConstant: 44),
            scrollView.topAnchor.constraint(equalTo: tabStrip.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cardView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 10),
            cardView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 10),
            cardView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -10),
            cardView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -10),
            gridStackView.topAnchor.constraint(equalTo: cardView.topAnchor),
            gridStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            gridStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            gridStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
        observeViewModel()
        didSelectTab(0)
    }

    @IBAction func barButtonItemClick(_ sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parent as? DrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }

    private func observeViewModel() {
        semesterViewModel.$table
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.tabStrip.selectedIndex == 0 {
                    self?.rebuildSemesterGrid()
                }
            }
            .store(in: &cancellables)
        mockViewModel.$timetableList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.tabStrip.selectedIndex == 1 {
                    self?.rebuildMockGrid()
                }
            }
            .store(in: &cancellables)
        semesterViewModel.$message
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message = message {
                    self?.view.makeToast(message: message)
                }
            }
            .store(in: &cancellables)
        mockViewModel.$message
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let message = message {
                    self?.view.makeToast(message: message)
                }
            }
            .store(in: &cancellables)
    }

    private func didSelectTab(_ index: Int) {
        if index == 0 {
            rebuildSemesterGrid()
            if semesterViewModel.table.isEmpty {
                semesterViewModel.fetchSemesterTimetableList()
            }
        } else {
            rebuildMockGrid()
            mockViewModel.fetchTimetableList()
        }
    }

    // MARK: - 학기시간표 (Android SemesterTimetableView 대응 — LMS 파싱 결과 [[String]] 렌더링)

    private func rebuildSemesterGrid() {
        gridStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let table = semesterViewModel.table

        guard !table.isEmpty else {
            gridStackView.addArrangedSubview(makeCell(text: "학기시간표를 불러올수 없습니다.", color: .systemBackground, height: 60))
            return
        }
        for (rowIndex, row) in table.enumerated() {
            let rowStackView = makeRowStackView()

            for text in row {
                rowStackView.addArrangedSubview(makeCell(text: text, color: rowIndex == 0 ? Self.dayCellColor : Self.timeCellColor, height: 55))
            }
            gridStackView.addArrangedSubview(rowStackView)
        }
    }

    // MARK: - 모의시간표 (Android TimetableView 대응 — 6열×10교시, 셀 탭으로 입력/수정/삭제)

    private func rebuildMockGrid() {
        gridStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let headerRowStackView = makeRowStackView()

        for day in dayLine {
            headerRowStackView.addArrangedSubview(makeCell(text: day, color: Self.dayCellColor, height: 40))
        }
        gridStackView.addArrangedSubview(headerRowStackView)
        var cellId = 0

        for time in timeLine {
            let rowStackView = makeRowStackView()

            rowStackView.addArrangedSubview(makeCell(text: time, color: Self.timeCellColor, height: 55))
            for _ in 1..<dayLine.count {
                let item = mockViewModel.timetableList.first { $0.id == cellId }
                let button = UIButton(type: .system)

                button.setTitle(item.map { "\($0.subject)\n\($0.classroom)" }, for: .normal)
                button.setTitleColor(.label, for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 11)
                button.titleLabel?.numberOfLines = 2
                button.titleLabel?.textAlignment = .center
                button.backgroundColor = Self.timeCellColor
                button.tag = cellId
                button.heightAnchor.constraint(equalToConstant: 55).isActive = true
                button.addTarget(self, action: #selector(mockCellTapped(_:)), for: .touchUpInside)
                rowStackView.addArrangedSubview(button)
                cellId += 1
            }
            gridStackView.addArrangedSubview(rowStackView)
        }
    }

    // Android timetable_input_dig: 강의명/강의실 입력 다이얼로그 (기존 항목이면 삭제 제공)
    @objc private func mockCellTapped(_ sender: UIButton) {
        let cellId = sender.tag
        let existingItem = mockViewModel.timetableList.first { $0.id == cellId }
        let alert = UIAlertController(title: "시간표 입력", message: nil, preferredStyle: .alert)

        alert.addTextField {
            $0.placeholder = "강의명을 입력하세요."
            $0.text = existingItem?.subject
        }
        alert.addTextField {
            $0.placeholder = "강의실을 입력하세요."
            $0.text = existingItem?.classroom
        }
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self, weak alert] _ in
            guard let subject = alert?.textFields?[0].text, !subject.isEmpty else {
                self?.view.makeToast(message: "강의명을 입력하세요.")
                return
            }
            let classroom = alert?.textFields?[1].text ?? ""

            if existingItem != nil {
                self?.mockViewModel.updateTimetable(id: cellId, subject: subject, classroom: classroom)
            } else {
                self?.mockViewModel.addTimetable(id: cellId, subject: subject, classroom: classroom)
            }
        })
        if existingItem != nil {
            alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
                self?.mockViewModel.deleteTimetable(id: cellId)
            })
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - 그리드 공통

    private func makeRowStackView() -> UIStackView {
        let rowStackView = UIStackView()

        rowStackView.axis = .horizontal
        rowStackView.distribution = .fillEqually
        rowStackView.spacing = 1
        return rowStackView
    }

    private func makeCell(text: String?, color: UIColor, height: CGFloat) -> UILabel {
        let label = UILabel()

        label.text = text
        label.font = .systemFont(ofSize: 11)
        label.textAlignment = .center
        label.numberOfLines = 3
        label.backgroundColor = color
        label.heightAnchor.constraint(equalToConstant: height).isActive = true
        return label
    }
}
