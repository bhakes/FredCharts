//
//  NumberFormatter+Convenience.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/13/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation

extension NumberFormatter {
    
    static func getNumberFormatter(with seriesUnits: String)-> NumberFormatter{
        
        let numberFormatter = NumberFormatter()
        
        if seriesUnits == "Dollars" {
            numberFormatter.numberStyle = .currency
            numberFormatter.groupingSeparator = ","
            numberFormatter.maximumFractionDigits = 2
        } else {
            numberFormatter.numberStyle = .decimal
            numberFormatter.groupingSeparator = ","
            numberFormatter.maximumFractionDigits = 2
        }
        
        return numberFormatter
    }
    
}
