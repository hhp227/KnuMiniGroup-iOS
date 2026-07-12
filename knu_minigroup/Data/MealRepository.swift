//
//  MealRepository.swift
//  knu_minigroup
//
//  Android의 data.MealRepository 대응
//

import Foundation

class MealRepository {
    static let KEY_BREAKFAST = "breakfast"
    static let KEY_LAUNCH = "lunch"
    static let KEY_DINNER = "dinner"

    private let mealRemoteDataSource = MealRemoteDataSource()

    func getStudentMealList(id: Int, callback: @escaping Callback<[(key: String, value: String)]>) {
        mealRemoteDataSource.getStudentMealList(id: id, callback: callback)
    }

    func getBTLDormMealList(callback: @escaping Callback<[String]>) {
        mealRemoteDataSource.getBTLDormMealList(callback: callback)
    }
}
