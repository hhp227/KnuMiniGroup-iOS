//
//  RadioButtonCircleStyle.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/28.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

public struct RadioButtonCircleStyle {
    let outer: CGFloat
    let inner: CGFloat
    let lineWidth: CGFloat
    let contentPadding: CGFloat
    
    public init(outerCircle: CGFloat = 16, innerCircle: CGFloat = 7, outerCircleBorder: CGFloat = 2, contentPadding: CGFloat = 6) {
        self.outer = outerCircle
        self.inner = innerCircle
        self.lineWidth = outerCircleBorder
        self.contentPadding = contentPadding
    }
    
    public init(outerCircle: CGFloat, innerCircle: CGFloat) {
        self.init(outerCircle: outerCircle, innerCircle: innerCircle, outerCircleBorder: 2, contentPadding: 6)
    }
    
    public init(outerCircle: CGFloat, innerCircle: CGFloat, outerCircleBorder: CGFloat) {
        self.init(outerCircle: outerCircle, innerCircle: innerCircle, outerCircleBorder: outerCircleBorder, contentPadding: 6)
    }
}
