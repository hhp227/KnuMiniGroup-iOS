//
//  ScheduleRepository.swift
//  knu_minigroup
//
//  Android의 data.ScheduleRepository 대응
//

import Foundation

class ScheduleRepository {
    private let scheduleRemoteDataSource = ScheduleRemoteDataSource()

    func getDCShuttleSchedule(callback: @escaping Callback<[[String: String]]>) {
        scheduleRemoteDataSource.getDCShuttleSchedule(callback: callback)
    }

    func getSCShuttleSchedule(callback: @escaping Callback<(list: [[String: String]], headers: [String])>) {
        scheduleRemoteDataSource.getSCShuttleSchedule(callback: callback)
    }
}
