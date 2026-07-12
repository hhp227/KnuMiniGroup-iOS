//
//  UserRepository.swift
//  knu_minigroup
//
//  Android의 data.UserRepository 대응
//

import Foundation

class UserRepository {
    private let userRemoteDataSource: UserRemoteDataSource

    init(groupKey: String? = nil) {
        self.userRemoteDataSource = UserRemoteDataSource(groupKey: groupKey)
    }

    func getManagedMemberList(cookie: String?, groupId: String, callback: @escaping Callback<[MemberItem]>) {
        userRemoteDataSource.getManagedMemberList(cookie: cookie, groupId: groupId, callback: callback)
    }

    func getUserList(limit: Int, callback: @escaping Callback<[(key: String, value: MemberItem)]>) {
        userRemoteDataSource.getUserList(limit: limit, callback: callback)
    }
}
