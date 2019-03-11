//
//  FredSeriesS.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/9/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation

struct FredSeriesS: Codable {
    let id, realtimeStart, realtimeEnd, title: String
    let observationStart, observationEnd, frequency, frequencyShort: String
    let units, unitsShort, seasonalAdjustment, seasonalAdjustmentShort: String
    let lastUpdated: String
    let popularity, groupPopularity: Int
    let notes: String?
    
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
