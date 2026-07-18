//
//  Tab2ViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.Tab2ViewModel 대응 — 학사일정 캘린더 (경북대 XML)
//

import Foundation
import Combine

class Tab2ViewModel {
    @Published private(set) var isLoading = false

    @Published private(set) var itemList = [[String: String]]()

    @Published private(set) var message: String?

    @Published private(set) var calendar = Calendar.current.dateComponents([.year, .month], from: Date())

    func previousMonth() {
        guard let year = calendar.year, let month = calendar.month else {
            return
        }
        if month == 1 {
            calendar.year = year - 1
            calendar.month = 12
        } else {
            calendar.month = month - 1
        }
    }

    func nextMonth() {
        guard let year = calendar.year, let month = calendar.month else {
            return
        }
        if month == 12 {
            calendar.year = year + 1
            calendar.month = 1
        } else {
            calendar.month = month + 1
        }
    }

    // Android처럼 관찰 중인 calendar 값을 인자로 받아 해당 월의 학사일정을 요청
    func fetchDataTask(_ calendar: DateComponents) {
        guard let year = calendar.year, let month = calendar.month else {
            return
        }
        let yearMonth = String(format: "%d%02d", year, month)
        let endPoint = EndPoint.URL_SCHEDULE.replacingOccurrences(of: "{YEAR-MONTH}", with: yearMonth)

        isLoading = true
        HttpClient.request(endPoint) { [weak self] result in
            switch result {
            case .success(let response):
                let parser = ScheduleXMLParser()

                self?.isLoading = false
                self?.itemList = [[String: String]]()  + parser.parse(response)
            case .failure(let error):
                self?.isLoading = false
                self?.message = error.localizedDescription
            }
        }
    }
}

// 학사일정 XML 파서 — <entry><date>...</date><title>...</title></entry>
private class ScheduleXMLParser: NSObject, XMLParserDelegate {
    private var list = [[String: String]]()

    private var currentMap = [String: String]()

    private var currentElement = ""

    private var currentText = ""

    func parse(_ xml: String) -> [[String: String]] {
        list = [[String: String]()]
        guard let data = xml.data(using: .utf8) else {
            return list
        }
        let parser = XMLParser(data: data)

        parser.delegate = self
        parser.parse()
        return list
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        currentText = ""
        if elementName == "entry" {
            currentMap = [String: String]()
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "date":
            currentMap["날짜"] = DateUtil.getCalendarStamp(currentText)
        case "title":
            currentMap["내용"] = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        case "entry":
            list.append(currentMap)
        default:
            break
        }
    }
}
