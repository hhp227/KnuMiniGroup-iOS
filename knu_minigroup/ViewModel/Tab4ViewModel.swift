//
//  Tab4ViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.Tab4ViewModel 대응 — 소모임 설정 (폐쇄/탈퇴)
//

import Foundation
import Combine

class Tab4ViewModel {
    @Published private(set) var isLoading = false

    @Published private(set) var isSuccess = false

    @Published private(set) var message: String?

    let isAdmin: Bool

    let groupId: String

    let key: String

    private let groupRepository = GroupRepository()

    private let preferenceManager = PreferenceManager.shared

    var user: User? {
        return preferenceManager.user
    }

    init(isAdmin: Bool, groupId: String, key: String) {
        self.isAdmin = isAdmin
        self.groupId = groupId
        self.key = key
    }

    func deleteGroup() {
        guard let user = user else {
            return
        }
        groupRepository.removeGroup(user: user, isAdmin: isAdmin, key: key) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .loading:
                self.isLoading = true
            case .success(let success):
                self.isLoading = false
                self.isSuccess = success
                self.message = "소모임 " + (self.isAdmin ? "폐쇄" : "탈퇴") + " 완료"
            case .failure(let error):
                self.isLoading = false
                self.message = error.localizedDescription
            }
        }
    }
}
