//
//  LoginViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.LoginViewModel 대응 — KNU SSO + Firebase Auth
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseDatabase

class LoginViewModel {
    @Published private(set) var isLoading = false

    @Published private(set) var user: User?

    @Published private(set) var message: String?

    @Published private(set) var emailError: String?

    @Published private(set) var passwordError: String?

    private let preferenceManager = PreferenceManager.shared

    init() {
        self.user = preferenceManager.user
    }

    func login(id: String, password: String) {
        if !id.isEmpty && !password.isEmpty {
            isLoading = true
            if id == "TestUser" && password == "TestUser" {
                firebaseLogin(id: id, password: password)
            } else {
                loginKNUSSO(id: id, password: password)
            }
        } else {
            emailError = id.isEmpty ? "아이디를 입력하세요." : nil
            passwordError = password.isEmpty ? "패스워드를 입력하세요." : nil
        }
    }

    func storeUser(_ user: User) {
        preferenceManager.storeUser(user)
    }

    private func loginKNUSSO(id: String, password: String) {
        HttpClient.request(EndPoint.LOGIN, method: "POST", formParams: ["id": id, "pw": password, "agentId": "2"]) { [weak self] result in
            switch result {
            case .success(let response):
                let userId = HtmlUtil.inputValue(byId: "userId", in: response)
                let resultCode = HtmlUtil.inputValue(byId: "resultCode", in: response)
                let resultMessage = HtmlUtil.inputValue(byId: "resultMessage", in: response)

                if resultCode == "000000" {
                    self?.firebaseLogin(id: userId ?? id, password: password)
                } else {
                    self?.isLoading = false
                    self?.message = resultMessage ?? "로그인에 실패했습니다."
                }
            case .failure(let error):
                self?.isLoading = false
                self?.message = error.localizedDescription
            }
        }
    }

    private func firebaseLogin(id: String, password: String) {
        let email = id + "@knu.ac.kr"

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let firebaseUser = authResult?.user {
                var user = User()

                user.uid = firebaseUser.uid
                user.userId = id
                user.password = password
                user.name = id
                user.number = "2022000000"
                user.phoneNumber = "010-0000-0000"
                user.email = email
                self?.isLoading = false
                self?.user = user
            } else if error != nil {
                self?.firebaseRegister(id: id, password: password)
            }
        }
    }

    private func firebaseRegister(id: String, password: String) {
        let email = id + "@knu.ac.kr"
        let databaseReference = Database.database().reference(withPath: "Users")

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let firebaseUser = authResult?.user {
                var user = User()

                databaseReference.child(firebaseUser.uid).setValue(["uid": firebaseUser.uid, "email": email, "name": id])
                user.uid = firebaseUser.uid
                user.userId = id
                user.password = password
                user.name = id
                user.number = "2022000000"
                user.phoneNumber = "010-0000-0000"
                user.email = email
                self?.isLoading = false
                self?.user = user
            } else if let error = error {
                self?.isLoading = false
                self?.message = "Firebase error" + error.localizedDescription
            }
        }
    }
}
