//
//  HtmlUtil.swift
//  knu_minigroup
//
//  Android의 jericho HTML 파서 대응 — 정규식 기반 최소 구현
//

import Foundation

enum HtmlUtil {
    // html 내의 <table>...</table> 블록들을 반환
    static func tables(in html: String) -> [String] {
        return blocks(in: html, tag: "table")
    }

    // 테이블 html 내의 <tr>...</tr> 블록들을 반환
    static func rows(in tableHtml: String) -> [String] {
        return blocks(in: tableHtml, tag: "tr")
    }

    // 행 html 내의 <th> 또는 <td> 내용(태그 제거된 텍스트)들을 반환
    static func cells(in rowHtml: String, tag: String) -> [String] {
        return blocks(in: rowHtml, tag: tag).map(text(_:))
    }

    // 특정 id를 가진 input 태그의 value 속성 값 (로그인 응답 파싱용)
    static func inputValue(byId id: String, in html: String) -> String? {
        let pattern = "<input[^>]*id=[\"']\(id)[\"'][^>]*>"

        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range, in: html) else {
            return nil
        }
        let inputTag = String(html[range])
        let valuePattern = "value=[\"']([^\"']*)[\"']"

        guard let valueRegex = try? NSRegularExpression(pattern: valuePattern, options: [.caseInsensitive]),
              let valueMatch = valueRegex.firstMatch(in: inputTag, range: NSRange(inputTag.startIndex..., in: inputTag)),
              let valueRange = Range(valueMatch.range(at: 1), in: inputTag) else {
            return nil
        }
        return String(inputTag[valueRange])
    }

    // 태그 제거 + 기본 엔티티 디코딩
    static func text(_ html: String) -> String {
        var result = html.replacingOccurrences(of: "<br[^>]*>", with: "\n", options: [.regularExpression, .caseInsensitive])

        // 따옴표로 감싼 속성값 안의 '>'(예: 경북대 공지 목록 href의 "/>")에서 태그가 끊겨
        // URL 조각이 본문으로 노출되지 않도록 속성 인식형 패턴으로 태그 제거
        result = result.replacingOccurrences(of: "<[^>\"']*(?:\"[^\"]*\"[^>\"']*|'[^']*'[^>\"']*)*>", with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: "&nbsp;", with: " ")
        result = result.replacingOccurrences(of: "&lt;", with: "<")
        result = result.replacingOccurrences(of: "&gt;", with: ">")
        result = result.replacingOccurrences(of: "&amp;", with: "&")
        result = result.replacingOccurrences(of: "&quot;", with: "\"")
        result = result.replacingOccurrences(of: "&#39;", with: "'")
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func blocks(in html: String, tag: String) -> [String] {
        let pattern = "<\(tag)[^>]*>(.*?)</\(tag)>"

        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else {
            return []
        }
        let matches = regex.matches(in: html, range: NSRange(html.startIndex..., in: html))

        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: html) else {
                return nil
            }
            return String(html[range])
        }
    }
}
