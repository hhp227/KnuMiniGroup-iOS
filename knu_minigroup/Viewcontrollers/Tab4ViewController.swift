//
//  Tab4ViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/12/03.
//  Copyright © 2020 홍희표. All rights reserved.
//
//  설정 탭 — 사용자 설정/소모임 설정/어플리케이션 정보 (Android의 Tab4Fragment + content_tab4 대응)
//

import UIKit
import MessageUI
import StoreKit
import Combine

class Tab4ViewController: TabViewController {
    @IBOutlet weak var scrollView: UIScrollView!

    var isAdmin = false

    var groupId = ""

    var groupKey = ""

    private(set) var viewModel: Tab4ViewModel!

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        viewModel = Tab4ViewModel(isAdmin: isAdmin, groupId: groupId, key: groupKey)

        setupSettingsList()
        observeViewModel()
    }

    // Android content_tab4 카드: 사용자 설정 / 소모임 설정 / 어플리케이션 정보 3섹션
    private func setupSettingsList() {
        let card = UIView()
        let stackView = UIStackView()

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .secondarySystemGroupedBackground
        // Android content_tab4 CardView(cornerRadius 4dp, elevation) 상당 — 그림자 테두리 (cardView() 확장과 동일 값)
        card.layer.cornerRadius = 4
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        card.layer.shadowRadius = 2.0
        card.layer.shadowOpacity = 0.24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        card.addSubview(stackView)
        scrollView.addSubview(card)

        stackView.addArrangedSubview(sectionCaption("사용자 설정"))
        stackView.addArrangedSubview(divider(height: 5))
        stackView.addArrangedSubview(profileRow())

        stackView.addArrangedSubview(sectionCaption("소모임 설정", topPadding: 20))
        stackView.addArrangedSubview(divider(height: 5))
        stackView.addArrangedSubview(actionRow(title: isAdmin ? "소모임 폐쇄" : "소모임 탈퇴", titleColor: .systemRed, action: #selector(deleteButtonClick)))
        if isAdmin {
            stackView.addArrangedSubview(divider(height: 2))
            stackView.addArrangedSubview(actionRow(title: "설정", action: #selector(groupSettingsClick)))
        }

        stackView.addArrangedSubview(sectionCaption("어플리케이션 정보", topPadding: 20))
        stackView.addArrangedSubview(divider(height: 5))
        stackView.addArrangedSubview(actionRow(title: "공지사항", action: #selector(noticeClick)))
        stackView.addArrangedSubview(divider(height: 2))
        stackView.addArrangedSubview(actionRow(title: "버그 리포트", action: #selector(feedbackClick)))
        stackView.addArrangedSubview(divider(height: 2))
        stackView.addArrangedSubview(actionRow(title: "평점주기", action: #selector(rateAppClick)))
        stackView.addArrangedSubview(divider(height: 2))
        stackView.addArrangedSubview(actionRow(title: "공유하기", action: #selector(shareClick)))
        stackView.addArrangedSubview(divider(height: 2))
        stackView.addArrangedSubview(actionRow(title: "버전 정보", action: #selector(versionInfoClick)))

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 10),
            card.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 10),
            card.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -10),
            card.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
    }

    private func sectionCaption(_ text: String, topPadding: CGFloat = 0) -> UIView {
        let label = UILabel()
        let container = UIView()

        label.text = text
        label.font = .boldSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -15),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: topPadding),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5)
        ])
        return container
    }

    // Android content_tab4 구분선: 좌우 10dp 마진
    private func divider(height: CGFloat) -> UIView {
        let container = UIView()
        let line = UIView()

        container.translatesAutoresizingMaskIntoConstraints = false
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = .systemGray4
        container.addSubview(line)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: height),
            line.topAnchor.constraint(equalTo: container.topAnchor),
            line.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            line.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            line.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10)
        ])
        return container
    }

    // Android ll_profile: 아바타 45 + 이름/아이디, 탭하면 프로필 화면으로
    private func profileRow() -> UIView {
        let avatarImageView = UIImageView()
        let nameLabel = UILabel()
        let idLabel = UILabel()
        let textStack = UIStackView(arrangedSubviews: [nameLabel, idLabel])
        let row = UIView()

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 22.5
        avatarImageView.backgroundColor = .profileBg
        avatarImageView.image = UIImage(named: "profile_img_square")
        if let uid = viewModel.user?.uid {
            avatarImageView.loadImage(EndPoint.USER_IMAGE.replacingOccurrences(of: "{UID}", with: uid))
        }
        nameLabel.text = viewModel.user?.name
        nameLabel.font = .boldSystemFont(ofSize: 15)
        idLabel.text = viewModel.user?.userId
        idLabel.font = .systemFont(ofSize: 13)
        idLabel.textColor = .textTimestamp
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 50).isActive = true // Android ll_profile 50dp
        row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileRowClick)))
        row.addSubview(avatarImageView)
        row.addSubview(textStack)
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 15),
            avatarImageView.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 45),
            avatarImageView.heightAnchor.constraint(equalToConstant: 45),
            textStack.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor, constant: -15),
            textStack.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        return row
    }

    private func actionRow(title: String, titleColor: UIColor = .label, action: Selector) -> UIView {
        let button = UIButton(type: .system)

        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.contentHorizontalAlignment = .leading
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func profileRowClick() {
        pushDelegateFunc?(ProfileViewController())
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

    // LMS 서버 폐쇄로 소모임 수정 기능은 iOS에서 아직 지원하지 않음 (CreateGroupViewModel의 이미지 업로드와 동일한 방침)
    @objc private func groupSettingsClick() {
        view.makeToast(message: "현재 지원되지 않는 기능입니다.")
    }

    @objc private func noticeClick() {
        pushDelegateFunc?(UnivNoticeViewController())
    }

    @objc private func feedbackClick() {
        guard MFMailComposeViewController.canSendMail() else {
            view.makeToast(message: "메일을 보낼 수 없습니다.")
            return
        }
        let mail = MFMailComposeViewController()
        let content = "작성자: \(viewModel.user?.name ?? "")\n기기 모델: \(UIDevice.current.model)\niOS 버전: \(UIDevice.current.systemVersion)\n앱 버전: \(appVersion)\n내용: "

        mail.mailComposeDelegate = self
        mail.setToRecipients(["hong227@naver.com"])
        mail.setSubject("경북대소모임 건의사항")
        mail.setMessageBody(content, isHTML: false)
        present(mail, animated: true)
    }

    @objc private func rateAppClick() {
        guard let scene = view.window?.windowScene else {
            return
        }
        SKStoreReviewController.requestReview(in: scene)
    }

    @objc private func shareClick() {
        let activityViewController = UIActivityViewController(activityItems: ["경북대 소모임 앱을 확인해보세요!"], applicationActivities: nil)

        present(activityViewController, animated: true)
    }

    @objc private func versionInfoClick() {
        let alert = UIAlertController(title: "버전 정보", message: appVersion, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private var appVersion: String {
        let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

        return "\(shortVersion) (\(buildVersion))"
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

extension Tab4ViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
