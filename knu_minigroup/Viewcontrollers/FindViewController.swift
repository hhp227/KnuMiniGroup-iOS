//
//  FindViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/20.
//  Copyright © 2020 홍희표. All rights reserved.
//
//  소모임 찾기 (Android의 FindGroupActivity 대응)
//

import UIKit
import Combine

class FindViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    private let viewModel = FindGroupViewModel()

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 104

        addRefreshControl()
        observeViewModel()
        viewModel.fetchNextPage()
    }

    @objc func refreshControlDidChangeValue(refreshControl: UIRefreshControl) {
        viewModel.refresh()
        refreshControl.endRefreshing()
    }

    func addRefreshControl() {
        let refreshControl = UIRefreshControl()

        refreshControl.addTarget(self, action: #selector(refreshControlDidChangeValue), for: .valueChanged)
        tableView.refreshControl = refreshControl
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as? GroupTableViewCell else {
            fatalError()
        }
        cell.bind(viewModel.groupItemList[indexPath.row].value)
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.groupItemList.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let entry = viewModel.groupItemList[indexPath.row]
        let isJoinedOrRequested = entry.value.members?[PreferenceManager.shared.user?.uid ?? ""] != nil
        let groupInfoViewController = GroupInfoViewController(groupItem: entry.value, key: entry.key, buttonType: isJoinedOrRequested ? GroupInfoViewModel.TYPE_CANCEL : GroupInfoViewModel.TYPE_REQUEST)

        groupInfoViewController.onRequestSent = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        groupInfoViewController.onRequestCanceled = { [weak self] in
            self?.viewModel.refresh()
        }
        present(groupInfoViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.groupItemList.count - 1 && viewModel.hasRequestMore && !viewModel.isLoading {
            viewModel.fetchNextPage()
        }
    }
}
