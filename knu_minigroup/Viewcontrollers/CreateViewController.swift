//
//  CreateViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/22.
//  Copyright © 2020 홍희표. All rights reserved.
//
//  소모임 만들기 (Android의 CreateGroupActivity 대응)
//

import UIKit
import Combine

class CreateViewController: UIViewController {

    // 명칭UIname식으로 변수선언할것
    @IBOutlet weak var textFieldGroupTitle: UITextField!

    @IBOutlet weak var textViewGroupDescription: UITextView!

    @IBOutlet weak var barButtonItem: UIBarButtonItem!

    @IBOutlet weak var buttonTitleReset: UIButton!

    @IBOutlet weak var stackViewGroupType: UIStackView!

    private let viewModel = CreateGroupViewModel()

    private var cancellables = Set<AnyCancellable>()

    private let descriptionPlaceholderLabel = UILabel()

    private var joinTypeRadioButtons = [RadioButton]()

    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldGroupTitle.delegate = self
        textViewGroupDescription.delegate = self

        setupViews()
        observeViewModel()
        setupJoinTypeRadioButtons()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler)))
    }

    // Android activity_create_group 대응: 보더리스 제목 행 + 구분선 + 설명 hint + 하단 가입방식 행
    private func setupViews() {
        textFieldGroupTitle.borderStyle = .none
        textFieldGroupTitle.font = .systemFont(ofSize: 18) // textAppearanceMedium
        buttonTitleReset.tintColor = .gray
        if let titleRowStackView = textFieldGroupTitle.superview as? UIStackView {
            titleRowStackView.isLayoutMarginsRelativeArrangement = true
            titleRowStackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            titleRowStackView.spacing = 5

            addSeparator(below: titleRowStackView)
        }
        // Android et_description: padding 10 + "그룹 설명을 입력하세요." hint
        textViewGroupDescription.font = .systemFont(ofSize: 16)
        textViewGroupDescription.textContainerInset = UIEdgeInsets(top: 10, left: 6, bottom: 10, right: 6)
        descriptionPlaceholderLabel.text = "그룹 설명을 입력하세요."
        descriptionPlaceholderLabel.font = textViewGroupDescription.font
        descriptionPlaceholderLabel.textColor = .placeholderText
        descriptionPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        textViewGroupDescription.addSubview(descriptionPlaceholderLabel)
        NSLayoutConstraint.activate([
            descriptionPlaceholderLabel.topAnchor.constraint(equalTo: textViewGroupDescription.topAnchor, constant: 10),
            descriptionPlaceholderLabel.leadingAnchor.constraint(equalTo: textViewGroupDescription.leadingAnchor, constant: 11)
        ])
        updateDescriptionPlaceholder()
        // 가입방식 행: 좌우 여백 + 상단 구분선
        stackViewGroupType.isLayoutMarginsRelativeArrangement = true
        stackViewGroupType.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        addSeparator(above: stackViewGroupType)
    }

    private func addSeparator(below aboveView: UIView? = nil, above belowView: UIView? = nil) {
        let separator = UIView()

        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .systemGray5
        view.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            aboveView.map { separator.topAnchor.constraint(equalTo: $0.bottomAnchor) } ?? separator.bottomAnchor.constraint(equalTo: belowView!.topAnchor)
        ])
    }

    private func updateDescriptionPlaceholder() {
        descriptionPlaceholderLabel.isHidden = !(textViewGroupDescription.text ?? "").isEmpty
    }

    @objc private func tapGestureHandler() {
        view.endEditing(true)
    }

    @IBAction func actionSend(_ sender: UIBarButtonItem) {
        guard let title = textFieldGroupTitle.text, !title.isEmpty else {
            view.makeToast(message: "그룹 이름을 입력하세요.")
            return
        }
        guard let description = textViewGroupDescription.text, !description.isEmpty else {
            view.makeToast(message: "그룹 설명을 입력하세요.")
            return
        }
        viewModel.createGroup(title: title, description: description)
    }

    @IBAction func actionTitleReset(_ sender: UIButton) {
        textFieldGroupTitle.text = nil
    }

    // 가입 방식 라디오 버튼 — 라디오는 중첩 스택 안에 있으므로 한 단계 안까지 탐색
    private func setupJoinTypeRadioButtons() {
        joinTypeRadioButtons = stackViewGroupType.arrangedSubviews
            .flatMap { ($0 as? UIStackView)?.arrangedSubviews ?? [$0] }
            .compactMap { $0 as? RadioButton }
        for (index, radioButton) in joinTypeRadioButtons.enumerated() {
            radioButton.tag = index

            radioButton.addTarget(self, action: #selector(joinTypeChanged(_:)), for: .touchUpInside)
        }
        // Android rb_auto 기본 선택
        joinTypeRadioButtons.first?.isOn = true
    }

    @objc private func joinTypeChanged(_ sender: RadioButton) {
        viewModel.joinType = sender.tag == 0
        // 라디오 그룹처럼 단일 선택 유지
        joinTypeRadioButtons.forEach { $0.isOn = $0 === sender }
    }

    private func observeViewModel() {
        viewModel.$createdGroup
            .receive(on: DispatchQueue.main)
            .sink { [weak self] createdGroup in
                guard createdGroup != nil else {
                    return
                }
                self?.view.makeToast(message: "소모임 생성 완료")
                self?.navigationController?.popViewController(animated: true)
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

extension CreateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldGroupTitle {
            textViewGroupDescription.becomeFirstResponder()
        }
        return true
    }
}

extension CreateViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateDescriptionPlaceholder()
    }
}
