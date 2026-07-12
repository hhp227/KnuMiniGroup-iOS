//
//  UIViewToast.swift
//  knu_minigroup
//
//  기존 UI/Toast.swift를 간편하게 쓰기 위한 확장
//

import UIKit

extension UIView {
    func makeToast(message: String, duration: TimeInterval = 2.0) {
        Toast.makeText(view: self, message: message, duration: duration).show()
    }
}
