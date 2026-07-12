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

    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldGroupTitle.delegate = self

        observeViewModel()
        setupJoinTypeRadioButtons()
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

    // 가입 방식 라디오 버튼 (스토리보드의 RadioButton 연동)
    private func setupJoinTypeRadioButtons() {
        let radioButtons = stackViewGroupType.arrangedSubviews.compactMap { $0 as? RadioButton }

        for (index, radioButton) in radioButtons.enumerated() {
            radioButton.tag = index

            radioButton.addTarget(self, action: #selector(joinTypeChanged(_:)), for: .touchUpInside)
        }
    }

    @objc private func joinTypeChanged(_ sender: RadioButton) {
        viewModel.joinType = sender.tag == 0
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
