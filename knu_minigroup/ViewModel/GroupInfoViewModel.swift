//
//  GroupInfoViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.GroupInfoViewModel 대응 — 소모임 가입 신청/취소 (Firebase 직접 갱신)
//

import Foundation
import Combine
import FirebaseDatabase

class GroupInfoViewModel {
    static let TYPE_REQUEST = 0

    static let TYPE_CANCEL = 1

    @Published private(set) var isLoading = false

    @Published private(set) var type: Int?

    @Published private(set) var message: String?

    let buttonType: Int

    let groupItem: GroupItem

    let key: String

    private let preferenceManager = PreferenceManager.shared

    init(groupItem: GroupItem, key: String, buttonType: Int) {
        self.groupItem = groupItem
        self.key = key
        self.buttonType = buttonType
    }

    func sendRequest() {
        isLoading = true
        if buttonType == GroupInfoViewModel.TYPE_REQUEST {
            insertGroupToFirebase()
        } else if buttonType == GroupInfoViewModel.TYPE_CANCEL {
            deleteUserInGroupFromFirebase()
        }
    }

    private func insertGroupToFirebase() {
        guard let uid = preferenceManager.user?.uid else {
            return
        }
        let userGroupListReference = Database.database().reference(withPath: "UserGroupList")
        let groupsReference = Database.database().reference(withPath: "Groups")
        let isAutoJoin = groupItem.joinType == "0"

        groupsReference.child(key).observeSingleEvent(of: .value, with: { [weak self] dataSnapshot in
            guard let self = self else {
                return
            }
            if var groupItem = GroupItem(dictionary: dataSnapshot.value as? [String: Any]) {
                var members = groupItem.members ?? [String: Bool]()

                members[uid] = isAutoJoin
                groupItem.members = members
                groupItem.memberCount = members.count
                groupsReference.child(self.key).setValue(groupItem.dictionary)
            }
            self.isLoading = false
            self.type = GroupInfoViewModel.TYPE_REQUEST
            self.message = "신청완료"
        }, withCancel: { [weak self] error in
            self?.isLoading = false
            self?.message = error.localizedDescription
        })
        userGroupListReference.updateChildValues(["/\(uid)/\(key)": isAutoJoin])
    }

    private func deleteUserInGroupFromFirebase() {
        guard let uid = preferenceManager.user?.uid else {
            return
        }
        let userGroupListReference = Database.database().reference(withPath: "UserGroupList")
        let groupsReference = Database.database().reference(withPath: "Groups")

        groupsReference.child(key).observeSingleEvent(of: .value, with: { [weak self] dataSnapshot in
            guard let self = self else {
                return
            }
            if var groupItem = GroupItem(dictionary: dataSnapshot.value as? [String: Any]) {
                if var members = groupItem.members, members[uid] != nil {
                    members.removeValue(forKey: uid)

                    groupItem.members = members
                    groupItem.memberCount = members.count
                }
                groupsReference.child(self.key).setValue(groupItem.dictionary)
            }
            self.isLoading = false
            self.type = GroupInfoViewModel.TYPE_CANCEL
            self.message = "신청취소"
        }, withCancel: { [weak self] error in
            self?.isLoading = false
            self?.message = error.localizedDescription
        })
        userGroupListReference.child(uid).child(key).removeValue()
    }
}
