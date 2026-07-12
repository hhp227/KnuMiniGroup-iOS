//
//  UnivNoticeViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.UnivNoticeViewModel 대응 — 경북대 공지사항 (HTML 파싱)
//

import Foundation
import Combine

class UnivNoticeViewModel {
    @Published private(set) var isLoading = false

    @Published private(set) var noticeList = [[String: String]]()

    @Published private(set) var message: String?

    private var page = 1

    func fetchNextPage() {
        let endPoint = EndPoint.URL_KNU_NOTICE.replacingOccurrences(of: "{PAGE}", with: String(page))

        isLoading = true
        HttpClient.request(endPoint) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let response):
                var list = [[String: String]]()

                guard let table = HtmlUtil.tables(in: response).first else {
                    self.isLoading = false
                    self.message = "공지사항을 불러올수 없습니다."
                    return
                }
                for row in HtmlUtil.rows(in: table) {
                    let cells = HtmlUtil.cells(in: row, tag: "td")

                    guard cells.count >= 4 else {
                        continue
                    }
                    var map = [String: String]()

                    map["번호"] = cells[0]
                    map["제목"] = cells[1]
                    map["작성자"] = cells[2]
                    map["날짜"] = cells[3]
                    if let hrefRange = row.range(of: "href=\"([^\"]*)\"", options: .regularExpression) {
                        let href = String(row[hrefRange]).replacingOccurrences(of: "href=\"", with: "").replacingOccurrences(of: "\"", with: "")

                        map["링크"] = href.hasPrefix("http") ? href : EndPoint.URL_KNU + href
                    }
                    list.append(map)
                }
                self.isLoading = false
                self.noticeList += list
                self.page += 1
            case .failure(let error):
                self.isLoading = false
                self.message = error.localizedDescription
            }
        }
    }

    func refresh() {
        page = 1

        noticeList = []
        fetchNextPage()
    }
}
