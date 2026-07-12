//
//  UnivNoticeViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/13.
//  Copyright © 2020 홍희표. All rights reserved.
//
//  경북대 공지사항 (Android의 UnivNoticeFragment 대응) — 코드 기반 테이블
//

import UIKit
import Combine

class UnivNoticeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let tableView = UITableView()

    private let viewModel = UnivNoticeViewModel()

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "noticeCell")
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        observeViewModel()
        viewModel.fetchNextPage()
    }

    @IBAction func barButtonItemClick(_ sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parent as? DrawerController {
            drawerController.setDrawerState(.opened, animated: true)
        }
    }

    private func observeViewModel() {
        viewModel.$noticeList
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
        return viewModel.noticeList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath)
        let item = viewModel.noticeList[indexPath.row]
        var config = cell.defaultContentConfiguration()

        config.text = item["제목"]
        config.secondaryText = [item["작성자"], item["날짜"]].compactMap { $0 }.joined(separator: " · ")
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let link = viewModel.noticeList[indexPath.row]["링크"], let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.noticeList.count - 1 && !viewModel.isLoading {
            viewModel.fetchNextPage()
        }
    }
}
