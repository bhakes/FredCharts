//
//  Observations.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/9/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation

struct Observations: Codable {
    let realtimeStart, realtimeEnd, observationStart, observationEnd: String
    let units: String
    let outputType: Int
    let fileType, orderBy, sortOrder: String
    let count, offset, limit: Int
    let observations: [Observation]
    
    enum CodingKeys: String, CodingKey {
        case realtimeStart = "realtime_start"
        case realtimeEnd = "realtime_end"
        case observationStart = "observation_start"
        case observationEnd = "observation_end"
        case units
        case outputType = "output_type"
        case fileType = "file_type"
        case orderBy = "order_by"
        case sortOrder = "sort_order"
        case count, offset, limit, observations
    }
}

struct Observation: Codable {
    let realtimeStart, realtimeEnd, date, value: String
    
    enum CodingKeys: String, CodingKey {
        case realtimeStart = "realtime_start"
        case realtimeEnd = "realtime_end"
        case date, value
    }
}
