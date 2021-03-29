//
//  MenuItemView.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/12/01.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

class MenuItemView: UIView {
    var titleLabel: UILabel?
    
    var menuItemSeparator: UIView?
    
    func setUpMenuItemView(_ menuItemWidth: CGFloat, menuScrollViewHeight: CGFloat, indicatorHeight: CGFloat, separatorPercentageHeight: CGFloat, separatorWidth: CGFloat, separatorRoundEdges: Bool, menuItemSeparatorColor: UIColor) {
        titleLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: menuItemWidth, height: menuScrollViewHeight - indicatorHeight))
        menuItemSeparator = UIView(frame: CGRect(x: menuItemWidth - (separatorWidth / 2), y: floor(menuScrollViewHeight * ((1.0 - separatorPercentageHeight) / 2.0)), width: separatorWidth, height: floor(menuScrollViewHeight * separatorPercentageHeight)))
        menuItemSeparator!.backgroundColor = menuItemSeparatorColor
        menuItemSeparator!.isHidden = true
        
        if separatorRoundEdges {
            menuItemSeparator!.layer.cornerRadius = menuItemSeparator!.frame.width / 2
        }
        addSubview(menuItemSeparator!)
        addSubview(titleLabel!)
    }
    
    func setTitleText(_ text: NSString) {
        if titleLabel != nil {
            titleLabel!.text = text as String
            titleLabel!.numberOfLines = 0
            
            titleLabel!.sizeToFit()
        }
    }
    
    func configure(for pageMenu: TabLayout, controller: UIViewController, index: CGFloat) {
        if pageMenu.configuration.useMenuLikeSegmentedControl {
            if pageMenu.menuItemMargin > 0 {
                let marginSum = pageMenu.menuItemMargin * CGFloat(pageMenu.controllerArray.count + 1)
                let menuItemWidth = (pageMenu.view.frame.width - marginSum) / CGFloat(pageMenu.controllerArray.count)
                
                setUpMenuItemView(menuItemWidth, menuScrollViewHeight: pageMenu.configuration.menuHeight, indicatorHeight: pageMenu.configuration.selectionIndicatorHeight, separatorPercentageHeight: pageMenu.configuration.menuItemSeparatorPercentageHeight, separatorWidth: pageMenu.configuration.menuItemSeparatorWidth, separatorRoundEdges: pageMenu.configuration.menuItemSeparatorRoundEdges, menuItemSeparatorColor: pageMenu.configuration.menuItemSeparatorColor)
            } else {
                setUpMenuItemView(CGFloat(pageMenu.view.frame.width) / CGFloat(pageMenu.controllerArray.count), menuScrollViewHeight: pageMenu.configuration.menuHeight, indicatorHeight: pageMenu.configuration.selectionIndicatorHeight, separatorPercentageHeight: pageMenu.configuration.menuItemSeparatorPercentageHeight, separatorWidth: pageMenu.configuration.menuItemSeparatorWidth, separatorRoundEdges: pageMenu.configuration.menuItemSeparatorRoundEdges, menuItemSeparatorColor: pageMenu.configuration.menuItemSeparatorColor)
            }
        } else {
            setUpMenuItemView(pageMenu.configuration.menuItemWidth, menuScrollViewHeight: pageMenu.configuration.menuHeight, indicatorHeight: pageMenu.configuration.selectionIndicatorHeight, separatorPercentageHeight: pageMenu.configuration.menuItemSeparatorPercentageHeight, separatorWidth: pageMenu.configuration.menuItemSeparatorWidth, separatorRoundEdges: pageMenu.configuration.menuItemSeparatorRoundEdges, menuItemSeparatorColor: pageMenu.configuration.menuItemSeparatorColor)
        }
        
        titleLabel!.font = pageMenu.configuration.menuItemFont
        titleLabel!.textAlignment = NSTextAlignment.center
        titleLabel!.textColor = pageMenu.configuration.unselectedMenuItemLabelColor
        titleLabel!.adjustsFontSizeToFitWidth = pageMenu.configuration.titleTextSizeBasedOnMenuItemWidth
        
        if controller.title != nil {
            titleLabel!.text = controller.title!
        } else {
            titleLabel!.text = "Menu \(Int(index) + 1)"
        }
        
        // Add separator between menu items when using as segmented control
        if pageMenu.configuration.useMenuLikeSegmentedControl {
            if Int(index) < pageMenu.controllerArray.count - 1 {
                menuItemSeparator!.isHidden = false
            }
        }
    }
}
