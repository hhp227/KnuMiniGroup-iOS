//
//  TimetableRemoteDataSource.swift
//  knu_minigroup
//
//  Android의 data.remote.TimetableRemoteDataSource 대응 (LMS 학기 시간표 — 서버 폐쇄)
//

import Foundation

class TimetableRemoteDataSource {
    /*학기 시간표 페이지를 파싱하여 행 단위의 텍스트 리스트로 반환, 첫번째 행은 요일 헤더*/
    func getSemesterTimetableList(cookie: String?, callback: @escaping Callback<[[String]]>) {
        callback(.loading)
        HttpClient.request(EndPoint.TIMETABLE, headers: ["Cookie": cookie ?? ""]) { result in
            switch result {
            case .success(let response):
                guard let tableHtml = HtmlUtil.tables(in: response).first else {
                    callback(.failure(AppError(message: "시간표를 불러올수 없습니다.")))
                    return
                }
                var table = [[String]]()
                let trs = HtmlUtil.rows(in: tableHtml)

                for i in 0..<trs.count {
                    if i == 1 {
                        continue
                    }
                    let row = HtmlUtil.cells(in: trs[i], tag: "th") + HtmlUtil.cells(in: trs[i], tag: "td")

                    table.append(row)
                }
                callback(.success(table))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
}
