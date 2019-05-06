//
//  FredSeriesSRepresentation.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/14/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation

struct FredSeriesSRepresentation: Decodable {
    
    var title: String
    var id: String
    var realtimeStart: String
    var realtimeEnd: String
    var observationStart: String
    var observationEnd: String
    var frequency: String
    var frequencyShort: String
    var units: String
    var unitsShort: String
    var seasonalAdjustment: String
    var seasonalAdjustmentShort: String
    var lastUpdated: String
    var popularity: Int
    var groupPopularity: Int
    var notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case realtimeStart = "realtime_start"
        case realtimeEnd = "realtime_end"
        case title
        case observationStart = "observation_start"
        case observationEnd = "observation_end"
        case frequency
        case frequencyShort = "frequency_short"
        case units
        case unitsShort = "units_short"
        case seasonalAdjustment = "seasonal_adjustment"
        case seasonalAdjustmentShort = "seasonal_adjustment_short"
        case lastUpdated = "last_updated"
        case popularity
        case groupPopularity = "group_popularity"
        case notes
    }
    
    
}

func ==(lhs: FredSeriesSRepresentation, rhs: FredSeriesS) -> Bool {
    return rhs.id == lhs.id &&
        rhs.title == lhs.title
}

func ==(lhs: FredSeriesS, rhs: FredSeriesSRepresentation) -> Bool {
    return rhs == lhs
}

func !=(lhs: FredSeriesSRepresentation, rhs: FredSeriesS) -> Bool {
    return !(lhs == rhs)
}

func !=(lhs: FredSeriesS, rhs: FredSeriesSRepresentation) -> Bool {
    return rhs != lhs
}
