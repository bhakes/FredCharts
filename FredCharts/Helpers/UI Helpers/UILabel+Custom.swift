//
//  UILabel+Custom.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 8/25/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import UIKit

extension UILabel {
    enum LabelType {
        case title, header1, header2, body
    }
    
    static func label(for labelType: LabelType, with string: String? = nil) -> UILabel {
        let label = UILabel()
        label.text = string
        
        switch labelType {
            
        case .title:
            label.font = UIFont.boldSystemFont(ofSize: 48)
        case .header1:
            label.font = UIFont.boldSystemFont(ofSize: 36)
        case .header2:
            label.font = UIFont.boldSystemFont(ofSize: 24)
            label.textColor = .fadedTextColor
        case .body:
            label.font = UIFont.systemFont(ofSize: 17)
            label.textColor = .fadedTextColor
        }
        
        return label
    }
}
