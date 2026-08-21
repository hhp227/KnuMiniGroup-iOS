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

    /// 그룹 멤버 목록 (Groups/{key}/members 기반, 페이징).
    /// members의 값이 false면 가입 신청중이므로 멤버가 아니다.
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
            var uidList = [String]()

            for case let snapshot as DataSnapshot in dataSnapshot.children {
                if newLastKey == nil {
                    newLastKey = snapshot.key // 이 페이지에서 가장 앞선 키 - 다음 페이지는 이 키 앞을 읽는다
                }
                if snapshot.value as? Bool == true {
                    uidList.insert(snapshot.key, at: 0)
                }
            }
            if newLastKey == nil {
                self?.isStopRequestMore = true
            }
            self?.lastKey = newLastKey // 다음 페이지 요청을 위해 키 업데이트
            self?.fetchMemberNames(uidList: uidList, callback: callback)
        }, withCancel: { error in
            callback(.failure(error))
        })
    }

    /// uid만으로는 화면에 이름을 못 쓰므로 Users/{uid}를 하나씩 읽어 채운다.
    /// 모든 조회가 끝나야 목록 순서가 보장되므로 남은 개수를 세어 마지막에 한 번만 콜백한다.
    private func fetchMemberNames(uidList: [String], callback: @escaping Callback<[(key: String, value: MemberItem)]>) {
        guard !uidList.isEmpty else {
            callback(.success([]))
            return
        }
        let usersReference = Database.database().reference(withPath: "Users")
        var memberItems = [MemberItem?](repeating: nil, count: uidList.count)
        var remaining = uidList.count
        let complete: (Int, String) -> Void = { index, name in
            memberItems[index] = MemberItem(uid: uidList[index], name: name)
            remaining -= 1
            if remaining == 0 {
                var memberItemList = [(key: String, value: MemberItem)]()

                for (index, uid) in uidList.enumerated() {
                    if let memberItem = memberItems[index] {
                        memberItemList.append((key: uid, value: memberItem))
                    }
                }
                callback(.success(memberItemList))
            }
        }

        for (index, uid) in uidList.enumerated() {
            usersReference.child(uid).observeSingleEvent(of: .value, with: { dataSnapshot in
                complete(index, UserRemoteDataSource.resolveName(dataSnapshot, uid: uid))
            }, withCancel: { _ in
                complete(index, uid) // 이름을 못 읽어도 멤버 자체는 보여준다
            })
        }
    }

    /// Users/{uid}에 저장된 이름. 클라이언트마다 저장 포맷이 달라(iOS는 name을 넣고, 구버전 안드로이드는
    /// FirebaseUser를 통째로 넣어 name이 없다) 이메일 아이디 → uid 순으로 물러난다.
    private static func resolveName(_ dataSnapshot: DataSnapshot, uid: String) -> String {
        if let name = dataSnapshot.childSnapshot(forPath: "name").value as? String, !name.isEmpty {
            return name
        }
        if let email = dataSnapshot.childSnapshot(forPath: "email").value as? String, let index = email.firstIndex(of: "@") {
            return String(email[email.startIndex..<index])
        }
        return uid
    }
}
