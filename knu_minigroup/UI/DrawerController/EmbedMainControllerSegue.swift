//
//  EmbedMainControllerSegue.swift
//  knu_minigroup
//
//  Created by 홍희표 on 2020/08/31.
//  Copyright © 2020 홍희표. All rights reserved.
//

import UIKit

public class EmbedMainControllerSegue: UIStoryboardSegue {
    final override public func perform() {
        if let sourceViewController = source as? DrawerController {
            sourceViewController.mainViewController = destination
        } else {
            assertionFailure("SourceViewController must be DrawerController!")
        }
    }
}
