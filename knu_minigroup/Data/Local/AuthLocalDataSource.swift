//
//  AuthLocalDataSource.swift
//  knu_minigroup
//
//  Android의 data.local.AuthLocalDataSource 대응 — 자격증명은 Keychain, 사용자 정보는 UserDefaults
//

import Foundation
import Security

class AuthLocalDataSource {
    // 로그아웃(PreferenceManager.clear())에도 유지되어야 해서 Keychain에 저장
    private static let service = "com.hhp227.knu-minigroup.auth"

    private static let accountId = "saved_id"

    private static let accountPassword = "saved_pwd"

    private let preferenceManager = PreferenceManager.shared

    func putCredentials(id: String, password: String) {
        AuthLocalDataSource.keychainSave(id, account: AuthLocalDataSource.accountId)
        AuthLocalDataSource.keychainSave(password, account: AuthLocalDataSource.accountPassword)
    }

    var savedId: String? {
        return AuthLocalDataSource.keychainLoad(account: AuthLocalDataSource.accountId)
    }

    var savedPassword: String? {
        return AuthLocalDataSource.keychainLoad(account: AuthLocalDataSource.accountPassword)
    }

    var user: User? {
        return preferenceManager.user
    }

    // 비밀번호는 UserDefaults에 남기지 않는다 — Keychain이 원본
    func storeUser(_ user: User) {
        var stored = user

        stored.password = ""
        preferenceManager.storeUser(stored)
    }

    func clearUser() {
        preferenceManager.clear()
    }

    // 구버전이 UserDefaults에 남긴 평문 비밀번호를 Keychain으로 옮긴다 (멱등)
    func migrateLegacyPassword() {
        if let user = preferenceManager.user, let password = user.password, !password.isEmpty, let userId = user.userId {
            putCredentials(id: userId, password: password)
            storeUser(user)
        }
    }

    private static func keychainSave(_ value: String, account: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)

        if status == errSecItemNotFound {
            var attributes = query

            attributes[kSecValueData as String] = data
            SecItemAdd(attributes as CFDictionary, nil)
        }
    }

    private static func keychainLoad(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?

        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
