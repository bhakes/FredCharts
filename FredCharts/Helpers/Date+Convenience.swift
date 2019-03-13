//
//  Date+Convenience.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/12/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation


extension Date {
    
    static func from(year: Int, month: Int, day: Int) -> Date {
        let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        let date = gregorianCalendar.date(from: dateComponents)!
        return date
    }
    
    static func parse(_ string: String, format: String = "yyyy-MM-dd") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.default
        dateFormatter.dateFormat = format
        
        let date = dateFormatter.date(from: string)!
        return date
    }
    
    static func dateXYearsAgo(numberOfYearsAgo: Int) -> Date{
        let now = Date()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY"
        let year = dateformatter.string(from: now)
        dateformatter.dateFormat = "MM"
        let month = dateformatter.string(from: now)
        dateformatter.dateFormat = "dd"
        let day = dateformatter.string(from: now)
        
        let yearNumber = Int(year)! - numberOfYearsAgo
        let monthNumber = Int(month)!
        let dayNumber = Int(day)!
        let dateXYearsAgo = Date.from(year: yearNumber, month: monthNumber, day: dayNumber)
        return dateXYearsAgo
    }
    
    static func dateXMonthsAgo(numberOfMonthsAgo: Int) -> Date{
        let now = Date()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "YYYY"
        let year = dateformatter.string(from: now)
        dateformatter.dateFormat = "MM"
        let month = dateformatter.string(from: now)
        dateformatter.dateFormat = "dd"
        let day = dateformatter.string(from: now)
        
        let yearNumber = Int(year)!
        let monthNumber = Int(month)! - numberOfMonthsAgo
        let dayNumber = Int(day)!
        let dateXYearsAgo = Date.from(year: yearNumber, month: monthNumber, day: dayNumber)
        return dateXYearsAgo
    }
}
