//
//  RadioButtonContainer.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/28.
//  Copyright © 2020 홍희표. All rights reserved.
//

import Foundation

public class RadioButtonContainer: RadioBaseContainer<RadioButton> {
    public weak var delegate: RadioButtonDelegate? {
        didSet {
            allButtons.forEach { b -> Void in b.delegate = delegate }
        }
    }
    public var selectedButton: Kind? {
        get {
            return selectButtons.first
        }
        set {
            guard let button = newValue else {
                deSelectAll()
                return
            }
            selectButtons = [button]
        }
    }
    public var radioButtonColor: RadioButtonColor? {
        didSet {
            guard let color = radioButtonColor else {
                return
            }
            setEachRadioButtonColor { _ in return color }
        }
    }
    public var radioCircleStyle: RadioButtonCircleStyle? {
        didSet {
            guard let style = radioCircleStyle else {
                return
            }
            setEachRadioButtonCircleStyle { _ in return style }
        }
    }
    
    @discardableResult
    public override func addButton(_ button: Kind) -> Bool {
        button.delegate = delegate
        return super.addButton(button)
    }
    
    override func selectionChangeObserver(_ button: RadioButton, _ change: NSKeyValueObservedChange<Bool>) {
        super.selectionChangeObserver(button, change)
        if button.isOn {
            allButtons.forEach {
                if $0.isOn, button != $0 {
                    $0.isOn = false
                }
            }
        }
    }
    
    public func setEachRadioButtonColor(_ body: (Kind) -> RadioButtonColor) {
        allButtons.forEach { $0.radioButtonColor = body($0) }
    }
    
    public func setEachRadioButtonCircleStyle(_ body: (Kind) -> RadioButtonCircleStyle) {
        allButtons.forEach { $0.radioCircle = body($0) }
    }

}
