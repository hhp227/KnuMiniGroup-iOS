//
//  FindGroupViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.FindGroupViewModel 대응
//

import Foundation
import Combine

class FindGroupViewModel {
    private static let LIMIT = 15

    @Published private(set) var isLoading = false

    @Published private(set) var groupItemList = [(key: String, value: GroupItem)]()

    @Published private(set) var message: String?

    private(set) var hasRequestMore = true

    private var offset = 1

    private let groupRepository = GroupRepository()

    private let preferenceManager = PreferenceManager.shared

    var user: User? {
        return preferenceManager.user
    }

    func fetchNextPage() {
        guard hasRequestMore else {
            return
        }
        groupRepository.getNotJoinedGroupList(uid: user?.uid, offset: offset, limit: FindGroupViewModel.LIMIT) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .loading:
                self.isLoading = true
            case .success(let groupItemList):
                self.isLoading = false
                self.groupItemList += groupItemList
                self.offset += groupItemList.count
                self.hasRequestMore = !self.groupRepository.isStopRequestMore
            case .failure(let error):
                self.isLoading = false
                self.message = error.localizedDescription
            }
        }
    }

    func refresh() {
        offset = 1
        hasRequestMore = true

        groupRepository.setLastKey(nil)
        groupItemList = []
        fetchNextPage()
    }
}
