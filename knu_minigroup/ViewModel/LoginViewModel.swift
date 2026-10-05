//
//  LoginViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.LoginViewModel 대응 — AuthRepository 기반 Firebase 우선 로그인
//

import Foundation
import Combine

class LoginViewModel {
    @Published private(set) var isLoading = false

    @Published private(set) var user: User?

    @Published private(set) var message: String?

    @Published private(set) var emailError: String?

    @Published private(set) var passwordError: String?

    // 자동 로그인 실패(세션 없음) — 로그인 화면에 머무른다
    @Published private(set) var autoLoginFailed = false

    private let authRepository = AuthRepository()

    func login(id: String, password: String) {
        if !id.isEmpty && !password.isEmpty {
            authRepository.login(id: id, password: password) { [weak self] result in
                switch result {
                case .loading:
                    self?.isLoading = true
                case .success(let user):
                    self?.isLoading = false
                    self?.user = user
                case .failure(let error):
                    self?.isLoading = false
                    self?.message = error.localizedDescription
                }
            }
        } else {
            emailError = id.isEmpty ? "아이디를 입력하세요." : nil
            passwordError = password.isEmpty ? "패스워드를 입력하세요." : nil
        }
    }

    // Android SplashViewModel.connection 대응 — iOS는 스플래시가 없어 로그인 화면에서 수행
    func loginSilently() {
        authRepository.loginSilently { [weak self] result in
            switch result {
            case .loading:
                self?.isLoading = true
            case .success(let user):
                self?.isLoading = false
                self?.user = user
            case .failure:
                self?.isLoading = false
                self?.authRepository.logout()
                self?.autoLoginFailed = true
            }
        }
    }
}
