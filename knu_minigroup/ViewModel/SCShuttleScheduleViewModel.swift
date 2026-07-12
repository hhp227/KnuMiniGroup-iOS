//
//  SCShuttleScheduleViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.SCShuttleScheduleViewModel 대응 — 상주캠퍼스 셔틀
//

import Foundation
import Combine

class SCShuttleScheduleViewModel {
    @Published private(set) var isLoading = false

    @Published private(set) var shuttleList = [[String: String]]()

    @Published private(set) var headers = [String]()

    @Published private(set) var message: String?

    private let scheduleRepository = ScheduleRepository()

    func fetchShuttleSchedule() {
        scheduleRepository.getSCShuttleSchedule { [weak self] result in
            switch result {
            case .loading:
                self?.isLoading = true
            case .success(let data):
                self?.isLoading = false
                self?.shuttleList = data.list
                self?.headers = data.headers
            case .failure(let error):
                self?.isLoading = false
                self?.message = error.localizedDescription
            }
        }
    }
}
