//
//  ArticleViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/03/08.
//  Copyright © 2021 홍희표. All rights reserved.
//
//  게시글 상세 + 댓글 (Android의 ArticleActivity 대응)
//

import UIKit
import Combine

class ArticleViewController: UIViewController {
    @IBOutlet weak var toolbarView: UIView!

    @IBOutlet weak var inputTextView: UITextViewExtension!

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var sendButton: UIButton!

    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!

    private var viewModel: ArticleViewModel!

    private var cancellables = Set<AnyCancellable>()

    private var pendingGroupId = ""

    private var pendingGroupKey = ""

    private var pendingArticleKey = ""

    private var pendingArticleItem: ArticleItem?

    // 게시글 삭제/수정·댓글 수 변경 시 피드 갱신용 (Android의 ArticleActivity 결과 → refresh 대응)
    var onArticleChanged: (() -> Void)?

    // 댓글 추가/삭제 후 성공 응답($replyItemList 갱신)이 오면 피드에 전파하기 위한 플래그
    private var hasReplyChanged = false

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ArticleViewModel(groupId: pendingGroupId, groupKey: pendingGroupKey, articleKey: pendingArticleKey)
        collectionView.delegate = self
        collectionView.dataSource = self
        inputTextView.delegate = self
        inputTextView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.register(ReplyCollectionViewCell.self, forCellWithReuseIdentifier: "replyCell")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler)))
        setupSendButton()
        setupAuthorMenuIfNeeded()
        observeViewModel()
        viewModel.refresh()
    }

    // Android ArticleActivity 옵션 메뉴 대응 — 본인 글이면 우측 상단 더보기(수정하기/삭제하기)
    private func setupAuthorMenuIfNeeded() {
        guard let uid = currentArticleItem?.uid, uid == viewModel.user?.uid else {
            return
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(authorMenuClick))
    }

    @objc private func authorMenuClick() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "수정하기", style: .default) { [weak self] _ in
            self?.editArticle()
        })
        alert.addAction(UIAlertAction(title: "삭제하기", style: .destructive) { [weak self] _ in
            self?.viewModel.removeArticle()
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    // 댓글 수정 — Android UpdateReplyActivity 대응 별도 화면으로 진입
    private func presentEditReply(entry: (key: String, value: ReplyItem)) {
        let updateReplyViewController = UpdateReplyViewController(articleKey: pendingArticleKey, replyKey: entry.key, reply: entry.value.reply ?? "")

        updateReplyViewController.onUpdated = { [weak self] in
            self?.viewModel.fetchReplyList()
        }
        navigationController?.pushViewController(updateReplyViewController, animated: true)
    }

    // Android: CreateArticleActivity에 제목/내용을 실어 수정 모드(type 1)로 진입
    private func editArticle() {
        guard let item = currentArticleItem,
              let writeViewController = storyboard?.instantiateViewController(withIdentifier: "WriteViewController") as? WriteViewController else {
            return
        }
        writeViewController.groupId = pendingGroupId
        writeViewController.groupKey = pendingGroupKey
        writeViewController.articleKey = pendingArticleKey
        writeViewController.contents = [WriteItem.TextItem(item.title ?? "", item.content ?? "")]
        writeViewController.onArticleChanged = { [weak self] in
            self?.viewModel.refresh()
            self?.onArticleChanged?()
        }
        navigationController?.pushViewController(writeViewController, animated: true)
    }

    // 채팅 화면 전송 버튼과 동일 스타일 (UIButton.applySendButtonStyle 공용)
    private func setupSendButton() {
        updateSendButtonState()
    }

    private func updateSendButtonState() {
        let hasText = !(inputTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        sendButton.applySendButtonStyle(hasText: hasText)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func actionSend(_ sender: UIButton) {
        guard let text = inputTextView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        viewModel.addReply(text: text)
        hasReplyChanged = true
        inputTextView.text = ""
        updateSendButtonState()
        view.endEditing(true)
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

    func receiveItem(groupId: String, groupKey: String, articleKey: String, articleItem: ArticleItem) {
        pendingGroupId = groupId
        pendingGroupKey = groupKey
        pendingArticleKey = articleKey
        pendingArticleItem = articleItem
    }

    private func observeViewModel() {
        viewModel.$articleItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        viewModel.$replyItemList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
                // 댓글 추가/삭제 성공으로 갱신된 경우 피드의 댓글 수도 새로고침
                if self?.hasReplyChanged == true {
                    self?.hasReplyChanged = false
                    self?.onArticleChanged?()
                }
            }
            .store(in: &cancellables)
        viewModel.$isArticleRemoved
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRemoved in
                if isRemoved {
                    self?.onArticleChanged?()
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

    private var currentArticleItem: ArticleItem? {
        return viewModel.articleItem ?? pendingArticleItem
    }
}

extension ArticleViewController: UITextViewExtensionDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateSendButtonState()
    }

    private func increaseHeight(textView: UITextViewExtension, willChangeHeight height: CGFloat) {
        self.view.layoutIfNeeded()
    }
}

extension ArticleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 본인 댓글 롱탭 대응 — 선택시 수정/삭제 옵션 (Android의 컨텍스트 메뉴 대응)
        guard indexPath.row > 0 else {
            return
        }
        let entry = viewModel.replyItemList[indexPath.row - 1]

        guard entry.value.uid == viewModel.user?.uid else {
            return
        }
        let alert = UIAlertController(title: "댓글", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.viewModel.removeReply(replyKey: entry.key)
            self?.hasReplyChanged = true
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
}

extension ArticleViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "articleDetailCell", for: indexPath) as? ArticleDetailCollectionViewCell else {
                fatalError()
            }
            if let articleItem = currentArticleItem {
                cell.bind(articleItem)
            }
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "replyCell", for: indexPath) as? ReplyCollectionViewCell else {
            fatalError()
        }
        let entry = viewModel.replyItemList[indexPath.row - 1]

        // 본인 댓글은 스와이프로 수정/삭제 (Android 컨텍스트 메뉴의 댓글 수정/삭제 대응)
        cell.bind(entry.value, isMine: entry.value.uid == viewModel.user?.uid)
        cell.onEditClick = { [weak self] in
            self?.presentEditReply(entry: entry)
        }
        cell.onDeleteClick = { [weak self] in
            self?.viewModel.removeReply(replyKey: entry.key)
            self?.hasReplyChanged = true
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + viewModel.replyItemList.count
    }
}

extension ArticleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize() }
        let width = collectionView.frame.width - (flowLayout.sectionInset.left + flowLayout.sectionInset.right)

        if indexPath.row == 0 {
            guard let item = currentArticleItem else {
                return CGSize(width: width, height: 220)
            }
            // 헤더(12+45) + 본문 + 이미지(16:9) + 패딩 실측 (ArticleDetailCollectionViewCell 레이아웃과 동일 값)
            let contentHeight = heightForText(item.content, font: .systemFont(ofSize: 14), width: width - 32)
            let imageHeight = item.images.first != nil ? (width - 32) * 9 / 16 + 10 : 0
            return CGSize(width: width, height: 12 + 45 + 10 + contentHeight + imageHeight + 12)
        }
        // 댓글: 패딩 8 + 이름 18 + 본문 + 날짜 14 + 패딩 (ReplyCollectionViewCell 레이아웃과 동일 값)
        let reply = viewModel.replyItemList[indexPath.row - 1].value
        let replyHeight = heightForText(reply.reply, font: .systemFont(ofSize: 14), width: width - 69)
        return CGSize(width: width, height: max(61, 8 + 18 + 2 + replyHeight + 2 + 14 + 8))
    }

    private func heightForText(_ text: String?, font: UIFont, width: CGFloat) -> CGFloat {
        guard let text = text, !text.isEmpty else {
            return 0
        }
        let rect = (text as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
        return ceil(rect.height)
    }
}

// Android UpdateReplyActivity 대응 — 댓글 수정 전용 화면 (pbxproj 미수정 방침으로 이 파일에 정의)
class UpdateReplyViewController: UIViewController {
    var onUpdated: (() -> Void)?

    private let viewModel: UpdateReplyViewModel

    private let replyTextView = UITextView()

    private let initialReply: String

    private var cancellables = Set<AnyCancellable>()

    init(articleKey: String, replyKey: String, reply: String) {
        self.viewModel = UpdateReplyViewModel(articleKey: articleKey, replyKey: replyKey)
        self.initialReply = reply
        super.init(nibName: nil, bundle: nil)
        title = "댓글 수정"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // Android menu/write.xml: 우측 상단 "전송"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "전송", style: .plain, target: self, action: #selector(actionSend))
        replyTextView.translatesAutoresizingMaskIntoConstraints = false
        replyTextView.font = .systemFont(ofSize: 16)
        replyTextView.textContainerInset = UIEdgeInsets(top: 10, left: 6, bottom: 10, right: 6)
        replyTextView.text = initialReply
        view.addSubview(replyTextView)
        NSLayoutConstraint.activate([
            replyTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            replyTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            replyTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            replyTextView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
        observeViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        replyTextView.becomeFirstResponder()
    }

    @objc private func actionSend() {
        viewModel.setReply(text: replyTextView.text ?? "")
    }

    private func observeViewModel() {
        viewModel.$updatedReply
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedReply in
                if updatedReply != nil {
                    self?.onUpdated?()
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
