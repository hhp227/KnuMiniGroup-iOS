//
//  StudentMealViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.StudentMealViewModel 대응 — 학생식당 식단
//

import Foundation
import Combine

class StudentMealViewModel {
    static let KEY_BREAKFAST = MealRepository.KEY_BREAKFAST
    static let KEY_LAUNCH = MealRepository.KEY_LAUNCH
    static let KEY_DINNER = MealRepository.KEY_DINNER

    @Published private(set) var isLoading = false

    @Published private(set) var mealList = [(key: String, value: String)]()

    @Published private(set) var message: String?

    private let mealRepository = MealRepository()

    func fetchMealList(id: Int) {
        mealRepository.getStudentMealList(id: id) { [weak self] result in
            switch result {
            case .loading:
                self?.isLoading = true
            case .success(let mealList):
                self?.isLoading = false
                self?.mealList = mealList
            case .failure(let error):
                self?.isLoading = false
                self?.message = error.localizedDescription
            }
        }
    }
}
