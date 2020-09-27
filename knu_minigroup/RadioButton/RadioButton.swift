//
//  RadioButton.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/09/28.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

public protocol RadioButtonDelegate: class {
    func radioButtonDidSelect(_ button: RadioButton)
    
    func radioButtonDidDeselect(_ button: RadioButton)
}

internal class RadioLayer: CAShapeLayer {
    var activePath: CGPath?
    var inActivePath: CGPath?
}

public class RadioButton: RadioBaseButton {
    private var outerLayer = CAShapeLayer()
    private var innerLayer = RadioLayer()
    private var sizeChangeObserver: NSKeyValueObservation?
    public weak var delegate: RadioButtonDelegate?
    public var radioCircle = RadioButtonCircleStyle() {
        didSet {
            setUpLayer()
        }
    }
    public var radioButtonColor: RadioButtonColor! {
        didSet {
            innerLayer.fillColor = radioButtonColor.active.cgColor
            outerLayer.strokeColor = isOn ? radioButtonColor.active.cgColor : radioButtonColor.inActive.cgColor
        }
    }
    override internal var allowDeselection: Bool {
        return false
    }
    
    override internal func setUp() {
        radioButtonColor = RadioButtonColor(active: tintColor, inActive: UIColor.lightGray)
        style = .circle
        super.setUp()
    }
    
    override internal func setUpLayer() {
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
            guard let rect = outerLayer.path?.boundingBox else {
                return
            }
            innerLayer.fillColor = radioButtonColor.active.cgColor
            innerLayer.strokeColor = UIColor.clear.cgColor
            innerLayer.lineWidth = 0
            innerLayer.activePath = UIBezierPath.innerCircleActive(rect: rect, circle: radioCircle, style: style).cgPath
            innerLayer.inActivePath = UIBezierPath.innerCircleInactive(rect: rect).cgPath
            innerLayer.path = innerLayer.inActivePath
            
            innerLayer.removeFromSuperlayer()
            outerLayer.insertSublayer(innerLayer, at: 0)
        }
        
        addOuterLayer()
        addInnerLayer()
        super.setUpLayer()
    }
    
    override internal func callDelegate() {
        if isOn {
            delegate?.radioButtonDidSelect(self)
        } else {
            delegate?.radioButtonDidDeselect(self)
        }
    }
    
    override internal func updateActiveLayer() {
        super.updateActiveLayer()
        outerLayer.strokeColor = radioButtonColor.active.cgColor
        
        guard let start = innerLayer.path, let end = innerLayer.activePath else {
            return
        }
        
        innerLayer.animatePath(start: start, end: end)
        
        innerLayer.path = end
    }
    
    override internal func updateInactiveLayer() {
        super.updateInactiveLayer()
        outerLayer.strokeColor = radioButtonColor.inActive.cgColor
        
        guard let start = innerLayer.path, let end = innerLayer.inActivePath else {
            return
        }
        
        innerLayer.animatePath(start: start, end: end)
        
        innerLayer.path = end
    }
}

private extension UIBezierPath {
    static func outerCircle(rect: CGRect, circle: RadioButtonCircleStyle, style: RadioStyle) -> UIBezierPath {
        let size = CGSize(width: circle.inner, height: circle.inner)
        let origin = CGPoint(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2)
        let newRect = CGRect(origin: origin, size: size)
        
        switch style {
        case .circle:
            return UIBezierPath(roundedRect: newRect, cornerRadius: size.height / 2)
        case .square:
            return UIBezierPath(rect: newRect)
        case .rounded(let radius):
            return UIBezierPath(roundedRect: newRect, cornerRadius: radius)
        }
    }
    
    static func innerCircleActive(rect: CGRect, circle: RadioButtonCircleStyle, style: RadioStyle) -> UIBezierPath {
        let size = CGSize(width: circle.inner, height: circle.inner)
        let origin = CGPoint(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2)
        let newRect = CGRect(origin: origin, size: size)
        
        switch style {
        case .circle:
            return UIBezierPath(roundedRect: newRect, cornerRadius: size.height / 2)
        case .square:
            return UIBezierPath(rect: newRect)
        case .rounded(let radious):
            return UIBezierPath(roundedRect: newRect, cornerRadius: radious)
        }
    }
    
    static func innerCircleInactive(rect: CGRect) -> UIBezierPath {
        let origin = CGPoint(x: rect.midX, y: rect.midY)
        let frame = CGRect(origin: origin, size: CGSize.zero)
        return UIBezierPath(rect: frame)
    }
}
