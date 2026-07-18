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
        cell.bind(viewModel.replyItemList[indexPath.row - 1].value)
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
