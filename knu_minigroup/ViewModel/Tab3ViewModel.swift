//
//  Tab3ViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.Tab3ViewModel 대응 — 소모임 멤버 목록
//

import Foundation
import Combine

class Tab3ViewModel {
    private static let LIMIT = 40

    @Published private(set) var isLoading = false

    @Published private(set) var memberItemList = [(key: String, value: MemberItem)]()

    @Published private(set) var message: String?

    private let userRepository: UserRepository

    let groupKey: String

    init(groupKey: String) {
        self.groupKey = groupKey
        self.userRepository = UserRepository(groupKey: groupKey)
    }

    func fetchUserList() {
        userRepository.getUserList(limit: Tab3ViewModel.LIMIT) { [weak self] result in
            switch result {
            case .loading:
                self?.isLoading = true
            case .success(let memberItemList):
                self?.isLoading = false
                self?.memberItemList += memberItemList
            case .failure(let error):
                self?.isLoading = false
                self?.message = error.localizedDescription
            }
        }
    }

    func refresh() {
        memberItemList = []
        fetchUserList()
    }
}
