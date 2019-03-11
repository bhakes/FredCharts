//
//  Appearance.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/11/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import UIKit

struct Appearance {
    
    // setup Nav Bar Appearance
    static func setupNavAppearance() {
        UINavigationBar.appearance().tintColor = .accentColor
        UINavigationBar.appearance().barTintColor = .darkColor
        UINavigationBar.appearance().largeTitleTextAttributes = [ .foregroundColor: UIColor.accentColor]
        UINavigationBar.appearance().titleTextAttributes = [ .foregroundColor: UIColor.accentColor]
//        UINavigationBar.appearance().prefersLargeTitles = true
        UINavigationBar.appearance().isTranslucent = false
        
    }
    
    // setup SegmentedControlAppearance
    static func setupSegmentedControlAppearance() {
        UISegmentedControl.appearance().tintColor = .accentColor
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkColor], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkAccentColor], for: .normal)
        
    }
    
}

// add UIColor extensions
extension UIColor {
    static let darkColor = UIColor(red: 62/255, green: 80/255, blue: 97/255, alpha: 1)
    static let accentColor = UIColor(red: 170/255, green: 186/255, blue: 202/255, alpha: 1)
    static let darkAccentColor = UIColor(red: 18/255, green: 21/255, blue: 32/255, alpha: 1)
    static let submitColor = UIColor(red: 128/255, green: 143/255, blue: 159/255, alpha: 1)
}

//0x0c1017 0x2f4d76 0x2b2737 0x785442 0xead49f

//0x3e5061 0x121520 0x596b7d 0xaabaca 0x808f9f - blue
