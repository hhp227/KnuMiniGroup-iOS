//
//  RadioCheckboxBaseButton.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2022/09/03.
//  Copyright © 2022 홍희표. All rights reserved.
//

import Foundation
import UIKit

public enum RadioCheckboxStyle {
    case rounded(radius: CGFloat), square, circle
}

@IBDesignable
public class RadioCheckboxBaseButton: UIButton {
    private var sizeChangeObserver: NSKeyValueObservation?

    internal var allowDeselection: Bool {
        return false
    }

    @objc dynamic public var isOn = false {
        didSet {
            if isOn != oldValue {
                updateSelectionState()
                callDelegate()
            }
        }
    }
    
    public var style: RadioCheckboxStyle = .circle {
        didSet {
            setupLayer()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public convenience init?(type buttonType: UIButton.ButtonType) {
        return nil
    }
    
    internal func setup() {
        // Add action here
        addTarget(self, action: #selector(selectionAction), for: .touchUpInside)
        contentHorizontalAlignment = .left
        addObserverSizeChange()
        setupLayer()
    }
    
    @objc internal func selectionAction(_ sender: RadioCheckboxBaseButton) {
        // If toggle enable, change selection state
        if allowDeselection {
            isOn = !isOn
        } else if !isOn {
            isOn = true
        }
    }

    public func updateSelectionState() {
        if isOn {
            updateActiveLayer()
        } else {
            updateInactiveLayer()
        }
    }

    internal func setupLayer() {
        updateSelectionState()
    }
    
    internal func updateActiveLayer() { }
    
    internal func updateInactiveLayer() { }
    
    internal func callDelegate() { }
    
}

extension RadioCheckboxBaseButton {
    private func addObserverSizeChange() {
        sizeChangeObserver = observe(\RadioCheckboxBaseButton.frame, changeHandler: sizeChangeObseveHandler)
    }
    
    private func sizeChangeObseveHandler(_ object: RadioCheckboxBaseButton, _ change: NSKeyValueObservedChange<CGRect>) {
        setupLayer()
    }
}

internal extension CAShapeLayer {
    func animateStrokeEnd(from: CGFloat, to: CGFloat) {
        self.strokeEnd = from
        self.strokeEnd = to
    }
    
    func animatePath(start: CGPath, end: CGPath) {
        removeAllAnimations()
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = start
        animation.toValue = end
        animation.isRemovedOnCompletion = true
        
        add(animation, forKey: "pathAnimation")
    }
}
