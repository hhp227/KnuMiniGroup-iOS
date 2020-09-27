//
//  RadioBaseButton.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/27.
//  Copyright © 2020 홍희표. All rights reserved.
//

import Foundation
import UIKit

public enum RadioStyle {
    case rounded(radious: CGFloat), square, circle
}

@IBDesignable
public class RadioBaseButton: UIButton {
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
    public var style: RadioStyle = .circle {
        didSet {
            setUpLayer()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    public convenience init?(type buttonType: UIButton.ButtonType) {
        return nil
    }
    
    internal func setUp() {
        addTarget(self, action: #selector(selectionAction), for: .touchUpInside)
        contentHorizontalAlignment = .left
        addObserverSizeChange()
        setUpLayer()
        
    }

    @objc internal func selectionAction(_ sender: RadioBaseButton) {
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
    
    internal func setUpLayer() {
        updateSelectionState()
    }
    
    internal func updateActiveLayer() {
        
    }
    
    internal func updateInactiveLayer() {
        
    }
    
    internal func callDelegate() {
        
    }
}

extension RadioBaseButton {
    private func addObserverSizeChange() {
        sizeChangeObserver = observe(\RadioBaseButton.frame, changeHandler: sizeChangeObserveHandler)
    }
    
    private func sizeChangeObserveHandler(_ object: RadioBaseButton, _ change: NSKeyValueObservedChange<CGRect>) {
        setUpLayer()
    }
}

internal extension CAShapeLayer {
    func animateStrokeEnd(from: CGFloat, to: CGFloat) {
        self.strokeEnd = from
        self.strokeEnd = to
    }
    
    func animatePath(start: CGPath, end: CGPath) {
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = start
        animation.toValue = end
        animation.isRemovedOnCompletion = true
        
        removeAllAnimations()
        add(animation, forKey: "pathAnimation")
        
    }
}
