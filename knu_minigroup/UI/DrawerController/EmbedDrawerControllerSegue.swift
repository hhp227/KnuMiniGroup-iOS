//
//  EmbedDrawerControllerSegue.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/08/31.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

public class EmbedDrawerControllerSegue: UIStoryboardSegue {
    final override public func perform() {
        if let sourceViewController = source as? DrawerController {
            sourceViewController.drawerViewController = destination
        } else {
            assertionFailure("SourceViewController must be DrawerController!")
        }
    }
}
