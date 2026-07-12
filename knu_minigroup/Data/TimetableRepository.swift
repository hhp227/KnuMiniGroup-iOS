//
//  TimetableRepository.swift
//  knu_minigroup
//
//  Android의 data.TimetableRepository 대응 — Local(개인 시간표) + Remote(LMS 학기 시간표)
//

import Foundation

class TimetableRepository {
    private let timetableLocalDataSource = TimetableLocalDataSource()

    private let timetableRemoteDataSource = TimetableRemoteDataSource()

    func getTimetableList(callback: @escaping Callback<[TimetableItem]>) {
        timetableLocalDataSource.getTimetableList(callback: callback)
    }

    func addTimetable(id: Int, subject: String, classroom: String, callback: @escaping Callback<[TimetableItem]>) {
        timetableLocalDataSource.addTimetable(id: id, subject: subject, classroom: classroom, callback: callback)
    }

    func updateTimetable(id: Int, subject: String, classroom: String, callback: @escaping Callback<[TimetableItem]>) {
        timetableLocalDataSource.updateTimetable(id: id, subject: subject, classroom: classroom, callback: callback)
    }

    func deleteTimetable(id: Int, callback: @escaping Callback<[TimetableItem]>) {
        timetableLocalDataSource.deleteTimetable(id: id, callback: callback)
    }

    /*학기 시간표 페이지를 파싱하여 행 단위의 텍스트 리스트로 반환, 첫번째 행은 요일 헤더*/
    func getSemesterTimetableList(cookie: String?, callback: @escaping Callback<[[String]]>) {
        timetableRemoteDataSource.getSemesterTimetableList(cookie: cookie, callback: callback)
    }

    func close() {
        timetableLocalDataSource.close()
    }
}
