//
//  ChatViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/06/04.
//  Copyright © 2021 홍희표. All rights reserved.
//
//  그룹 채팅 (Android의 ChatActivity 대응)
//

import UIKit
import Combine

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var toolbarView: UIView!

    var receiver = ""

    var isGroupChat = true

    private var viewModel: ChatViewModel!

    private var cancellables = Set<AnyCancellable>()

    private let tableView = UITableView()

    private let inputTextField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ChatViewModel(receiver: receiver, isGroupChat: isGroupChat)
        title = "채팅"

        setupViews()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler)))
        observeViewModel()
        viewModel.fetchMessageList()
    }

    private func setupViews() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "messageCell")
        view.insertSubview(tableView, belowSubview: toolbarView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor)
        ])
        // 툴바에 입력 필드 추가 (스토리보드 툴바 내 텍스트필드가 아웃렛 연결되어 있지 않아 코드로 구성)
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.placeholder = "메시지를 입력하세요"
        inputTextField.borderStyle = .roundedRect
        toolbarView.addSubview(inputTextField)
        NSLayoutConstraint.activate([
            inputTextField.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 8),
            inputTextField.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            inputTextField.trailingAnchor.constraint(equalTo: toolbarView.trailingAnchor, constant: -72)
        ])
    }

    private func observeViewModel() {
        cancellables.removeAll()
        viewModel.$messageItemList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messageItemList in
                self?.tableView.reloadData()
                if !messageItemList.isEmpty {
                    self?.tableView.scrollToRow(at: IndexPath(row: messageItemList.count - 1, section: 0), at: .bottom, animated: false)
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

    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            toolbarBottomConstraint?.constant = {
                var keyboardHeight = view.bounds.height - endFrame.origin.y

                if keyboardHeight > 0 {
                    keyboardHeight -= view.safeAreaInsets.bottom
                }
                return -(keyboardHeight)
            }()
        }
        view.layoutIfNeeded()
    }

    @objc func tapGestureHandler() {
        view.endEditing(true)
    }

    @IBAction func actionSend(_ sender: UIButton) {
        guard let text = inputTextField.text, !text.isEmpty else {
            return
        }
        viewModel.sendMessage(text: text)
        inputTextField.text = ""
        // 전송 후 목록 갱신 (Android는 ChildEventListener로 실시간 수신 — 최소 구현)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.refreshMessages()
        }
    }

    private func refreshMessages() {
        viewModel = ChatViewModel(receiver: receiver, isGroupChat: isGroupChat)

        observeViewModel()
        viewModel.fetchMessageList()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messageItemList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        let messageItem = viewModel.messageItemList[indexPath.row].value
        let isMine = messageItem.from == PreferenceManager.shared.user?.uid
        var config = cell.defaultContentConfiguration()

        config.text = messageItem.message
        config.secondaryText = isMine ? "나" : messageItem.name
        cell.contentConfiguration = config
        cell.selectionStyle = .none
        return cell
    }
}
