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
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().barTintColor = .mainColor
        UINavigationBar.appearance().largeTitleTextAttributes = [ .foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [ .foregroundColor: UIColor.white]
//        UINavigationBar.appearance().prefersLargeTitles = true
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().layer.masksToBounds = false
        UINavigationBar.appearance().layer.shadowColor = UIColor.black.cgColor
        UINavigationBar.appearance().layer.shadowOpacity = 0.5
        UINavigationBar.appearance().layer.shadowOffset = CGSize(width: 0, height: 4.0)
        UINavigationBar.appearance().layer.shadowRadius = 4
        
    }
    
    // setup SegmentedControlAppearance
    static func setupSegmentedControlAppearance() {
        UISegmentedControl.appearance().tintColor = .mainColor
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.mainColor], for: .normal)
        
    }
    
}

// add UIColor extensions
extension UIColor {
    static let mainColor = #colorLiteral(red: 0.2431372549, green: 0.3137254902, blue: 0.3803921569, alpha: 1)
    static let darkAccentColor = #colorLiteral(red: 0.07058823529, green: 0.08235294118, blue: 0.1254901961, alpha: 1)
    static let lightAccentColor = #colorLiteral(red: 0.6666666667, green: 0.7294117647, blue: 0.7921568627, alpha: 1)
    static let darkAccentColor2 = #colorLiteral(red: 0.3490196078, green: 0.4196078431, blue: 0.4901960784, alpha: 1)
    static let lightAccentColor2 = #colorLiteral(red: 0.5019607843, green: 0.5607843137, blue: 0.6235294118, alpha: 1)

}

//0x0c1017 0x2f4d76 0x2b2737 0x785442 0xead49f

//0x3e5061 0x121520 0x596b7d 0xaabaca 0x808f9f - blue
