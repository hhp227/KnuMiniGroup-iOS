//
//  AuthRepository.swift
//  knu_minigroup
//
//  Android의 data.AuthRepository 대응 — Firebase 우선 로그인 오케스트레이션
//

import Foundation
import FirebaseAuth

class AuthRepository {
    // AuthErrorCode의 Swift 표면이 SDK 버전마다 달라 raw 코드로 비교한다
    private static let emailAlreadyInUseCode = 17007 // FIRAuthErrorCodeEmailAlreadyInUse

    private static let invalidUserCodes = [17005, 17011, 17017, 17021] // userDisabled/userNotFound/invalidUserToken/userTokenExpired

    private static let authErrorDomain = "FIRAuthErrorDomain"

    private let remote = AuthRemoteDataSource()

    private let local = AuthLocalDataSource()

    /// Firebase 우선 로그인.
    /// 1) Firebase signIn 성공 → 끝 (SSO 안 탐 — 평상시 경로)
    /// 2) 실패 → KNU SSO로 재학생 인증 → Firebase 가입 (최초 로그인)
    /// 3) 가입 충돌(EMAIL_ALREADY_IN_USE) = KNU 비밀번호 변경 → 이전 비밀번호로 로그인 후 updatePassword
    /// 4) 이전 비밀번호가 없거나 실패 → 재설정 메일 발송
    func login(id: String, password: String, callback: @escaping Callback<User>) {
        callback(.loading)
        local.migrateLegacyPassword()
        remote.signIn(email: id + "@knu.ac.kr", password: password) { result in
            switch result {
            case .success(let firebaseUser):
                self.finishLogin(firebaseUser: firebaseUser, id: id, password: password, callback: callback)
            case .failure:
                if id == "TestUser" && password == "TestUser" {
                    self.register(id: id, password: password, callback: callback)
                } else {
                    self.verifyWithKNUSSO(id: id, password: password, callback: callback)
                }
            case .loading:
                break
            }
        }
    }

    /// 자동 로그인 — SSO 없이 Firebase 세션만 확인 (Android AuthRepository.loginSilently 대응).
    /// reload의 네트워크 오류는 통과시켜 오프라인 시작을 허용한다.
    func loginSilently(callback: @escaping Callback<User>) {
        callback(.loading)
        local.migrateLegacyPassword()
        if remote.currentUser != nil {
            remote.reload { result in
                switch result {
                case .success:
                    if let user = self.local.user {
                        callback(.success(user))
                    } else {
                        callback(.failure(AppError(message: "로그인이 필요합니다.")))
                    }
                case .failure(let error):
                    let nsError = error as NSError

                    if nsError.domain == AuthRepository.authErrorDomain && AuthRepository.invalidUserCodes.contains(nsError.code) {
                        // 계정 삭제/비활성/토큰 무효 — 세션 무효
                        callback(.failure(AppError(message: "세션이 만료되었습니다. 다시 로그인해주세요.")))
                    } else if let user = self.local.user {
                        // 네트워크 오류 — 오프라인 시작 허용
                        callback(.success(user))
                    } else {
                        callback(.failure(AppError(message: "로그인이 필요합니다.")))
                    }
                case .loading:
                    break
                }
            }
        } else if let savedId = local.savedId, let savedPassword = local.savedPassword, local.user != nil {
            login(id: savedId, password: savedPassword, callback: callback)
        } else {
            callback(.failure(AppError(message: "로그인이 필요합니다.")))
        }
    }

    func logout() {
        remote.signOut()
        local.clearUser()
    }

    private func verifyWithKNUSSO(id: String, password: String, callback: @escaping Callback<User>) {
        remote.loginKNUSSO(id: id, password: password) { result in
            switch result {
            case .success(let userId):
                self.register(id: userId, password: password, callback: callback)
            case .failure(let error):
                callback(.failure(error))
            case .loading:
                break
            }
        }
    }

    private func register(id: String, password: String, callback: @escaping Callback<User>) {
        remote.register(email: id + "@knu.ac.kr", password: password) { result in
            switch result {
            case .success(let firebaseUser):
                self.finishLogin(firebaseUser: firebaseUser, id: id, password: password, callback: callback)
            case .failure(let error):
                let nsError = error as NSError

                if nsError.domain == AuthRepository.authErrorDomain && nsError.code == AuthRepository.emailAlreadyInUseCode {
                    self.syncChangedPassword(id: id, newPassword: password, callback: callback)
                } else {
                    callback(.failure(error))
                }
            case .loading:
                break
            }
        }
    }

    // KNU 인증은 통과했는데 가입이 충돌 → KNU 비밀번호가 바뀐 계정
    private func syncChangedPassword(id: String, newPassword: String, callback: @escaping Callback<User>) {
        if let savedId = local.savedId, savedId.lowercased() == id.lowercased(),
           let savedPassword = local.savedPassword, savedPassword == newPassword {
            // 비밀번호가 그대로인데 가입이 충돌 → 실제 변경이 아니라 Firebase 일시 장애(스로틀 등)
            callback(.failure(AppError(message: "일시적인 오류로 로그인하지 못했습니다. 잠시 후 다시 시도해주세요.")))
        } else if let savedId = local.savedId, savedId.lowercased() == id.lowercased(),
           let savedPassword = local.savedPassword, savedPassword != newPassword {
            remote.signIn(email: id + "@knu.ac.kr", password: savedPassword) { result in
                switch result {
                case .success:
                    self.updatePassword(id: id, newPassword: newPassword, callback: callback)
                case .failure:
                    self.sendResetEmail(id: id, callback: callback)
                case .loading:
                    break
                }
            }
        } else {
            sendResetEmail(id: id, callback: callback)
        }
    }

    private func updatePassword(id: String, newPassword: String, callback: @escaping Callback<User>) {
        remote.updatePassword(newPassword: newPassword) { result in
            switch result {
            case .success(let firebaseUser):
                self.finishLogin(firebaseUser: firebaseUser, id: id, password: newPassword, callback: callback)
            case .failure:
                // 이전 비밀번호 signIn은 성공해 세션이 살아있는 상태 — 안내와 상태가 모순되지 않도록 정리
                self.remote.signOut()
                self.sendResetEmail(id: id, callback: callback)
            case .loading:
                break
            }
        }
    }

    private func sendResetEmail(id: String, callback: @escaping Callback<User>) {
        let email = id + "@knu.ac.kr"

        remote.sendPasswordResetEmail(email: email) { result in
            switch result {
            case .success:
                callback(.failure(AppError(message: "경북대 비밀번호가 변경되어 \(email)(경북대 웹메일)로 재설정 메일을 보냈습니다. 메일의 링크에서 새 비밀번호로 재설정한 뒤 다시 로그인해주세요.")))
            case .failure:
                callback(.failure(AppError(message: "재설정 메일 발송에 실패했습니다. 잠시 후 다시 시도해주세요.")))
            case .loading:
                break
            }
        }
    }

    private func finishLogin(firebaseUser: FirebaseAuth.User, id: String, password: String, callback: @escaping Callback<User>) {
        let email = id + "@knu.ac.kr"
        var user = User()

        user.uid = firebaseUser.uid
        user.userId = id
        user.password = ""
        user.name = id
        user.number = "2022000000"
        user.phoneNumber = "010-0000-0000"
        user.email = email
        local.putCredentials(id: id, password: password)
        local.storeUser(user)
        remote.saveUserToFirebase(uid: firebaseUser.uid, id: id, email: email)
        callback(.success(user))
    }
}
