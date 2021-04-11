//
//  TextViewExtension.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/03/25.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

class UITextViewExtension: UITextView {
    @IBInspectable public var isAnimate: Bool = true

    @IBInspectable public var maxLength: Int = 0
    
    @IBInspectable public var minHeight: CGFloat = 0
    
    @IBInspectable public var maxHeight: CGFloat = 0
    
    @IBInspectable public var cornerRadius: CGFloat = 0

    @IBInspectable public var placeHolder: String? {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable public var placeHolderColor: UIColor = UIColor(white: 0.8, alpha: 1.0) {
        didSet { setNeedsDisplay() }
    }

    private weak var heightConstraint: NSLayoutConstraint?

    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        let height = checkHeightConstraint()
        heightConstraint?.constant = height
        layer.cornerRadius = cornerRadius
        
        if isAnimate {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: { [weak self] in
                guard let self = self, let delegate = self.delegate as? UITextViewExtensionDelegate else { return }
                delegate.increaseHeight?(textView: self, willChangeHeight: height)
                self.scrollToBottom()
            }) { [weak self] _ in
                guard let self = self, let delegate = self.delegate as? UITextViewExtensionDelegate else { return }
                delegate.increaseHeight?(textView: self, didChangeHeight: height)
            }
        } else {
            guard let delegate = delegate as? UITextViewExtensionDelegate else { return }
            delegate.increaseHeight?(textView: self, willChangeHeight: height)
            self.scrollToBottom()
            delegate.increaseHeight?(textView: self, didChangeHeight: height)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if text.isEmpty {
            let xValue = textContainerInset.left + textContainer.lineFragmentPadding
            let yValue = textContainerInset.top
            let width = rect.size.width - xValue - textContainerInset.right
            let height = rect.size.height - yValue - textContainerInset.bottom
            let placeHolderRect = CGRect(x: xValue, y: yValue, width: width, height: height)
            
            guard let gc = UIGraphicsGetCurrentContext() else { return }
            gc.saveGState()
            defer { gc.restoreGState() }
            placeHolder?.draw(in: placeHolderRect, withAttributes: getPlaceHolderAttribues())
        }
    }
    
    @objc private func textDidEndEditing(notification: Notification) {
        scrollToBottom()
    }
    
    @objc private func textDidChange(notification: Notification) {
        if let sender = notification.object as? UITextViewExtension, sender == self {
            if maxLength > 0 && text.count > maxLength {
                let endIndex = text.index(text.startIndex, offsetBy: maxLength)
                text = String(text[..<endIndex])
                
                undoManager?.removeAllActions()
            }
            setNeedsDisplay()
        }
    }
    
    private func commonInit() {
        contentMode = .redraw
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing), name: UITextView.textDidEndEditingNotification, object: self)
    }
    
    private func checkHeightConstraint() -> CGFloat {
        let height = getHieght()
        
        if heightConstraint == nil {
            heightConstraint = self.heightAnchor.constraint(equalToConstant: height)
            
            addConstraint(heightConstraint!)
        }
        return height
    }
    
    private func getHieght() -> CGFloat {
        let size = sizeThatFits(CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
        var height = size.height
        height = minHeight > 0 ? max(height, minHeight) : height
        height = maxHeight > 0 ? min(height, maxHeight) : height
        return height
    }
    
    private func scrollToBottom() {
        let bottom = self.contentSize.height - self.bounds.size.height
        
        setContentOffset(CGPoint(x: 0, y: bottom), animated: false)
    }
    
    private func getPlaceHolderAttribues() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: placeHolderColor,
            .paragraphStyle: paragraphStyle
        ]
        attributes[.font] = self.font
        return attributes
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

@objc public protocol UITextViewExtensionDelegate: UITextViewDelegate {
    @objc optional func increaseHeight(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    
    @objc optional func increaseHeightShouldReturn(textView: UITextView)
    
    @objc optional func increaseHeight(textView: UITextView, willChangeHeight height: CGFloat)
    
    @objc optional func increaseHeight(textView: UITextView, didChangeHeight height: CGFloat)
}

extension UITextViewExtension: UITextViewExtensionDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard textView.hasText || text != "" else { return false }
        if let delegate = delegate as? UITextViewExtensionDelegate {
            guard let value = delegate.increaseHeight?(textView: self, shouldChangeTextInRange: range, replacementText: text) else { return false }
            return value
        }
        if text == "\n" {
            if let delegate = delegate as? UITextViewExtensionDelegate {
                delegate.increaseHeightShouldReturn?(textView: self)
                return true
            } else {
                textView.resignFirstResponder()
                return false
            }
        }
        return true
    }
}
