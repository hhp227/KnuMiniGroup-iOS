//
//  MockTimeTableViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.MockTimeTableViewModel 대응 — 개인 시간표 (로컬 저장)
//

import Foundation
import Combine

class MockTimeTableViewModel {
    @Published private(set) var isLoading = false

    @Published private(set) var timetableList = [TimetableItem]()

    @Published private(set) var message: String?

    private let timetableRepository = TimetableRepository()

    deinit {
        timetableRepository.close()
    }

    func fetchTimetableList() {
        timetableRepository.getTimetableList(callback: makeCallback())
    }

    func addTimetable(id: Int, subject: String, classroom: String) {
        timetableRepository.addTimetable(id: id, subject: subject, classroom: classroom, callback: makeCallback())
    }

    func updateTimetable(id: Int, subject: String, classroom: String) {
        timetableRepository.updateTimetable(id: id, subject: subject, classroom: classroom, callback: makeCallback())
    }

    func deleteTimetable(id: Int) {
        timetableRepository.deleteTimetable(id: id, callback: makeCallback())
    }

    private func makeCallback() -> Callback<[TimetableItem]> {
        return { [weak self] result in
            switch result {
            case .loading:
                self?.isLoading = true
            case .success(let timetableList):
                self?.isLoading = false
                self?.timetableList = timetableList
            case .failure(let error):
                self?.isLoading = false
                self?.message = error.localizedDescription
            }
        }
    }
}
