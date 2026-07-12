//
//  ViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/08/23.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit
import Combine

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var idTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!

    private let viewModel = LoginViewModel()

    private var cancellables = Set<AnyCancellable>()

    private var isNavigated = false

    override func viewDidLoad() {
        super.viewDidLoad()
        idTextField.delegate = self
        passwordTextField.delegate = self

        observeViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 자동 로그인 (Android의 SplashActivity 대응)
        if PreferenceManager.shared.user != nil {
            navigateToMain(animated: false)
        }
    }

    @IBAction func loginClick(_ sender: UIButton) {
        guard let id = idTextField.text else { return }
        guard let password = passwordTextField.text else { return }

        viewModel.login(id: id, password: password)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    private func observeViewModel() {
        viewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let user = user else {
                    return
                }
                self?.viewModel.storeUser(user)
                self?.navigateToMain(animated: true)
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
        viewModel.$emailError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.view.makeToast(message: error)
                }
            }
            .store(in: &cancellables)
        viewModel.$passwordError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.view.makeToast(message: error)
                }
            }
            .store(in: &cancellables)
    }

    private func navigateToMain(animated: Bool) {
        guard !isNavigated else {
            return
        }
        isNavigated = true
        let drawerController = storyboard?.instantiateViewController(withIdentifier: "DrawerController") as! DrawerController

        navigationController?.pushViewController(drawerController, animated: animated)
    }
}
