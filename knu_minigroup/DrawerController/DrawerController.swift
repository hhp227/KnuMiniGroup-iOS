//
//  DrawerController.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/08/30.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

open class DrawerController: UIViewController, UIGestureRecognizerDelegate {
    @objc public enum DrawerDirection: Int {
        case left, right
    }
    
    @objc public enum DrawerState: Int {
        case opened, closed
    }

    @IBInspectable public var containerViewMaxAlpha: CGFloat = 0.2
    
    @IBInspectable public var drawerAnimationDuration: TimeInterval = 0.25
    
    @IBInspectable public var mainSegueIdentifier: String?
    
    @IBInspectable public var drawerSegueIdentifier: String?
    
    private var drawerConstraint: NSLayoutConstraint!
    
    private var drawerWidthConstraint: NSLayoutConstraint!
    
    private var panStartLocation = CGPoint.zero
    
    private var panDelta: CGFloat = 0
    
    private lazy var containerView: UIView = {
        let view = UIView(frame: self.view.frame)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.0, alpha: 0)
        
        view.addGestureRecognizer(self.containerViewTapGesture)
        return view
    }()
    
    private var isAppearing: Bool?
    
    public var screenEdgePanGestureEnabled = true
    
    public private(set) lazy var screenEdgePanGesture: UIScreenEdgePanGestureRecognizer = {
        let gesture = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(DrawerController.handlePanGesture(_:))
        )
        
        switch self.drawerDirection {
        case .left:
            gesture.edges = .left
        case .right:
            gesture.edges = .right
        }
        
        gesture.delegate = self
        return gesture
    }()
    
    public private(set) lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(DrawerController.handlePanGesture(_:))
        )
        gesture.delegate = self
        return gesture
    }()
    
    public private(set) lazy var containerViewTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(DrawerController.didtapContainerView(_:))
        )
        gesture.delegate = self
        return gesture
    }()
    
    public weak var delegate: DrawerControllerDelegate?
    
    public var drawerDirection: DrawerDirection = .left {
        didSet {
            switch drawerDirection {
            case .left:
                screenEdgePanGesture.edges = .left
            case .right:
                screenEdgePanGesture.edges = .right
            }
            
            let temp = drawerViewController
            drawerViewController = temp
        }
    }
    
    public var drawerState: DrawerState {
        get { return containerView.isHidden ? .closed : .opened }
        set { setDrawerState(newValue, animated: false) }
    }
    
    @IBInspectable public var drawerWidth: CGFloat = 280 {
        didSet { drawerWidthConstraint.constant = drawerWidth }
    }
    
    public var displayingViewController: UIViewController? {
        switch drawerState {
        case .closed:
            return mainViewController
        case .opened:
            return drawerViewController
        }
    }
    
    public var mainViewController: UIViewController! {
        didSet {
            let isVisible = (drawerState == .closed)
            
            if let oldController = oldValue {
                oldController.willMove(toParent: nil)
                if isVisible {
                    oldController.beginAppearanceTransition(false, animated: false)
                }
                oldController.view.removeFromSuperview()
                if isVisible {
                    oldController.endAppearanceTransition()
                }
                oldController.removeFromParent()
            }

            guard let mainViewController = mainViewController else { return }
            
            addChild(mainViewController)
            if isVisible {
                mainViewController.beginAppearanceTransition(true, animated: false)
            }

            mainViewController.view.translatesAutoresizingMaskIntoConstraints = false
            
            view.insertSubview(mainViewController.view, at: 0)

            let viewDictionary = ["mainView" : mainViewController.view!]
            
            view.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "V:|-0-[mainView]-0-|",
                    options: [],
                    metrics: nil,
                    views: viewDictionary
                )
            )
            view.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|-0-[mainView]-0-|",
                    options: [],
                    metrics: nil,
                    views: viewDictionary
                )
            )
            if isVisible {
                mainViewController.endAppearanceTransition()
            }
            mainViewController.didMove(toParent: self)
        }
    }
    
    public var drawerViewController: UIViewController? {
        didSet {
            let isVisible = (drawerState == .opened)
            
            if let oldController = oldValue {
                oldController.willMove(toParent: nil)
                if isVisible {
                    oldController.beginAppearanceTransition(false, animated: false)
                }
                oldController.view.removeFromSuperview()
                if isVisible {
                    oldController.endAppearanceTransition()
                }
                oldController.removeFromParent()
            }
            
            guard let drawerViewController = drawerViewController else { return }
            
            addChild(drawerViewController)
            if isVisible {
                drawerViewController.beginAppearanceTransition(true, animated: false)
            }
            
            drawerViewController.view.layer.shadowColor = UIColor.black.cgColor
            drawerViewController.view.layer.shadowOpacity = 0.4
            drawerViewController.view.layer.shadowRadius = 5.0
            drawerViewController.view.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.addSubview(drawerViewController.view)
            
            let itemAttribute: NSLayoutConstraint.Attribute
            let toItemAttribute: NSLayoutConstraint.Attribute
            
            switch drawerDirection {
            case .left:
                itemAttribute = .right
                toItemAttribute = .left
            case .right:
                itemAttribute = .left
                toItemAttribute = .right
            }
            
            drawerWidthConstraint = NSLayoutConstraint(
                item: drawerViewController.view,
                attribute: NSLayoutConstraint.Attribute.width,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: nil,
                attribute: NSLayoutConstraint.Attribute.width,
                multiplier: 1,
                constant: drawerWidth
            )
            drawerConstraint = NSLayoutConstraint(
                item: drawerViewController.view,
                attribute: itemAttribute,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: containerView,
                attribute: toItemAttribute,
                multiplier: 1,
                constant: 0
            )
            
            drawerViewController.view.addConstraint(drawerWidthConstraint)
            containerView.addConstraint(drawerConstraint)
            
            let viewDictionary = ["drawerView" : drawerViewController.view!]
            
            containerView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[drawerView]-0-|",
                options: [],
                metrics: nil,
                views: viewDictionary
            ))
            containerView.layoutIfNeeded()
            if isVisible {
                drawerViewController.endAppearanceTransition()
            }
            drawerViewController.didMove(toParent: self)
        }
    }

    public init(drawerDirection: DrawerDirection, drawerWidth: CGFloat) {
        super.init(nibName: nil, bundle: nil)
        self.drawerDirection = drawerDirection
        self.drawerWidth = drawerWidth
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        let viewDictionary = ["containerView" : containerView]
        
        view.addGestureRecognizer(screenEdgePanGesture)
        view.addGestureRecognizer(panGesture)
        view.addSubview(containerView)
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-0-[containerView]-0-|",
            options: [],
            metrics: nil,
            views: viewDictionary
        ))
        view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-0-[containerView]-0-|",
            options: [],
            metrics: nil,
            views: viewDictionary
        ))
        containerView.isHidden = true
        
        if let mainSegueId = mainSegueIdentifier {
            performSegue(withIdentifier: mainSegueId, sender: self)
        }
        if let drawerSegueId = drawerSegueIdentifier {
            performSegue(withIdentifier: drawerSegueId, sender: self)
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayingViewController?.beginAppearanceTransition(true, animated: animated)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayingViewController?.endAppearanceTransition()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayingViewController?.beginAppearanceTransition(false, animated: animated)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        displayingViewController?.endAppearanceTransition()
    }

    override open var shouldAutomaticallyForwardAppearanceMethods: Bool {
        get {
            return false
        }
    }

    public func setDrawerState(_ state: DrawerState, animated: Bool) {
        delegate?.drawerController?(self, willChangeState: state)
        
        containerView.isHidden = false
        let duration: TimeInterval = animated ? drawerAnimationDuration : 0
        let isAppearing = state == .opened
        
        if self.isAppearing != isAppearing {
            self.isAppearing = isAppearing
            
            drawerViewController?.beginAppearanceTransition(isAppearing, animated: animated)
            mainViewController.beginAppearanceTransition(!isAppearing, animated: animated)
        }
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .curveEaseOut,
            animations: { () -> Void in
                switch state {
                case .closed:
                    self.drawerConstraint.constant = 0
                    self.containerView.backgroundColor = UIColor(white: 0, alpha: 0)
                case .opened:
                    let constant: CGFloat
                    switch self.drawerDirection {
                    case .left:
                        constant = self.drawerWidth
                    case .right:
                        constant = self.drawerWidth
                    }
                    
                    self.drawerConstraint.constant = constant
                    self.containerView.backgroundColor = UIColor(white: 0, alpha: self.containerViewMaxAlpha)
                }
                self.containerView.layoutIfNeeded()
        }) { (finished: Bool) -> Void in
            if state == .closed {
                self.containerView.isHidden = true
            }
            self.drawerViewController?.endAppearanceTransition()
            self.mainViewController?.endAppearanceTransition()
            
            self.isAppearing = nil
            
            if let didChangeState = self.delegate?.drawerController(_:didChangeState:) {
                didChangeState(self, state)
            } else {
                self.delegate?.drawerController?(self, stateChanged: state)
            }
        }
    }
    
    @objc final func handlePanGesture(_ sender: UIGestureRecognizer) {
        containerView.isHidden = false
        
        if sender.state == .began {
            panStartLocation = sender.location(in: view)
        }
        
        let delta = CGFloat(sender.location(in: view).x - panStartLocation.x)
        let constant: CGFloat
        let backgroundAlpha: CGFloat
        let drawerState: DrawerState
        
        switch drawerDirection {
        case .left:
            drawerState = panDelta <= 0 ? .closed : .opened
            constant = min(drawerConstraint.constant + delta, drawerWidth)
            backgroundAlpha = min(
                containerViewMaxAlpha,
                containerViewMaxAlpha * (abs(constant) / drawerWidth)
            )
        case .right:
            drawerState = panDelta >= 0 ? .closed : .opened
            constant = max(drawerConstraint.constant + delta, -drawerWidth)
            backgroundAlpha = min(
                containerViewMaxAlpha,
                containerViewMaxAlpha * (abs(constant) / drawerWidth)
            )
        }
        
        drawerConstraint.constant = constant
        containerView.backgroundColor = UIColor(white: 0, alpha: backgroundAlpha)
        
        switch sender.state {
        case .changed:
            let isAppearing = drawerState != .opened
            
            if self.isAppearing == nil {
                self.isAppearing = isAppearing
                drawerViewController?.beginAppearanceTransition(isAppearing, animated: true)
                mainViewController?.beginAppearanceTransition(!isAppearing, animated: true)
            }
            
            panStartLocation = sender.location(in: view)
            panDelta = delta
        case .ended, .cancelled:
            setDrawerState(drawerState, animated: true)
        default:
            break
        }
    }
    
    @objc final func didtapContainerView(_ gesture: UITapGestureRecognizer) {
        setDrawerState(.closed, animated: true)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        switch gestureRecognizer {
        case panGesture:
            return drawerState == .opened
        case screenEdgePanGesture:
            return screenEdgePanGestureEnabled ? drawerState == .closed : false
        default:
            return touch.view == gestureRecognizer.view
        }
    }
}

@objc public protocol DrawerControllerDelegate {
    @objc optional func drawerController(_ drawerController: DrawerController, willChangeState state: DrawerController.DrawerState)
    
    @objc optional func drawerController(_ drawerController: DrawerController, didChangeState state: DrawerController.DrawerState)
    
    @available(*, deprecated, renamed: "drawerController(_:didChangeState:)")
    @objc optional func drawerController(_ drawerController: DrawerController, stateChanged state: DrawerController.DrawerState)
}
