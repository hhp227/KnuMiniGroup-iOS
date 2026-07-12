//
//  SemesterTimeTableViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.SemesterTimeTableViewModel 대응 — LMS 학기 시간표 (서버 폐쇄)
//

import Foundation
import Combine

class SemesterTimeTableViewModel {
    @Published private(set) var isLoading = false

    @Published private(set) var table = [[String]]()

    @Published private(set) var message: String?

    private let timetableRepository = TimetableRepository()

    func fetchSemesterTimetableList() {
        timetableRepository.getSemesterTimetableList(cookie: nil) { [weak self] result in
            switch result {
            case .loading:
                self?.isLoading = true
            case .success(let table):
                self?.isLoading = false
                self?.table = table
            case .failure(let error):
                self?.isLoading = false
                self?.message = error.localizedDescription
            }
        }
    }
}
