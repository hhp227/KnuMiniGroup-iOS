//
//  GroupRemoteDataSource.swift
//  knu_minigroup
//
//  Android의 data.remote.GroupRemoteDataSource 대응 (Firebase Database + Storage)
//  LMS 서버는 폐쇄됨 — 커버 업로드와 소모임 수정은 Firebase로 처리한다
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

class GroupRemoteDataSource {
    private var lastKey: String? = nil // 마지막으로 가져온 데이터의 키

    private(set) var isStopRequestMore = false

    func setLastKey(_ lastKey: String?) {
        self.lastKey = lastKey
        if lastKey == nil {
            isStopRequestMore = false // 새로고침 시 페이징 재개
        }
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

    // uid가 가입중이거나(true) 가입신청중인(false) 그룹은 목록에서 제외
    func getNotJoinedGroupList(uid: String?, limit: Int, callback: @escaping Callback<[(key: String, value: GroupItem)]>) {
        let databaseReference = Database.database().reference(withPath: "Groups")
        var query: DatabaseQuery = databaseReference.queryOrderedByKey().queryLimited(toFirst: UInt(limit))

        if let lastKey = lastKey {
            query = query.queryStarting(afterValue: lastKey)
        }
        callback(.loading)
        query.observeSingleEvent(of: .value, with: { [weak self] dataSnapshot in
            var newLastKey: String? = nil
            var groupItemList = [(key: String, value: GroupItem)]()
            var childIndex = 0

            for case let snapshot as DataSnapshot in dataSnapshot.children {
                // 가입 그룹이 필터링되면 목록 개수로는 마지막 child를 못 찾으므로 원본 인덱스로 판별
                if childIndex == Int(dataSnapshot.childrenCount) - 1 {
                    newLastKey = snapshot.key // 마지막 키 저장
                }
                childIndex += 1
                if let value = GroupItem(dictionary: snapshot.value as? [String: Any]), uid == nil || value.members?[uid!] == nil {
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

    func addGroup(user: User, groupName: String, description: String, imageData: Data?, type: String, callback: @escaping Callback<(key: String, value: GroupItem)>) {
        callback(.loading)
        if let imageData = imageData {
            uploadGroupImage(imageData: imageData, callback: callback) { [weak self] imageUrl in
                self?.insertGroupToFirebase(user: user, groupName: groupName, description: description, imageUrl: imageUrl, type: type, callback: callback)
            }
        } else {
            insertGroupToFirebase(user: user, groupName: groupName, description: description, imageUrl: nil, type: type, callback: callback)
        }
    }

    /// 그룹 생성과 소모임 수정이 함께 쓰는 커버 업로드. 성공하면 다운로드 URL을 넘긴다.
    private func uploadGroupImage<T>(imageData: Data, callback: @escaping Callback<T>, onUploaded: @escaping (String) -> Void) {
        let storageReference = Storage.storage()
            .reference(withPath: "group_images")
            .child(UUID().uuidString.replacingOccurrences(of: "-", with: "") + ".jpg")

        storageReference.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                DispatchQueue.main.async { callback(.failure(error)) }
                return
            }
            storageReference.downloadURL { url, error in
                DispatchQueue.main.async {
                    if let url = url {
                        onUploaded(url.absoluteString)
                    } else {
                        callback(.failure(error ?? AppError(message: "이미지 업로드에 실패했습니다.")))
                    }
                }
            }
        }
    }

    private func insertGroupToFirebase(user: User, groupName: String, description: String, imageUrl: String?, type: String, callback: @escaping Callback<(key: String, value: GroupItem)>) {
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
        // 커버가 없으면 nil로 두고 표시 단계의 placeholder에 맡긴다 (LMS 기본 이미지 URL은 서버가 닫혀 로드되지 않는다)
        groupItem.image = imageUrl
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

    /// LMS 서버가 닫혀 소모임 수정 엔드포인트를 쓸 수 없으므로 Firebase에 바로 반영한다.
    /// 커버를 새로 골랐으면 Storage에 올린 뒤 그 URL까지 함께 갱신한다. (Android setGroup과 동일)
    func setGroup(cookie: String?, groupKey: String, groupId: String, groupName: String, description: String, joinType: String, imageData: Data?, callback: @escaping Callback<GroupItem>) {
        var groupItem = GroupItem()

        groupItem.id = groupId
        groupItem.name = groupName
        groupItem.groupDescription = description
        groupItem.joinType = joinType
        callback(.loading)
        if let imageData = imageData {
            uploadGroupImage(imageData: imageData, callback: callback) { [weak self] imageUrl in
                groupItem.image = imageUrl
                self?.updateGroupDataToFirebase(groupKey: groupKey, newGroupItem: groupItem, callback: callback)
            }
        } else {
            updateGroupDataToFirebase(groupKey: groupKey, newGroupItem: groupItem, callback: callback)
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
        var newGroupItem = newGroupItem

        query.observeSingleEvent(of: .value, with: { dataSnapshot in
            if var groupItem = GroupItem(dictionary: dataSnapshot.value as? [String: Any]) {
                groupItem.name = newGroupItem.name
                groupItem.groupDescription = newGroupItem.groupDescription
                groupItem.joinType = newGroupItem.joinType
                // 커버를 새로 고른 경우에만 교체하고, 아니면 기존 이미지를 유지한다
                if let imageUrl = newGroupItem.image {
                    groupItem.image = imageUrl
                } else {
                    newGroupItem.image = groupItem.image
                }
                query.setValue(groupItem.dictionary)
            }
            callback(.success(newGroupItem))
        }, withCancel: { error in
            callback(.failure(error))
        })
    }
}
