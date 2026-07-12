//
//  MainViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.GroupMainViewModel 대응 — 가입된 소모임 + 인기 소모임
//

import Foundation
import Combine

class MainViewModel {
    @Published private(set) var isLoading = false

    @Published private(set) var groupItemList = [(key: String, value: GroupItem)]()

    @Published private(set) var popularItemList = [GroupItem]()

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
        groupRepository.getJoinedGroupList(user: user) { [weak self] result in
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

    func fetchPopularGroupList() {
        groupRepository.getPopularGroupList(cookie: nil) { [weak self] result in
            switch result {
            case .loading:
                break
            case .success(let popularItemList):
                self?.popularItemList = popularItemList
            case .failure:
                // LMS 서버 폐쇄로 인기 소모임은 현재 제공되지 않음 (Android와 동일)
                self?.popularItemList = []
            }
        }
    }

    func logout() {
        preferenceManager.clear()
    }
}
