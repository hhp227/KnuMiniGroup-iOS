//
//  DateUtil.swift
//  knu_minigroup
//
//  Android의 helper.DateUtil 대응
//

import Foundation

enum DateUtil {
    // 타임스탬프(ms)를 "n분전/n시간전/날짜" 형태로 반환
    static func getPeriodTime(_ timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
        let diff = Date().timeIntervalSince(date)

        switch diff {
        case ..<60:
            return "방금전"
        case ..<3600:
            return "\(Int(diff / 60))분전"
        case ..<86400:
            return "\(Int(diff / 3600))시간전"
        default:
            let formatter = DateFormatter()

            formatter.dateFormat = "yyyy.MM.dd"
            return formatter.string(from: date)
        }
    }

    // 학사일정 XML의 날짜(yyyyMMdd)를 "yyyy.MM.dd"로 변환
    static func getCalendarStamp(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.count == 8 else {
            return trimmed
        }
        let year = trimmed.prefix(4)
        let month = trimmed.dropFirst(4).prefix(2)
        let day = trimmed.suffix(2)

        return "\(year).\(month).\(day)"
    }
}
