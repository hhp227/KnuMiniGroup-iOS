//
//  AuthRemoteDataSource.swift
//  knu_minigroup
//
//  Android의 data.remote.AuthRemoteDataSource 대응 — KNU SSO + FirebaseAuth
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class AuthRemoteDataSource {
    var currentUser: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }

    // KNU SSO는 재학생 검증 용도로만 쓴다 (Android AuthRemoteDataSource.loginKNUSSO 대응)
    func loginKNUSSO(id: String, password: String, callback: @escaping Callback<String>) {
        HttpClient.request(EndPoint.LOGIN, method: "POST", formParams: ["id": id, "pw": password, "agentId": "2"]) { result in
            switch result {
            case .success(let response):
                let userId = HtmlUtil.inputValue(byId: "userId", in: response)
                let resultCode = HtmlUtil.inputValue(byId: "resultCode", in: response)
                let resultMessage = HtmlUtil.inputValue(byId: "resultMessage", in: response)

                if resultCode == "000000" {
                    callback(.success(userId ?? id))
                } else if let resultMessage = resultMessage, !resultMessage.isEmpty {
                    callback(.failure(AppError(message: resultMessage)))
                } else {
                    callback(.failure(AppError(message: "아이디 또는 비밀번호가 올바르지 않습니다.")))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }

    func signIn(email: String, password: String, callback: @escaping Callback<FirebaseAuth.User>) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let firebaseUser = authResult?.user {
                callback(.success(firebaseUser))
            } else {
                callback(.failure(error ?? AppError(message: "로그인에 실패했습니다.")))
            }
        }
    }

    func register(email: String, password: String, callback: @escaping Callback<FirebaseAuth.User>) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let firebaseUser = authResult?.user {
                callback(.success(firebaseUser))
            } else {
                callback(.failure(error ?? AppError(message: "가입에 실패했습니다.")))
            }
        }
    }

    func updatePassword(newPassword: String, callback: @escaping Callback<FirebaseAuth.User>) {
        guard let firebaseUser = Auth.auth().currentUser else {
            callback(.failure(AppError(message: "로그인 상태가 아닙니다.")))
            return
        }
        firebaseUser.updatePassword(to: newPassword) { error in
            if let error = error {
                callback(.failure(error))
            } else {
                callback(.success(firebaseUser))
            }
        }
    }

    func sendPasswordResetEmail(email: String, callback: @escaping Callback<Void>) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                callback(.failure(error))
            } else {
                callback(.success(()))
            }
        }
    }

    func reload(callback: @escaping Callback<FirebaseAuth.User>) {
        guard let firebaseUser = Auth.auth().currentUser else {
            callback(.failure(AppError(message: "로그인 상태가 아닙니다.")))
            return
        }
        firebaseUser.reload { error in
            if let error = error {
                callback(.failure(error))
            } else {
                callback(.success(firebaseUser))
            }
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
    }

    /// 멤버 목록이 uid로 이름을 찾을 수 있도록 Users/{uid}를 채운다.
    /// 로그인할 때마다 호출해 기존 계정도 다음 로그인 때 보정되게 한다
    /// (setValue가 아닌 병합이라 다른 필드는 보존 — Android AuthRemoteDataSource와 동일).
    func saveUserToFirebase(uid: String, id: String, email: String) {
        Database.database().reference(withPath: "Users").child(uid).updateChildValues(["uid": uid, "email": email, "name": id])
    }
}
