//
//  FredChart+Convenience.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/14/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation

extension FredSeriesS : Encodable {
    
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

    
    // MARK: - Encode
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(id, forKey: .id)
        try container.encode(realtimeEnd, forKey: .realtimeEnd)
        try container.encode(realtimeStart, forKey: .realtimeStart)
        try container.encode(observationEnd, forKey: .observationEnd)
        try container.encode(observationStart, forKey: .observationStart)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(frequencyShort, forKey: .frequencyShort)
        try container.encode(units, forKey: .units)
        try container.encode(unitsShort, forKey: .unitsShort)
        try container.encode(seasonalAdjustment, forKey: .seasonalAdjustment)
        try container.encode(seasonalAdjustmentShort, forKey: .seasonalAdjustmentShort)
        try container.encode(lastUpdated, forKey: .lastUpdated)
        try container.encode(popularity, forKey: .popularity)
        try container.encode(groupPopularity, forKey: .groupPopularity)
        try container.encode(notes, forKey: .notes)
    }
    
}
