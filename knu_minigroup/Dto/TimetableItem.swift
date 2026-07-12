//
//  TimetableItem.swift
//  knu_minigroup
//
//  Android의 dto.TimetableItem 대응
//

import Foundation

struct TimetableItem: Codable {
    var id: Int

    var subject: String

    var classroom: String
}
