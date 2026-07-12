//
//  GroupRemoteDataSource.swift
//  knu_minigroup
//
//  Android의 data.remote.GroupRemoteDataSource 대응 (Firebase + LMS)
//  LMS 서버는 폐쇄됨 — Android와 동일하게 요청은 시도하며 실패시 onFailure
//

import Foundation
import FirebaseDatabase

class GroupRemoteDataSource {
    private var lastKey: String? = nil // 마지막으로 가져온 데이터의 키

    private(set) var isStopRequestMore = false

    func setLastKey(_ lastKey: String?) {
        self.lastKey = lastKey
    }

    func getJoinedGroupList(user: User, callback: @escaping Callback<[(key: String, value: GroupItem)]>) {
        guard let uid = user.uid else {
            callback(.success([]))
            return
        }
        let databaseReference = Database.database().reference(withPath: "UserGroupList")
        let query = databaseReference.child(uid).queryOrderedByValue().queryEqual(toValue: true)

        callback(.loading)
        fetchDataTaskFromFirebase(query: query, callback: callback)
    }

    func getNotJoinedGroupList(limit: Int, callback: @escaping Callback<[(key: String, value: GroupItem)]>) {
        let databaseReference = Database.database().reference(withPath: "Groups")
        var query: DatabaseQuery = databaseReference.queryOrderedByKey().queryLimited(toFirst: UInt(limit))

        if let lastKey = lastKey {
            query = query.queryStarting(afterValue: lastKey)
        }
        callback(.loading)
        query.observeSingleEvent(of: .value, with: { [weak self] dataSnapshot in
            var newLastKey: String? = nil
            var groupItemList = [(key: String, value: GroupItem)]()

            for case let snapshot as DataSnapshot in dataSnapshot.children {
                if groupItemList.count == Int(dataSnapshot.childrenCount) - 1 {
                    newLastKey = snapshot.key // 마지막 키 저장
                }
                if let value = GroupItem(dictionary: snapshot.value as? [String: Any]) {
                    groupItemList.append((snapshot.key, value))
                }
            }
            if newLastKey == nil {
                self?.isStopRequestMore = true
            }
            self?.lastKey = newLastKey // 다음 페이지 요청을 위해 키 업데이트
            callback(.success(groupItemList))
        }, withCancel: { error in
            callback(.failure(error))
        })
    }

    func getJoinRequestGroupList(user: User, callback: @escaping Callback<[(key: String, value: GroupItem)]>) {
        guard let uid = user.uid else {
            callback(.success([]))
            return
        }
        let databaseReference = Database.database().reference(withPath: "UserGroupList")
        let query = databaseReference.child(uid).queryOrderedByValue().queryEqual(toValue: false)

        fetchDataTaskFromFirebase(query: query, callback: callback)
    }

    // LMS 인기 소모임 목록 (서버 폐쇄)
    func getPopularGroupList(cookie: String?, callback: @escaping Callback<[GroupItem]>) {
        callback(.loading)
        HttpClient.request(EndPoint.GROUP_LIST, method: "POST", headers: ["Cookie": cookie ?? ""], formParams: ["panel_id": "3", "encoding": "utf-8"]) { result in
            switch result {
            case .success:
                // LMS 서버 폐쇄로 응답 파싱은 생략하고 빈 목록 반환
                callback(.success([]))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }

    // LMS 소모임 정보 조회 (서버 폐쇄)
    func getGroup(cookie: String?, groupId: String, groupImage: String?, callback: @escaping Callback<GroupItem>) {
        callback(.loading)
        HttpClient.request(EndPoint.MODIFY_GROUP + "?CLUB_GRP_ID=" + groupId, headers: ["Cookie": cookie ?? ""]) { result in
            switch result {
            case .success(let response):
                var groupItem = GroupItem()

                groupItem.id = groupId
                groupItem.image = groupImage
                groupItem.name = HtmlUtil.inputValue(byId: "wrtGroup", in: response)
                groupItem.joinType = "0"
                callback(.success(groupItem))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }

    func addGroup(user: User, groupName: String, description: String, hasImage: Bool, type: String, callback: @escaping Callback<(key: String, value: GroupItem)>) {
        let databaseReference = Database.database().reference()

        guard let uid = user.uid, let key = databaseReference.childByAutoId().key else {
            callback(.failure(AppError(message: "그룹 생성에 실패했습니다.")))
            return
        }
        var members = [String: Bool]()
        var groupItem = GroupItem()
        var childUpdates = [String: Any]()

        members[uid] = true
        groupItem.id = key
        groupItem.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        groupItem.author = user.name
        groupItem.authorUid = uid
        groupItem.image = hasImage ? EndPoint.GROUP_IMAGE.replacingOccurrences(of: "{FILE}", with: key + ".jpg") : EndPoint.DEFAULT_GROUP_IMAGE
        groupItem.name = groupName
        groupItem.groupDescription = description
        groupItem.joinType = type
        groupItem.members = members
        groupItem.memberCount = members.count
        childUpdates["Groups/" + key] = groupItem.dictionary
        childUpdates["UserGroupList/" + uid + "/" + key] = true
        databaseReference.updateChildValues(childUpdates)
        callback(.success((key, groupItem)))
    }

    // LMS 소모임 수정 요청 후 Firebase 반영 (LMS 폐쇄로 현재는 실패함 — Android와 동일)
    func setGroup(cookie: String?, groupKey: String, groupId: String, groupName: String, description: String, joinType: String, callback: @escaping Callback<GroupItem>) {
        HttpClient.request(EndPoint.UPDATE_GROUP, method: "POST", headers: ["Cookie": cookie ?? ""], formParams: ["CLUB_GRP_ID": groupId, "GRP_NM": groupName, "TXT": description, "JOIN_DIV": joinType]) { [weak self] result in
            switch result {
            case .success(let response):
                guard let data = response.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      json["isError"] as? Bool == false else {
                    callback(.failure(AppError(message: "소모임 수정에 실패했습니다.")))
                    return
                }
                var groupItem = GroupItem()

                groupItem.id = groupId
                groupItem.name = (json["GRP_NM"] as? String) ?? groupName
                groupItem.groupDescription = description
                groupItem.joinType = joinType
                self?.updateGroupDataToFirebase(groupKey: groupKey, newGroupItem: groupItem, callback: callback)
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }

    func removeGroup(user: User, isAdmin: Bool, key: String, callback: @escaping Callback<Bool>) {
        let userGroupListReference = Database.database().reference(withPath: "UserGroupList")
        let articlesReference = Database.database().reference(withPath: "Articles")
        let groupsReference = Database.database().reference(withPath: "Groups")

        if isAdmin {
            groupsReference.child(key).child("members").observeSingleEvent(of: .value, with: { dataSnapshot in
                for case let snapshot as DataSnapshot in dataSnapshot.children {
                    userGroupListReference.child(snapshot.key).child(key).removeValue()
                }
            }, withCancel: { error in
                callback(.failure(error))
            })
            articlesReference.child(key).observeSingleEvent(of: .value, with: { dataSnapshot in
                let replysReference = Database.database().reference(withPath: "Replys")

                for case let snapshot as DataSnapshot in dataSnapshot.children {
                    replysReference.child(snapshot.key).removeValue()
                }
                articlesReference.child(key).removeValue()
                groupsReference.child(key).removeValue()
            }, withCancel: { error in
                callback(.failure(error))
            })
        } else {
            groupsReference.child(key).observeSingleEvent(of: .value, with: { dataSnapshot in
                if var groupItem = GroupItem(dictionary: dataSnapshot.value as? [String: Any]) {
                    if let uid = user.uid, var members = groupItem.members, members[uid] != nil {
                        members.removeValue(forKey: uid)

                        groupItem.members = members
                        groupItem.memberCount = members.count
                    }
                    groupsReference.child(key).setValue(groupItem.dictionary)
                }
            }, withCancel: { error in
                callback(.failure(error))
            })
            if let uid = user.uid {
                userGroupListReference.child(uid).child(key).removeValue()
            }
        }
        callback(.success(true))
    }

    // UserGroupList 쿼리 결과의 각 키로 Groups를 조회하여 목록 구성 (Android의 fetchDataTaskFromFirebase 대응)
    private func fetchDataTaskFromFirebase(query: DatabaseQuery, callback: @escaping Callback<[(key: String, value: GroupItem)]>) {
        query.observeSingleEvent(of: .value, with: { dataSnapshot in
            guard dataSnapshot.hasChildren() else {
                callback(.success([]))
                return
            }
            let groupsReference = Database.database().reference(withPath: "Groups")
            var groupItemList = [(key: String, value: GroupItem)]()

            for case let snapshot as DataSnapshot in dataSnapshot.children {
                groupsReference.child(snapshot.key).observeSingleEvent(of: .value, with: { groupSnapshot in
                    if let value = GroupItem(dictionary: groupSnapshot.value as? [String: Any]) {
                        groupItemList.append((groupSnapshot.key, value))
                    }
                    callback(.success(groupItemList))
                }, withCancel: { error in
                    callback(.failure(error))
                })
            }
        }, withCancel: { error in
            callback(.failure(error))
        })
    }

    private func updateGroupDataToFirebase(groupKey: String, newGroupItem: GroupItem, callback: @escaping Callback<GroupItem>) {
        let databaseReference = Database.database().reference(withPath: "Groups")
        let query = databaseReference.child(groupKey)

        query.observeSingleEvent(of: .value, with: { dataSnapshot in
            if var groupItem = GroupItem(dictionary: dataSnapshot.value as? [String: Any]) {
                groupItem.name = newGroupItem.name
                groupItem.groupDescription = newGroupItem.groupDescription
                groupItem.joinType = newGroupItem.joinType
                query.setValue(groupItem.dictionary)
            }
            callback(.success(newGroupItem))
        }, withCancel: { error in
            callback(.failure(error))
        })
    }
}
