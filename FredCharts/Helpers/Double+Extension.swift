//
//  Double+Extension.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/13/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation

extension Double {
    
    mutating func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self.binade * divisor) / divisor
    }
}
