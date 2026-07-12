//
//  ScheduleRemoteDataSource.swift
//  knu_minigroup
//
//  Android의 data.remote.ScheduleRemoteDataSource 대응 (경북대 셔틀버스 페이지 HTML 파싱)
//

import Foundation

class ScheduleRemoteDataSource {
    // 대구캠퍼스 셔틀
    func getDCShuttleSchedule(callback: @escaping Callback<[[String: String]]>) {
        callback(.loading)
        HttpClient.request(EndPoint.URL_SHUTTLE.replacingOccurrences(of: "{SHUTTLE}", with: "map03")) { result in
            switch result {
            case .success(let response):
                var shuttleList = [[String: String]]()
                let tables = HtmlUtil.tables(in: response)

                for a in 0..<min(3, tables.count) {
                    let trs = HtmlUtil.rows(in: tables[a])

                    for i in 0..<trs.count {
                        let j = i - 1
                        let ths = HtmlUtil.cells(in: trs[i], tag: "th")
                        let tds = HtmlUtil.cells(in: trs[i], tag: "td")

                        guard let col1 = ths.first else {
                            continue
                        }
                        var map1 = [String: String]()
                        var map2 = [String: String]()

                        map1["col1"] = col1
                        if i != 0 {
                            guard let col2 = tds.first else {
                                continue
                            }
                            map1["col2"] = col2
                            shuttleList.insert(map1, at: a == 0 ? min(j, shuttleList.count) : shuttleList.count)
                            if ths.count > 1 && tds.count > 1 {
                                map2["col1"] = ths[1]
                                map2["col2"] = tds[1]
                                if !ths[1].isEmpty || !tds[1].isEmpty {
                                    shuttleList.append(map2)
                                }
                            }
                        } else {
                            shuttleList.insert(map1, at: a == 0 ? min(i, shuttleList.count) : shuttleList.count)
                        }
                    }
                }
                callback(.success(shuttleList))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }

    // 상주캠퍼스 셔틀 — (시간표 목록, 헤더 목록) 반환
    func getSCShuttleSchedule(callback: @escaping Callback<(list: [[String: String]], headers: [String])>) {
        callback(.loading)
        HttpClient.request(EndPoint.URL_SHUTTLE.replacingOccurrences(of: "{SHUTTLE}", with: "map03_02")) { result in
            switch result {
            case .success(let response):
                guard let table = HtmlUtil.tables(in: response).first else {
                    callback(.failure(AppError(message: "시간표를 불러올수 없습니다.")))
                    return
                }
                let trs = HtmlUtil.rows(in: table)
                let headers = trs.first.map { HtmlUtil.cells(in: $0, tag: "th") } ?? []
                var shuttleList = [[String: String]]()

                for i in 1..<trs.count {
                    let tds = HtmlUtil.cells(in: trs[i], tag: "td")

                    guard tds.count >= 6 else {
                        continue
                    }
                    var map = [String: String]()

                    map["col1"] = String(i)
                    for c in 0..<6 {
                        map["col\(c + 2)"] = tds[c]
                    }
                    shuttleList.append(map)
                }
                callback(.success((shuttleList, headers)))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
}
