//
//  GroupInfoViewController.swift
//  knu_minigroup
//
//  소모임 정보 + 가입 신청/취소 (Android의 GroupInfoFragment 대응) — 코드 기반 UI
//

import UIKit
import Combine

class GroupInfoViewController: UIViewController {
    private let viewModel: GroupInfoViewModel

    private var cancellables = Set<AnyCancellable>()

    private let groupImageView = UIImageView()

    private let nameOverlayView = UIView()

    private let nameLabel = UILabel()

    private let infoLabel = UILabel()

    private let descriptionLabel = UILabel()

    private let requestButton = UIButton(type: .system)

    private let closeButton = UIButton(type: .system)

    private let scrollView = UIScrollView()

    // 가입 신청 성공 시 호출 — 호스트가 메인 복귀 처리 (Android TYPE_REQUEST 대응)
    var onRequestSent: (() -> Void)?

    // 신청 취소 성공 시 호출 — 호스트 목록 갱신 (Android RequestActivity.refresh() 대응)
    var onRequestCanceled: (() -> Void)?

    init(groupItem: GroupItem, key: String, buttonType: Int) {
        self.viewModel = GroupInfoViewModel(groupItem: groupItem, key: key, buttonType: buttonType)
        super.init(nibName: nil, bundle: nil)
        // Android DialogFragment 대응 — 하프시트로 시작, 위로 끌면 확장
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = viewModel.groupItem.name

        setupViews()
        observeViewModel()
    }

    // Android fragment_group_info: 이미지 200 + 하단 반투명 이름 오버레이 + 설명(16)/정보(13) +
    // 구분선 + [가입신청|닫기] 반반 버튼 바
    // 시트에서는 본문만 스크롤, 버튼 바는 하단 고정 — medium 디텐트에서도 버튼이 항상 보이게
    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        groupImageView.translatesAutoresizingMaskIntoConstraints = false
        groupImageView.contentMode = .scaleAspectFill
        groupImageView.clipsToBounds = true
        groupImageView.backgroundColor = .systemGray5
        // 이름: 이미지 하단 겹침, #77000000 배경 + 흰 18
        nameOverlayView.translatesAutoresizingMaskIntoConstraints = false
        nameOverlayView.backgroundColor = UIColor.black.withAlphaComponent(0.47)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 18)
        nameLabel.textColor = .white
        nameLabel.text = viewModel.groupItem.name
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 6
        descriptionLabel.text = viewModel.groupItem.groupDescription
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = .systemFont(ofSize: 13)
        infoLabel.textColor = .secondaryLabel
        infoLabel.numberOfLines = 0
        infoLabel.text = viewModel.groupItem.info ?? "회원수: \(viewModel.groupItem.memberCount)명"
        setupMainButton(requestButton, title: viewModel.buttonType == GroupInfoViewModel.TYPE_REQUEST ? "가입신청" : "신청취소")
        requestButton.addTarget(self, action: #selector(requestButtonClick), for: .touchUpInside)
        setupMainButton(closeButton, title: "닫기")
        closeButton.addTarget(self, action: #selector(closeButtonClick), for: .touchUpInside)
        let topSeparatorView = makeSeparator()
        let buttonDividerView = makeSeparator()

        nameOverlayView.addSubview(nameLabel)
        scrollView.addSubview(groupImageView)
        scrollView.addSubview(nameOverlayView)
        scrollView.addSubview(descriptionLabel)
        scrollView.addSubview(infoLabel)
        view.addSubview(scrollView)
        view.addSubview(topSeparatorView)
        view.addSubview(requestButton)
        view.addSubview(buttonDividerView)
        view.addSubview(closeButton)
        groupImageView.loadImage(viewModel.groupItem.image, placeholder: UIImage(named: "knu_minigroup"))
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: topSeparatorView.topAnchor),
            groupImageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            groupImageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            groupImageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            groupImageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            groupImageView.heightAnchor.constraint(equalToConstant: 200),
            nameOverlayView.leadingAnchor.constraint(equalTo: groupImageView.leadingAnchor),
            nameOverlayView.trailingAnchor.constraint(equalTo: groupImageView.trailingAnchor),
            nameOverlayView.bottomAnchor.constraint(equalTo: groupImageView.bottomAnchor),
            nameLabel.topAnchor.constraint(equalTo: nameOverlayView.topAnchor, constant: 14),
            nameLabel.bottomAnchor.constraint(equalTo: nameOverlayView.bottomAnchor, constant: -14),
            nameLabel.leadingAnchor.constraint(equalTo: nameOverlayView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: nameOverlayView.trailingAnchor, constant: -8),
            descriptionLabel.topAnchor.constraint(equalTo: groupImageView.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: groupImageView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: groupImageView.trailingAnchor, constant: -20),
            infoLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            infoLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            infoLabel.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -10),
            topSeparatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSeparatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSeparatorView.heightAnchor.constraint(equalToConstant: 0.5),
            requestButton.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor),
            requestButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            requestButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            requestButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.topAnchor.constraint(equalTo: requestButton.topAnchor),
            closeButton.leadingAnchor.constraint(equalTo: requestButton.trailingAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            closeButton.widthAnchor.constraint(equalTo: requestButton.widthAnchor),
            closeButton.heightAnchor.constraint(equalTo: requestButton.heightAnchor),
            buttonDividerView.topAnchor.constraint(equalTo: requestButton.topAnchor),
            buttonDividerView.bottomAnchor.constraint(equalTo: requestButton.bottomAnchor),
            buttonDividerView.leadingAnchor.constraint(equalTo: requestButton.trailingAnchor),
            buttonDividerView.widthAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    // Android main_button 셀렉터: #FAFAFA 배경 + 검정 텍스트, 눌림 시 #AAAAAA
    private func setupMainButton(_ button: UIButton, title: String) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setBackgroundImage(UIImage(color: .buttonNormalBg), for: .normal)
        button.setBackgroundImage(UIImage(color: .colorAccent), for: .highlighted)
        button.setTitleColor(.black, for: .normal)
        button.clipsToBounds = true
    }

    private func makeSeparator() -> UIView {
        let separator = UIView()

        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .systemGray4
        return separator
    }

    @objc private func closeButtonClick() {
        dismiss(animated: true)
    }

    @objc private func requestButtonClick() {
        viewModel.sendRequest()
    }

    private func observeViewModel() {
        viewModel.$type
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                guard type != nil else {
                    return
                }
                // Android GroupInfoFragment: 가입 신청 성공은 메인 화면으로, 신청 취소는 호스트 목록 갱신
                // 콜백은 dismiss 완료 후 self가 해제될 수 있으므로 미리 붙잡아 둔다
                let completion = type == GroupInfoViewModel.TYPE_REQUEST ? self?.onRequestSent : self?.onRequestCanceled

                self?.dismiss(animated: true, completion: completion)
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
