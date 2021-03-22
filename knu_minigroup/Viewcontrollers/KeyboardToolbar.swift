//
//  KeyboardToolbar.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2021/03/22.
//  Copyright © 2021 홍희표. All rights reserved.
//

import UIKit

class KeyboardToolbar: UIToolbar {
    private weak var toolBarDelegate: KeyboardToolbarDelegate?
    
    private weak var textField: UITextField!
    
    init(for textField: UITextField, toolBarDelegate: KeyboardToolbarDelegate) {
        super.init(frame: .init(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 44)))
        barStyle = .default
        isTranslucent = true
        self.textField = textField
        self.toolBarDelegate = toolBarDelegate
        textField.inputAccessoryView = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUp(leftButtons: [KeyboardToolbarButton], rightButtons: [KeyboardToolbarButton]) {
        let leftBarButtons = leftButtons.map { $0.createButton(target: self, action: #selector(buttonTapped)) }
        let rightBarButtons = rightButtons.map { $0.createButton(target: self, action: #selector(buttonTapped(sender:))) }
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        setItems(leftBarButtons + [spaceButton] + rightBarButtons, animated: false)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @objc func buttonTapped(sender: UIBarButtonItem) {
        guard let type = KeyboardToolbarButton.detectType(barButton: sender) else {
            return
        }
        toolBarDelegate?.keyboardToolbar(button: sender, type: type, isInputAccessoryViewOf: textField)
    }

}

enum KeyboardToolbarButton: Int {
    case done = 0
    case cancel
    case back, backDisabled
    case forward, forwardDisabled
    
    func createButton(target: Any?, action: Selector?) -> UIBarButtonItem {
        var button: UIBarButtonItem!
        
        switch self {
        case .back:
            button = .init(title: "back", style: .plain, target: target, action: action)
        case .backDisabled:
            button = .init(title: "back", style: .plain, target: target, action: action)
            button.isEnabled = false
        case .forward:
            button = .init(title: "forward", style: .plain, target: target, action: action)
        case .forwardDisabled:
            button = .init(title: "forward", style: .plain, target: target, action: action)
            button.isEnabled = false
        case .done:
            button = .init(title: "done", style: .plain, target: target, action: action)
        case .cancel:
            button = .init(title: "cancel", style: .plain, target: target, action: action)
        }
        button.tag = rawValue
        return button
    }
    
    static func detectType(barButton: UIBarButtonItem) -> KeyboardToolbarButton? {
        return KeyboardToolbarButton(rawValue: barButton.tag)
    }
}

protocol KeyboardToolbarDelegate: class {
    func keyboardToolbar(button: UIBarButtonItem, type: KeyboardToolbarButton, isInputAccessoryViewOf textField: UITextField)
}

extension UITextField {
    func addKeyboardToolBar(leftButtons: [KeyboardToolbarButton], rightButtons: [KeyboardToolbarButton], toolBarDelegate: KeyboardToolbarDelegate) {
        let toolBar = KeyboardToolbar(for: self, toolBarDelegate: toolBarDelegate)
        toolBar.setUp(leftButtons: leftButtons, rightButtons: rightButtons)
    }
}
