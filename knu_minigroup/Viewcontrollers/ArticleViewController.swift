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
        observeViewModel()
        viewModel.refresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func actionSend(_ sender: UIButton) {
        guard let text = inputTextView.text else {
            return
        }
        viewModel.addReply(text: text)
        inputTextView.text = ""
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
            }
            .store(in: &cancellables)
        viewModel.$isArticleRemoved
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRemoved in
                if isRemoved {
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

        return CGSize(width: width, height: indexPath.row == 0 ? max(flowLayout.itemSize.height, 220) : 76)
    }
}
