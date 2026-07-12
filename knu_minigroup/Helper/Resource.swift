//
//  Resource.swift
//  knu_minigroup
//
//  Android의 helper.Callback(onLoading/onSuccess/onFailure) 대응
//

import Foundation

enum Resource<T> {
    case loading
    case success(T)
    case failure(Error)
}

typealias Callback<T> = (Resource<T>) -> Void

struct AppError: LocalizedError {
    let message: String

    var errorDescription: String? {
        return message
    }
}
