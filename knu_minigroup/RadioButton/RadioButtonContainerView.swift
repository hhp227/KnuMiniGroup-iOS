//
//  RadioButtonContainerView.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/28.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

open class RadioButtonContainerView: UIView {
    private var mButtonContainer = RadioButtonContainer()
    public var buttonContainer: RadioButtonContainer {
        return mButtonContainer
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let buttons = subviews
        for case let button as RadioButtonContainer.Kind in buttons {
            addButton(button)
        }
    }
    
    open override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        guard let button = subview as? RadioButtonContainer.Kind else {
            return
        }
        addButton(button)
    }
    
    open override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        guard let button = subview as? RadioButtonContainer.Kind else {
            return
        }
        removeButton(button)
    }

    public func addButton(_ button: RadioButtonContainer.Kind) {
        buttonContainer.addButton(button)
    }
    
    public func removeButton(_ button: RadioButtonContainer.Kind) {
        buttonContainer.removeButton(button)
    }
}
