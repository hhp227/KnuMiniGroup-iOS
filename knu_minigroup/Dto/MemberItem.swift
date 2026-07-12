//
//  MemberItem.swift
//  knu_minigroup
//
//  Android의 dto.MemberItem 대응
//

import Foundation

struct MemberItem {
    var uid: String?

    var name: String?

    var value: String?

    var stuNum: String?

    var dept: String?

    var div: String?

    var regDate: String?

    init(uid: String?, name: String?, value: String? = nil, stuNum: String? = nil, dept: String? = nil, div: String? = nil, regDate: String? = nil) {
        self.uid = uid
        self.name = name
        self.value = value
        self.stuNum = stuNum
        self.dept = dept
        self.div = div
        self.regDate = regDate
    }
}
