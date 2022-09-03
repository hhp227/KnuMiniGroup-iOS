//
//  RadioButtonContainer.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2022/09/03.
//  Copyright © 2022 홍희표. All rights reserved.
//

import Foundation

public class RadioButtonContainer: RadioCheckboxBaseContainer<RadioButton> {
    public weak var delegate: RadioButtonDelegate? {
        didSet {
            allButtons.forEach { $0.delegate = delegate }
        }
    }
    
    public var selectedButton: Kind? {
        get { return selectedButtons.first }
        set {
            guard let button = newValue else {
                deselectAll()
                return
            }
            selectedButtons = [button]
        }
    }
    
    public var radioButtonColor: RadioButtonColor? {
        didSet {
            guard let color = radioButtonColor else { return }
            setEachRadioButtonColor { _ in return color }
        }
    }

    public var radioCircleStyle: RadioButtonCircleStyle? {
        didSet {
            guard let style = radioCircleStyle else { return }
            setEachRadioButtonCircleStyle { _ in return style }
        }
    }
    
    @discardableResult
    public override func addButton(_ button: Kind) -> Bool {
        button.delegate = delegate
        return super.addButton(button)
    }
    
    override func selectionChangeObserver(_ radioButton: RadioButton, _ change: NSKeyValueObservedChange<Bool>) {
        super.selectionChangeObserver(radioButton, change)
        if radioButton.isOn {
            allButtons.forEach { button in
                if button.isOn, radioButton != button {
                    button.isOn = false
                }
            }
        }
    }
    
    public func setEachRadioButtonColor(_ body: (Kind) -> RadioButtonColor) {
        allButtons.forEach { button in
            button.radioButtonColor = body(button)
        }
    }

    public func setEachRadioButtonCircleStyle(_ body: (Kind) -> RadioButtonCircleStyle) {
        allButtons.forEach { button in
            button.radioCircle = body(button)
        }
    }
}
