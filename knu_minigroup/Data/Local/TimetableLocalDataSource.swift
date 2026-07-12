//
//  TimetableLocalDataSource.swift
//  knu_minigroup
//
//  Android의 data.local.TimetableLocalDataSource(SQLite) 대응 — UserDefaults 기반
//

import Foundation

class TimetableLocalDataSource {
    private static let KEY_TIMETABLE = "timetable_items"

    private let defaults = UserDefaults.standard

    func getTimetableList(callback: @escaping Callback<[TimetableItem]>) {
        callback(.loading)
        callback(.success(fetchTimetableList()))
    }

    func addTimetable(id: Int, subject: String, classroom: String, callback: @escaping Callback<[TimetableItem]>) {
        callback(.loading)
        var timetableList = fetchTimetableList()

        timetableList.removeAll { $0.id == id }
        timetableList.append(TimetableItem(id: id, subject: subject, classroom: classroom))
        store(timetableList)
        callback(.success(fetchTimetableList()))
    }

    func updateTimetable(id: Int, subject: String, classroom: String, callback: @escaping Callback<[TimetableItem]>) {
        callback(.loading)
        var timetableList = fetchTimetableList()

        if let index = timetableList.firstIndex(where: { $0.id == id }) {
            timetableList[index] = TimetableItem(id: id, subject: subject, classroom: classroom)
        }
        store(timetableList)
        callback(.success(fetchTimetableList()))
    }

    func deleteTimetable(id: Int, callback: @escaping Callback<[TimetableItem]>) {
        callback(.loading)
        var timetableList = fetchTimetableList()

        timetableList.removeAll { $0.id == id }
        store(timetableList)
        callback(.success(fetchTimetableList()))
    }

    func close() {
    }

    private func fetchTimetableList() -> [TimetableItem] {
        guard let data = defaults.data(forKey: TimetableLocalDataSource.KEY_TIMETABLE),
              let timetableList = try? JSONDecoder().decode([TimetableItem].self, from: data) else {
            return []
        }
        return timetableList
    }

    private func store(_ timetableList: [TimetableItem]) {
        if let data = try? JSONEncoder().encode(timetableList) {
            defaults.set(data, forKey: TimetableLocalDataSource.KEY_TIMETABLE)
        }
    }
}
