//
//  RadioCheckboxBaseContainer.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2022/09/03.
//  Copyright © 2022 홍희표. All rights reserved.
//

import Foundation

struct WeakRef<T: RadioCheckboxBaseButton> {
    private var selectionObservation: NSKeyValueObservation?
    
    weak var value: T?
    
    init(_ value: T, handler: @escaping (T, NSKeyValueObservedChange<Bool>) -> Void) {
        self.value = value
        selectionObservation = self.value?.observe(\T.isOn, changeHandler: handler)
    }
}

public class RadioCheckboxBaseContainer<T> where T: RadioCheckboxBaseButton {
    public typealias Kind = T
    
    private var buttonContainer: [WeakRef<T>] = []
    
    public init(_ buttons: [T] = []) {
        addButtons(buttons)
    }

    public var allButtons: [T] {
        return buttonContainer.filter { $0.value != nil }.map { $0.value! }
    }
    
    private func weakRefOf(button: T) -> WeakRef<T>? {
        return buttonContainer.first(where: { $0.value == button })
    }

    public func addButtons(_ buttons: [T]) {
        buttons.forEach { addButton($0) }
    }

    public func deselectAll() {
        allButtons.forEach { $0.isOn = false }
    }

    public var selectedButtons: [T] {
        get {
            return allButtons.filter { $0.isOn }
        }
        set {
            deselectAll()
            for each in newValue {
                let btn = weakRefOf(button: each)
                btn?.value?.isOn = true
            }
        }
    }
    
    public var buttonStyle: RadioCheckboxStyle? {
        didSet {
            guard let newStyle = buttonStyle else { return }
            setEachButtonStyle { _ in return newStyle }
        }
    }
    
    @discardableResult
    public func addButton(_ button: T) -> Bool {
        if weakRefOf(button: button) == nil {
            button.style = buttonStyle ?? button.style
            let newWeakRef = WeakRef<T>(button, handler: selectionChangeObserver)
            
            buttonContainer.append(newWeakRef)
            return true
        }
        return false
    }
    
    @discardableResult
    public func removeButton(_ button: T) -> Bool {
        guard let index = buttonContainer.firstIndex(where: { $0.value == button }) else {
            return false
        }
        buttonContainer.remove(at: index)
        return true
    }

    internal func selectionChangeObserver(_ button: T, _ change: NSKeyValueObservedChange<Bool>) {
    }
    
    public func setEachButtonStyle(_ body: (T) -> RadioCheckboxStyle) {
        allButtons.forEach { button in
            button.style = body(button)
        }
    }

    public func compact() {
        var counter = 0
        
        while counter < buttonContainer.count {
            if buttonContainer[counter].value == nil {
                buttonContainer.remove(at: counter)
            } else {
                counter += 1
            }
        }
    }
}
