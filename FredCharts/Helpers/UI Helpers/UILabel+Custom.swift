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
        case title, header1, header2, body, caption1, caption2
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
        case .body:
            label.font = UIFont.systemFont(ofSize: 18)
        case .caption1:
            label.font = UIFont.systemFont(ofSize: 14)
        case .caption2:
            label.font = UIFont.systemFont(ofSize: 10)
        }
        
        return label
    }
}
