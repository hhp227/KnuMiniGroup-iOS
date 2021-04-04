//
//  Toast.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/04/04.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

class Toast: UILabel {
    static var LENGTH_SHORT = 4.0
    static var LENGTH_LONG = 8.0
    
    var duration: TimeInterval = 0
    
    static func makeText(view: UIView, message: String, duration: TimeInterval) -> Toast {
        let toast = Toast(frame: CGRect(x: view.frame.size.width / 2 - 75, y: view.frame.size.height - 100, width: 150, height: 35))
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toast.textColor = UIColor.white
        toast.font = UIFont.systemFont(ofSize: 14.0)
        toast.textAlignment = .center
        toast.text = message
        toast.alpha = 1.0
        toast.layer.cornerRadius = 10
        toast.clipsToBounds = true
        toast.duration = duration
        
        view.addSubview(toast)
        return toast
    }
    
    override func draw(_ rect: CGRect) {
        
    }
    
    func show() {
        UIView.animate(withDuration: duration, delay: 0.1, options: .curveEaseOut, animations: { self.alpha = 0.0 }, completion: { (isCompleted) in self.removeFromSuperview() })
    }
}
