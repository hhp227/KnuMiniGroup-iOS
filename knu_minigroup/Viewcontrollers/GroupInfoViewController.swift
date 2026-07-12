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

    private let nameLabel = UILabel()

    private let infoLabel = UILabel()

    private let descriptionLabel = UILabel()

    private let requestButton = UIButton(type: .system)

    init(groupItem: GroupItem, key: String, buttonType: Int) {
        self.viewModel = GroupInfoViewModel(groupItem: groupItem, key: key, buttonType: buttonType)
        super.init(nibName: nil, bundle: nil)
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

    private func setupViews() {
        groupImageView.translatesAutoresizingMaskIntoConstraints = false
        groupImageView.contentMode = .scaleAspectFill
        groupImageView.clipsToBounds = true
        groupImageView.backgroundColor = .systemGray5
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .boldSystemFont(ofSize: 20)
        nameLabel.text = viewModel.groupItem.name
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = .systemFont(ofSize: 13)
        infoLabel.textColor = .secondaryLabel
        infoLabel.numberOfLines = 0
        infoLabel.text = viewModel.groupItem.info ?? "회원수: \(viewModel.groupItem.memberCount)명"
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = viewModel.groupItem.groupDescription
        requestButton.translatesAutoresizingMaskIntoConstraints = false
        requestButton.setTitle(viewModel.buttonType == GroupInfoViewModel.TYPE_REQUEST ? "가입신청" : "신청취소", for: .normal)
        requestButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        requestButton.backgroundColor = .systemBlue
        requestButton.setTitleColor(.white, for: .normal)
        requestButton.layer.cornerRadius = 8
        requestButton.addTarget(self, action: #selector(requestButtonClick), for: .touchUpInside)
        view.addSubview(groupImageView)
        view.addSubview(nameLabel)
        view.addSubview(infoLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(requestButton)
        groupImageView.loadImage(viewModel.groupItem.image, placeholder: UIImage(named: "knu_minigroup"))
        NSLayoutConstraint.activate([
            groupImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            groupImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            groupImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            groupImageView.heightAnchor.constraint(equalToConstant: 200),
            nameLabel.topAnchor.constraint(equalTo: groupImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            infoLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            requestButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            requestButton.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            requestButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            requestButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func requestButtonClick() {
        viewModel.sendRequest()
    }

    private func observeViewModel() {
        viewModel.$type
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                if type != nil {
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
