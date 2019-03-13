//
//  DateHelper.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/11/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation

class DateHelper {
    
    
    static func makeDateFromString(with string: String) -> Date {
        
        let dateFromObservation = string.split(separator: "-").map({ (substring) in
            return Int(substring)
        })
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = dateFromObservation[0]
        dateComponents.month = dateFromObservation[1]
        dateComponents.day = dateFromObservation[2]
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let dateValue = userCalendar.date(from: dateComponents)
        guard let date = dateValue else { fatalError("error convering date") }
        return date
        
    }
    
}

