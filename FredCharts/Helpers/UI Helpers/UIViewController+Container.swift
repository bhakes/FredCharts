//
//  UIViewController+Container.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 8/25/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import UIKit

extension UIViewController {
    func add(_ child: UIViewController, toView: UIView? = nil) {
        let parentView = toView == nil ? view! : toView!
        addChild(child)
        child.view.constrainToFill(parentView)
        child.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else { return }
        
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

