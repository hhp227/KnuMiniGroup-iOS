//
//  UserRemoteDataSource.swift
//  knu_minigroup
//
//  Android의 data.remote.UserRemoteDataSource 대응
//

import Foundation
import FirebaseDatabase

class UserRemoteDataSource {
    private let groupKey: String?

    private var lastKey: String? = nil // 마지막으로 가져온 데이터의 키

    private(set) var isStopRequestMore = false

    init(groupKey: String? = nil) {
        self.groupKey = groupKey
    }

    // LMS 멤버 관리 목록 (서버 폐쇄 — Android와 동일하게 요청은 시도하며 실패시 onFailure)
    func getManagedMemberList(cookie: String?, groupId: String, callback: @escaping Callback<[MemberItem]>) {
        callback(.loading)
        HttpClient.request(EndPoint.GROUP_MEMBER_LIST, method: "POST", headers: ["Cookie": cookie ?? ""], formParams: ["CLUB_GRP_ID": groupId]) { result in
            switch result {
            case .success:
                // LMS 서버 폐쇄로 응답 파싱은 생략하고 빈 목록 반환
                callback(.success([]))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }

    // 그룹 멤버 목록 (Groups/{key}/members 기반, 페이징)
    func getUserList(limit: Int, callback: @escaping Callback<[(key: String, value: MemberItem)]>) {
        guard let groupKey = groupKey else {
            callback(.success([]))
            return
        }
        let databaseReference = Database.database().reference(withPath: "Groups")
        var query: DatabaseQuery = databaseReference.child(groupKey).child("members").queryOrderedByKey().queryLimited(toLast: UInt(limit))

        if let lastKey = lastKey {
            query = query.queryEnding(beforeValue: lastKey)
        }
        callback(.loading)
        query.observeSingleEvent(of: .value, with: { [weak self] dataSnapshot in
            var newLastKey: String? = nil
            var memberItemList = [(key: String, value: MemberItem)]()

            for case let snapshot as DataSnapshot in dataSnapshot.children {
                if memberItemList.isEmpty {
                    newLastKey = snapshot.key // 마지막 키 저장
                }
                if snapshot.value as? Bool == true {
                    memberItemList.insert((snapshot.key, MemberItem(uid: snapshot.key, name: snapshot.key)), at: 0)
                }
            }
            if newLastKey == nil {
                self?.isStopRequestMore = true
            }
            self?.lastKey = newLastKey // 다음 페이지 요청을 위해 키 업데이트
            callback(.success(memberItemList))
        }, withCancel: { error in
            callback(.failure(error))
        })
    }
}
