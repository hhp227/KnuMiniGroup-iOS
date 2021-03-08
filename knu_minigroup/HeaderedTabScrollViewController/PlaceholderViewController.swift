//
//  PlaceholderViewController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/12/03.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class PlaceholderViewController: UIViewController, UITextViewDelegate {
    let contentText = UITextView()
    
    var placeholderContent: String = "" {
        didSet {
            self.contentText.text = placeholderContent
            
            contentText.sizeToFit()
            // Scroll to top
            contentText.setContentOffset(CGPoint(x: 0, y: -contentText.contentInset.top), animated: false)
        }
    }
    
    var scrollDelegateFunc: ((UIScrollView) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentText.delegate = self
        self.view.addSubview(contentText)
        
        contentText.translatesAutoresizingMaskIntoConstraints = false
        contentText.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentText.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentText.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentText.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentText.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        contentText.isScrollEnabled = true
        contentText.alwaysBounceVertical = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.scrollDelegateFunc != nil {
            self.scrollDelegateFunc!(scrollView)
        }
    }
}
