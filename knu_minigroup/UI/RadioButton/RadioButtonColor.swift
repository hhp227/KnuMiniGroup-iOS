//
//  RadioButtonColor.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2022/09/03.
//  Copyright © 2022 홍희표. All rights reserved.
//

import UIKit

public struct RadioButtonColor {
    let active: UIColor
    
    let inactive: UIColor
    
    public init(active: UIColor, inactive: UIColor) {
        self.active = active
        self.inactive = inactive
    }
}
