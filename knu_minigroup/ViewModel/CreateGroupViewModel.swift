//
//  CreateGroupViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.CreateGroupViewModel 대응
//

import Foundation
import Combine
import UIKit

class CreateGroupViewModel {
    @Published private(set) var isLoading = false

    @Published private(set) var createdGroup: (key: String, value: GroupItem)?

    @Published private(set) var message: String?

    var image: UIImage?

    var joinType = true // true: 자동 승인(0), false: 승인 확인(1)

    private let groupRepository = GroupRepository()

    private let preferenceManager = PreferenceManager.shared

    func createGroup(title: String, description: String) {
        guard let user = preferenceManager.user else {
            return
        }
        guard !title.isEmpty else {
            message = "소모임 이름을 입력하세요."
            return
        }
        guard !description.isEmpty else {
            message = "소모임 설명을 입력하세요."
            return
        }
        // LMS 서버 폐쇄로 이미지 업로드는 지원되지 않음 (Android도 이미지 첨부시 생성 실패)
        if image != nil {
            message = "이미지 업로드는 현재 지원되지 않습니다."
            return
        }
        isLoading = true
        groupRepository.addGroup(cookie: nil, user: user, hasImage: false, title: title, description: description, type: joinType ? "0" : "1") { [weak self] result in
            switch result {
            case .loading:
                self?.isLoading = true
            case .success(let entry):
                self?.isLoading = false
                self?.createdGroup = entry
            case .failure(let error):
                self?.isLoading = false
                self?.message = error.localizedDescription
            }
        }
    }
}
