//
//  RadioButtonContainerView.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2022/09/03.
//  Copyright © 2022 홍희표. All rights reserved.
//

import Foundation
import UIKit

open class RadioButtonContainerView: UIView {
    private var _buttonContainer = RadioButtonContainer()

    public var buttonContainer: RadioButtonContainer {
        return _buttonContainer
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for case let button as RadioButtonContainer.Kind in subviews {
            addButton(button)
        }
    }

    open override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        guard let button = subview as? RadioButtonContainer.Kind else { return }
        addButton(button)
    }

    open override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        guard let button = subview as? RadioButtonContainer.Kind else { return }
        removeButton(button)
    }
    
    public func addButton(_ button: RadioButtonContainer.Kind) {
        buttonContainer.addButton(button)
    }
    
    public func removeButton(_ view: RadioButtonContainer.Kind) {
        buttonContainer.removeButton(view)
    }
}
