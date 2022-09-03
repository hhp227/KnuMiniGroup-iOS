//
//  RadioButton.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2022/09/03.
//  Copyright © 2022 홍희표. All rights reserved.
//

import Foundation
import UIKit

public class RadioButton: RadioCheckboxBaseButton {
    private var outerLayer = CAShapeLayer()
    
    private var innerLayer = RadioLayer()
    
    private var sizeChangeObserver: NSKeyValueObservation?

    public weak var delegate: RadioButtonDelegate?

    public var radioCircle = RadioButtonCircleStyle() {
        didSet { setupLayer() }
    }

    public var radioButtonColor: RadioButtonColor! {
        didSet {
            innerLayer.fillColor = radioButtonColor.active.cgColor
            outerLayer.strokeColor = isOn ? radioButtonColor.active.cgColor : radioButtonColor.inactive.cgColor
        }
    }

    override internal var allowDeselection: Bool {
        return false
    }
    
    override internal func setup() {
        radioButtonColor = RadioButtonColor(active: tintColor, inactive: UIColor.lightGray)
        style = .circle
        super.setup()
    }

    override internal func setupLayer() {
        contentEdgeInsets = UIEdgeInsets(top: 0, left: radioCircle.outer + radioCircle.contentPadding, bottom: 0, right: 0)
        
        func addOuterLayer() {
            outerLayer.strokeColor = radioButtonColor.active.cgColor
            outerLayer.fillColor = UIColor.clear.cgColor
            outerLayer.lineWidth = radioCircle.lineWidth
            outerLayer.path = UIBezierPath.outerCircle(rect: bounds, circle: radioCircle, style: style).cgPath
            
            outerLayer.removeFromSuperlayer()
            layer.insertSublayer(outerLayer, at: 0)
        }
        
        func addInnerLayer() {
            guard let rect = outerLayer.path?.boundingBox else { return }
            innerLayer.fillColor = radioButtonColor.active.cgColor
            innerLayer.strokeColor = UIColor.clear.cgColor
            innerLayer.lineWidth = 0
            innerLayer.activePath = UIBezierPath.innerCircleActive(rect: rect, circle: radioCircle, style: style).cgPath
            innerLayer.inactivePath = UIBezierPath.innerCircleInactive(rect: rect).cgPath
            innerLayer.path = innerLayer.inactivePath
            
            innerLayer.removeFromSuperlayer()
            outerLayer.insertSublayer(innerLayer, at: 0)
        }
        
        addOuterLayer()
        addInnerLayer()
        super.setupLayer()
    }
    
    override internal func callDelegate() {
        if isOn {
            delegate?.onRadioButtonSelect(self)
        }
    }
    
    override internal func updateActiveLayer() {
        super.updateActiveLayer()
        outerLayer.strokeColor = radioButtonColor.active.cgColor
        guard let start = innerLayer.path, let end = innerLayer.activePath else { return }
        innerLayer.path = end
        
        innerLayer.animatePath(start: start, end: end)
    }
    
    override internal func updateInactiveLayer() {
        super.updateInactiveLayer()
        outerLayer.strokeColor = radioButtonColor.inactive.cgColor
        guard let start = innerLayer.path, let end = innerLayer.inactivePath else { return }
        innerLayer.path = end
        
        innerLayer.animatePath(start: start, end: end)
    }
}

private extension UIBezierPath {
    static func outerCircle(rect: CGRect, circle: RadioButtonCircleStyle, style: RadioCheckboxStyle) -> UIBezierPath {
        let size = CGSize(width: circle.outer, height: circle.outer)
        let newRect = CGRect(origin: CGPoint(x: circle.lineWidth / 2, y: rect.size.height / 2 - (circle.outer / 2)), size: size)
        
        switch style {
        case .circle:
            return UIBezierPath(roundedRect: newRect, cornerRadius: size.height / 2)
        case .square:
            return UIBezierPath(rect: newRect)
        case .rounded(let radius):
            return UIBezierPath(roundedRect: newRect, cornerRadius: radius)
        }
    }
    
    static func innerCircleActive(rect: CGRect, circle: RadioButtonCircleStyle, style: RadioCheckboxStyle) -> UIBezierPath {
        let size = CGSize(width: circle.inner, height: circle.inner)
        let origon = CGPoint(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2)
        let newRect = CGRect(origin: origon, size: size)
        
        switch style {
        case .circle:
            return UIBezierPath(roundedRect: newRect, cornerRadius: size.height / 2)
        case .square:
            return UIBezierPath(rect: newRect)
        case .rounded(let radius):
            return UIBezierPath(roundedRect: newRect, cornerRadius: radius)
        }
    }
    
    static func innerCircleInactive(rect: CGRect) -> UIBezierPath {
        let origin = CGPoint(x: rect.midX, y: rect.midY)
        let frame = CGRect(origin: origin, size: CGSize.zero)
        return UIBezierPath(rect: frame)
    }
}

public protocol RadioButtonDelegate: AnyObject {
    func onRadioButtonSelect(_ button: RadioButton)
}

internal class RadioLayer: CAShapeLayer {
    var activePath: CGPath?

    var inactivePath: CGPath?
}
