//
//  GroupRepository.swift
//  knu_minigroup
//
//  Android의 data.GroupRepository 대응
//

import Foundation

class GroupRepository {
    private let groupRemoteDataSource = GroupRemoteDataSource()

    var isStopRequestMore: Bool {
        return groupRemoteDataSource.isStopRequestMore
    }

    func setLastKey(_ lastKey: String?) {
        groupRemoteDataSource.setLastKey(lastKey)
    }

    func getJoinedGroupList(user: User, callback: @escaping Callback<[(key: String, value: GroupItem)]>) {
        groupRemoteDataSource.getJoinedGroupList(user: user, callback: callback)
    }

    func getNotJoinedGroupList(uid: String?, offset: Int, limit: Int, callback: @escaping Callback<[(key: String, value: GroupItem)]>) {
        groupRemoteDataSource.getNotJoinedGroupList(uid: uid, limit: limit, callback: callback)
    }

    func getJoinRequestGroupList(user: User, offset: Int, limit: Int, callback: @escaping Callback<[(key: String, value: GroupItem)]>) {
        groupRemoteDataSource.getJoinRequestGroupList(user: user, callback: callback)
    }

    func getPopularGroupList(cookie: String?, callback: @escaping Callback<[GroupItem]>) {
        groupRemoteDataSource.getPopularGroupList(cookie: cookie, callback: callback)
    }

    func getGroup(cookie: String?, groupId: String, groupImage: String?, callback: @escaping Callback<GroupItem>) {
        groupRemoteDataSource.getGroup(cookie: cookie, groupId: groupId, groupImage: groupImage, callback: callback)
    }

    func addGroup(cookie: String?, user: User, hasImage: Bool, title: String, description: String, type: String, callback: @escaping Callback<(key: String, value: GroupItem)>) {
        groupRemoteDataSource.addGroup(user: user, groupName: title, description: description, hasImage: hasImage, type: type, callback: callback)
    }

    func setGroup(cookie: String?, groupKey: String, groupId: String, groupName: String, description: String, joinType: String, callback: @escaping Callback<GroupItem>) {
        groupRemoteDataSource.setGroup(cookie: cookie, groupKey: groupKey, groupId: groupId, groupName: groupName, description: description, joinType: joinType, callback: callback)
    }

    func removeGroup(user: User, isAdmin: Bool, key: String, callback: @escaping Callback<Bool>) {
        groupRemoteDataSource.removeGroup(user: user, isAdmin: isAdmin, key: key, callback: callback)
    }
}
