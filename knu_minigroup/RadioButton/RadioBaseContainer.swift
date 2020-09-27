//
//  RadioBaseContainer.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/28.
//  Copyright © 2020 홍희표. All rights reserved.
//

import Foundation

struct WeakRef<T: RadioBaseButton> {
    private var selectionObservation: NSKeyValueObservation?
    weak var value: T?
    
    init(_ value: T, handler: @escaping (T, NSKeyValueObservedChange<Bool>) -> Void) {
        self.value = value
        selectionObservation = self.value?.observe(\T.isOn, changeHandler: handler)
    }
}

public class RadioBaseContainer<T> where T: RadioBaseButton {
    public typealias Kind = T
    private var buttonContainer: [WeakRef<T>] = []
    public var allButtons: [T] {
        return buttonContainer.filter { $0.value != nil }.map { $0.value! }
    }
    public var selectButtons: [T] {
        get {
            return allButtons.filter { $0.isOn }
        }
        set {
            deSelectAll()
            newValue.forEach { weakRefOf(button: $0)?.value?.isOn = true }
        }
    }
    public var buttonStyle: RadioStyle? {
        didSet {
            guard let newStyle = buttonStyle else {
                return
            }
            
            setEachButtonStyle { _ in return newStyle }
        }
    }
    
    public init(_ buttons: [T] = []) {
        addButtons(buttons)
    }
    
    private func weakRefOf(button: T) -> WeakRef<T>? {
        return buttonContainer.first(where: { $0.value == button })
    }
    
    public func addButtons(_ buttons: [T]) {
        buttons.forEach { addButton($0) }
    }
    
    public func deSelectAll() {
        allButtons.forEach { $0.isOn = false }
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
    
    public func setEachButtonStyle(_ body: (T) -> RadioStyle) {
        allButtons.forEach { $0.style = body($0) }
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
