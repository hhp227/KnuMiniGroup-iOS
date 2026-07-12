//
//  DCShuttleScheduleViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.DCShuttleScheduleViewModel 대응 — 대구캠퍼스 셔틀
//

import Foundation
import Combine

class DCShuttleScheduleViewModel {
    @Published private(set) var isLoading = false

    @Published private(set) var shuttleList = [[String: String]]()

    @Published private(set) var message: String?

    private let scheduleRepository = ScheduleRepository()

    func fetchShuttleSchedule() {
        scheduleRepository.getDCShuttleSchedule { [weak self] result in
            switch result {
            case .loading:
                self?.isLoading = true
            case .success(let shuttleList):
                self?.isLoading = false
                self?.shuttleList = shuttleList
            case .failure(let error):
                self?.isLoading = false
                self?.message = error.localizedDescription
            }
        }
    }
}
