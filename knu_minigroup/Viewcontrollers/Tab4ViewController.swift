//
//  Tab4ViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/12/03.
//  Copyright © 2020 홍희표. All rights reserved.
//
//  설정 탭 — 소모임 폐쇄/탈퇴 (Android의 Tab4Fragment 대응)
//

import UIKit
import Combine

class Tab4ViewController: TabViewController {
    @IBOutlet weak var scrollView: UIScrollView!

    var isAdmin = false

    var groupId = ""

    var groupKey = ""

    private(set) var viewModel: Tab4ViewModel!

    private var cancellables = Set<AnyCancellable>()

    private let deleteButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        viewModel = Tab4ViewModel(isAdmin: isAdmin, groupId: groupId, key: groupKey)

        setupDeleteButton()
        observeViewModel()
    }

    private func setupDeleteButton() {
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle(isAdmin ? "소모임 폐쇄" : "소모임 탈퇴", for: .normal)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        deleteButton.addTarget(self, action: #selector(deleteButtonClick), for: .touchUpInside)
        scrollView.addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            deleteButton.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func deleteButtonClick() {
        let title = isAdmin ? "소모임 폐쇄" : "소모임 탈퇴"
        let alert = UIAlertController(title: title, message: "정말 \(title)하시겠습니까?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteGroup()
        })
        present(alert, animated: true)
    }

    private func observeViewModel() {
        viewModel.$isSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSuccess in
                if isSuccess {
                    self?.navigationController?.popViewController(animated: true)
                }
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
}
