//
//  RequestViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.RequestViewModel 대응 — 가입 신청중인 소모임 목록
//

import Foundation
import Combine

class RequestViewModel {
    private static let LIMIT = 100

    @Published private(set) var isLoading = false

    @Published private(set) var groupItemList = [(key: String, value: GroupItem)]()

    @Published private(set) var message: String?

    private let groupRepository = GroupRepository()

    private let preferenceManager = PreferenceManager.shared

    var user: User? {
        return preferenceManager.user
    }

    func fetchGroupList() {
        guard let user = user else {
            return
        }
        isLoading = true
        groupRepository.getJoinRequestGroupList(user: user, offset: 1, limit: RequestViewModel.LIMIT) { [weak self] result in
            switch result {
            case .loading:
                self?.isLoading = true
            case .success(let groupItemList):
                self?.isLoading = false
                self?.groupItemList = groupItemList
            case .failure(let error):
                self?.isLoading = false
                self?.message = error.localizedDescription
            }
        }
    }

    func refresh() {
        groupRepository.setLastKey(nil)
        groupItemList = []
        fetchGroupList()
    }
}
