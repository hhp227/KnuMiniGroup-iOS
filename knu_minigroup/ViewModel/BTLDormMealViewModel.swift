//
//  BTLDormMealViewModel.swift
//  knu_minigroup
//
//  Android의 viewmodel.BTLDormMealViewModel 대응 — BTL 기숙사 식단
//

import Foundation
import Combine

class BTLDormMealViewModel {
    @Published private(set) var isLoading = false

    @Published private(set) var mealList = [String]()

    @Published private(set) var message: String?

    private let mealRepository = MealRepository()

    func fetchMealList() {
        mealRepository.getBTLDormMealList { [weak self] result in
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
