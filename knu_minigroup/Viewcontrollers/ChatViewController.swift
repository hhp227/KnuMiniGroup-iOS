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

    @IBOutlet weak var sendButton: UIButton!

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
        // Android activity_chat: 캔버스 #F4FAFF, 말풍선 셀
        view.backgroundColor = .chatCanvas
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .chatCanvas
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60

        tableView.register(ChatMessageTableViewCell.self, forCellReuseIdentifier: "messageCell")
        view.insertSubview(tableView, belowSubview: toolbarView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor)
        ])
        // 툴바에 입력 필드 추가 (스토리보드 툴바 내 텍스트필드가 아웃렛 연결되어 있지 않아 코드로 구성)
        // Android 입력바: borderless EditText, 텍스트 #626262
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.placeholder = "메시지를 입력하세요."
        inputTextField.borderStyle = .none
        inputTextField.textColor = .chatInputText
        inputTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        toolbarView.addSubview(inputTextField)
        NSLayoutConstraint.activate([
            inputTextField.leadingAnchor.constraint(equalTo: toolbarView.leadingAnchor, constant: 10),
            inputTextField.centerYAnchor.constraint(equalTo: toolbarView.centerYAnchor),
            inputTextField.trailingAnchor.constraint(equalTo: toolbarView.trailingAnchor, constant: -72)
        ])
        updateSendButtonState()
    }

    @objc private func textFieldDidChange() {
        updateSendButtonState()
    }

    // 게시글 상세 댓글 전송 버튼과 동일 스타일 (UIButton.applySendButtonStyle 공용)
    private func updateSendButtonState() {
        let hasText = !(inputTextField.text ?? "").isEmpty

        sendButton.applySendButtonStyle(hasText: hasText)
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
        updateSendButtonState()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as? ChatMessageTableViewCell else {
            fatalError()
        }
        let entries = viewModel.messageItemList
        let messageItem = entries[indexPath.row].value
        let isMine = messageItem.from == PreferenceManager.shared.user?.uid
        // Android 규칙: 같은 발신자의 연속 메시지는 이름/아바타 생략 + 상단 여백 축소
        let isContinuation = indexPath.row > 0 && entries[indexPath.row - 1].value.from == messageItem.from

        cell.configure(item: messageItem, isMine: isMine, isContinuation: isContinuation)
        return cell
    }
}

// Android message_item_left/right 대응 말풍선 셀 — 좌우 전환식 단일 클래스
class ChatMessageTableViewCell: UITableViewCell {
    private let avatarImageView = UIImageView()

    private let nameLabel = UILabel()

    private let bubbleView = UIView()

    private let messageLabel = UILabel()

    private let timeLabel = UILabel()

    private var topPaddingConstraint: NSLayoutConstraint!

    private var leftConstraints = [NSLayoutConstraint]()

    private var rightConstraints = [NSLayoutConstraint]()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()

        formatter.dateFormat = "a h:mm"
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
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        // 아바타 41(연속 메시지면 숨김), 이름 13 bold #777777, 말풍선 r3 패딩 9 텍스트 16, 시간 10
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 20.5
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .boldSystemFont(ofSize: 13)
        nameLabel.textColor = .chatSenderName
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.layer.cornerRadius = 3
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.numberOfLines = 0
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 10)
        timeLabel.textColor = .gray
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(bubbleView)
        contentView.addSubview(timeLabel)
        bubbleView.addSubview(messageLabel)
        topPaddingConstraint = nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10)
        NSLayoutConstraint.activate([
            topPaddingConstraint,
            avatarImageView.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            avatarImageView.widthAnchor.constraint(equalToConstant: 41),
            avatarImageView.heightAnchor.constraint(equalToConstant: 41),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            bubbleView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.65),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 9),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 9),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -9),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -9),
            timeLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor)
        ])
        leftConstraints = [
            bubbleView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: 4)
        ]
        rightConstraints = [
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            timeLabel.trailingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: -4)
        ]
        NSLayoutConstraint.activate(leftConstraints)
    }

    func configure(item: MessageItem, isMine: Bool, isContinuation: Bool) {
        messageLabel.text = item.message
        timeLabel.text = item.timestamp > 0 ? Self.timeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(item.timestamp) / 1000)) : nil
        topPaddingConstraint.constant = isContinuation ? 0 : 10
        NSLayoutConstraint.deactivate(leftConstraints + rightConstraints)
        NSLayoutConstraint.activate(isMine ? rightConstraints : leftConstraints)
        if isMine {
            bubbleView.backgroundColor = .bubbleMine
            messageLabel.textColor = .bubbleMineText
            avatarImageView.isHidden = true
            nameLabel.text = nil
        } else {
            bubbleView.backgroundColor = .bubbleOther
            messageLabel.textColor = .bubbleOtherText
            avatarImageView.isHidden = isContinuation
            nameLabel.text = isContinuation ? nil : item.name
            if !isContinuation {
                avatarImageView.loadImage(EndPoint.USER_IMAGE.replacingOccurrences(of: "{UID}", with: item.from ?? ""), placeholder: UIImage(named: "user_image_view_circle"))
            }
        }
    }
}
