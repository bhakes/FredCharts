//
//  UnitTypes.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/12/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation

enum UnitTypes: String {
    case Percent = "Percent"
    case Persons = "Persons"
    case Units = "Units"
    case NumberOfInstitutions = "Number of Institutions"
    case CentsPerGallon = "Cents per Gallon"
    case ThousandsOfUnits = "Thousands of Units"
    case Index2000 = "Index Jan 2000=100"
    case MillionsOfDollars = "Millions of Dollars"
    case Dollars = "Dollars"
    case DollarsPerHour = "DollarsPerHour"
    case KnownIncidents = "Known Incidents"
    case Establishments = "Establishments"
    case Rate = "Rate"
    case RatePer100000 = "Rate per 100,000"
    case Minutes = "Minutes"
    case YearsOfAge = "Years of Age"
    case Ratio = "Ratio"
    case Number = "Number"
    case ThousandsOfPersons = "Thousands of Persons"
}

struct UnitDefinition {
    
    static func bestDefinition(for name: String) -> UnitDefinition {
        
        if name == "Dollars" { return self.dollars }
        if name == "Percent" { return self.percent }
        if name == "Units" { return self.number }
        if name == "Number of Institutions" { return self.number }
        if name == "Cents per Gallon" { return self.dollars }
        if name == "Ratio" { return self.ratio }
        
        if name.contains("Index") { return self.number }
        if name.contains("Person") { return self.number }
        
        return self.number
    }
    
    let name: String
    private let formatter: (Double) -> String
    
    init(name: String, formatter: @escaping (Double) -> String) {
        self.name = name
        self.formatter = formatter
    }

    func format(_ number: Double) -> String {
        return formatter(number)
    }
    
}

extension UnitDefinition {
    static let dollars = UnitDefinition(name: "Dollars") { n -> String in
        let nf = NumberFormatter()
        nf.numberStyle = .currency
    
        if n < 1 {
            // format it for currency in one way
            nf.maximumFractionDigits = 3
            return nf.string(from: n as NSNumber)!
        } else if n < 10 {
            // format it for currency in one way
            nf.maximumFractionDigits = 2
            return nf.string(from: n as NSNumber)!
        } else if n < 500 {
            // format as "$4,000"
            nf.maximumFractionDigits = 1
            return nf.string(from: n as NSNumber)!
        } else if n < 1_000 {
            // format as "$4,000"
            nf.groupingSeparator = ","
            nf.maximumFractionDigits = 0
            return nf.string(from: n as NSNumber)!
        } else if n < 1_000_000 {
            // format as "$55,555"
            nf.groupingSeparator = ","
            nf.maximumFractionDigits = 0
            return nf.string(from: n as NSNumber)!
        } else if n < 1_000_000_000 {
            // format as "$990 M"
            let newN = n / 1_000_000
            nf.groupingSeparator = ","
            nf.maximumFractionDigits = 0
            return "\(nf.string(from: newN as NSNumber)!)M"
        } else if n < 1_000_000_000_000{
            let newN = n / 1_000_000_000
            // format as "$9,888 B"
            nf.groupingSeparator = ","
            nf.maximumFractionDigits = 1
            return "\(nf.string(from: newN as NSNumber)!)B"
        } else {
            let newN = n / 1_000_000_000_000
            // format as "$9,888 T"
            nf.groupingSeparator = ","
            nf.maximumFractionDigits = 1
            return "\(nf.string(from: newN as NSNumber)!)T"
        }
    }
    
    static let percent = UnitDefinition(name: "Percent") { n -> String in
        
        return "\(String(format: "%.2f", n))%"
        
    }
    
    static let ratio = UnitDefinition(name: "Ratio") { n -> String in
        
        return "\(String(format: "%.2f", n))"
        
    }
    
    static let number = UnitDefinition(name: "Number") { n -> String in
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        
        if n < 1 {
            // format it for currency in one way
            nf.maximumFractionDigits = 3
            return nf.string(from: n as NSNumber)!
        } else if n < 10 {
            // format it for currency in one way
            nf.maximumFractionDigits = 2
            return nf.string(from: n as NSNumber)!
        } else if n < 500 {
            // format as "$4,000"
            nf.maximumFractionDigits = 1
            return nf.string(from: n as NSNumber)!
        } else if n < 1_000 {
            // format as "$4,000"
            nf.groupingSeparator = ","
            nf.maximumFractionDigits = 0
            return nf.string(from: n as NSNumber)!
        } else if n < 1_000_000 {
            // format as "$55,555"
            nf.groupingSeparator = ","
            nf.maximumFractionDigits = 0
            return nf.string(from: n as NSNumber)!
        } else if n < 1_000_000_000 {
            // format as "$990 M"
            let newN = n / 1_000_000
            nf.groupingSeparator = ","
            nf.maximumFractionDigits = 0
            return "\(nf.string(from: newN as NSNumber)!)M"
        } else if n < 1_000_000_000_000{
            let newN = n / 1_000_000_000
            // format as "$9,888 B"
            nf.groupingSeparator = ","
            nf.maximumFractionDigits = 1
            return "\(nf.string(from: newN as NSNumber)!)B"
        } else {
            let newN = n / 1_000_000_000_000
            // format as "$9,888 T"
            nf.groupingSeparator = ","
            nf.maximumFractionDigits = 1
            return "\(nf.string(from: newN as NSNumber)!)T"
        }
    }
}
