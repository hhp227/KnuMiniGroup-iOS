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

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "calendarCell")
        observeViewModel()
        viewModel.fetchDataTask()
    }

    private func observeViewModel() {
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

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let year = viewModel.calendar.year, let month = viewModel.calendar.month else {
            return nil
        }
        return String(format: "%d년 %d월 학사일정", year, month)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath)
        let item = viewModel.itemList[indexPath.row]
        var config = cell.defaultContentConfiguration()

        config.text = item["내용"]
        config.secondaryText = item["날짜"]
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        return cell
    }
}
