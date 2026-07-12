//
//  RequestViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/21.
//  Copyright © 2020 홍희표. All rights reserved.
//
//  가입 신청중인 소모임 (Android의 RequestActivity 대응) — 코드 기반 테이블
//

import UIKit
import Combine

class RequestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let tableView = UITableView()

    private let viewModel = RequestViewModel()

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "가입신청중인 소모임"
        view.backgroundColor = .systemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "requestCell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        observeViewModel()
        viewModel.fetchGroupList()
    }

    private func observeViewModel() {
        viewModel.$groupItemList
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.groupItemList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath)
        let groupItem = viewModel.groupItemList[indexPath.row].value
        var config = cell.defaultContentConfiguration()

        config.text = groupItem.name
        config.secondaryText = groupItem.groupDescription
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entry = viewModel.groupItemList[indexPath.row]
        let groupInfoViewController = GroupInfoViewController(groupItem: entry.value, key: entry.key, buttonType: GroupInfoViewModel.TYPE_CANCEL)

        navigationController?.pushViewController(groupInfoViewController, animated: true)
    }
}
