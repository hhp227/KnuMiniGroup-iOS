//
//  MealRemoteDataSource.swift
//  knu_minigroup
//
//  Android의 data.remote.MealRemoteDataSource 대응 (경북대 생협/기숙사 식단 XML)
//

import Foundation

class MealRemoteDataSource {
    func getStudentMealList(id: Int, callback: @escaping Callback<[(key: String, value: String)]>) {
        let endPoint = EndPoint.URL_KNU_MEAL.replacingOccurrences(of: "{ID}", with: String(id))

        callback(.loading)
        HttpClient.request(endPoint) { result in
            switch result {
            case .success(let response):
                let parser = MealXMLParser()
                let entries = parser.parseEntries(response)
                var mealList = [(key: String, value: String)]()

                for entry in entries {
                    switch entry.mode {
                    case "breakfast":
                        mealList.append((MealRepository.KEY_BREAKFAST, HtmlUtil.text(entry.data)))
                    case "breakfast_limited":
                        mealList.append((MealRepository.KEY_BREAKFAST, "* 특식\n" + HtmlUtil.text(entry.data)))
                    case "lunch":
                        mealList.append((MealRepository.KEY_LAUNCH, HtmlUtil.text(entry.data)))
                    case "lunch_limited":
                        mealList.append((MealRepository.KEY_LAUNCH, "* 특식\n" + HtmlUtil.text(entry.data)))
                    case "dinner":
                        mealList.append((MealRepository.KEY_DINNER, HtmlUtil.text(entry.data)))
                    case "dinner_limited":
                        mealList.append((MealRepository.KEY_DINNER, "* 특식\n" + HtmlUtil.text(entry.data)))
                    default:
                        break
                    }
                }
                callback(.success(mealList.isEmpty ? [
                    (MealRepository.KEY_BREAKFAST, "등록된 식단이 없습니다."),
                    (MealRepository.KEY_LAUNCH, "등록된 식단이 없습니다."),
                    (MealRepository.KEY_DINNER, "등록된 식단이 없습니다.")
                ] : mealList))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }

    func getBTLDormMealList(callback: @escaping Callback<[String]>) {
        let endPoint = EndPoint.URL_KNU_DORM_MEAL.replacingOccurrences(of: "{ID}", with: "3")

        callback(.loading)
        HttpClient.request(endPoint) { result in
            switch result {
            case .success(let response):
                let parser = MealXMLParser()
                let mealList = parser.parseDataTags(response).map(HtmlUtil.text(_:))

                callback(.success(mealList.isEmpty ? [
                    "등록된 식단이 없습니다.",
                    "등록된 식단이 없습니다.",
                    "등록된 식단이 없습니다."
                ] : mealList))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
}

// 식단 XML 파서 — Android의 XmlPullParser 파싱 대응
private class MealXMLParser: NSObject, XMLParserDelegate {
    private var entries = [(mode: String, data: String)]()

    private var dataTags = [String]()

    private var currentMode: String?

    private var currentText = ""

    private var isInData = false

    func parseEntries(_ xml: String) -> [(mode: String, data: String)] {
        entries = []
        parse(xml)
        return entries
    }

    func parseDataTags(_ xml: String) -> [String] {
        dataTags = []
        parse(xml)
        return dataTags
    }

    private func parse(_ xml: String) {
        guard let data = xml.data(using: .utf8) else {
            return
        }
        let parser = XMLParser(data: data)

        parser.delegate = self
        parser.parse()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        if elementName == "entry" {
            currentMode = attributeDict.values.first
        } else if elementName == "data" {
            isInData = true
            currentText = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isInData {
            currentText += string
        }
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if isInData {
            currentText += String(data: CDATABlock, encoding: .utf8) ?? ""
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "data" {
            isInData = false

            dataTags.append(currentText)
            if let mode = currentMode {
                entries.append((mode, currentText))
            }
        } else if elementName == "entry" {
            currentMode = nil
        }
    }
}
