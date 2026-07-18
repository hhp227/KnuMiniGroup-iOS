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

    // 최초 로딩(성공) 완료 여부 — 완료 전에는 빈 목록을 "그룹 없음"으로 판단하지 않는다
    private(set) var isLoaded = false

    private let groupRepository = GroupRepository()

    private let preferenceManager = PreferenceManager.shared

    var user: User? {
        return preferenceManager.user
    }

    // 배너는 로딩이 끝나 가입중인 그룹이 없다고 확정된 경우에만 노출 (Android GroupGridAdapter 대응)
    var showsEmptyBanner: Bool {
        return isLoaded && groupItemList.isEmpty
    }

    init() {
        // 앱 재실행 시 서버 응답을 기다리지 않고 마지막 목록을 즉시 표시
        groupItemList = groupRepository.getCachedJoinedGroupList(uid: user?.uid)
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
                self?.isLoaded = true
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
