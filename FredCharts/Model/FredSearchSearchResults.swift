//
//  FredSearchSearchResults.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/9/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation

// individual entry
struct FredSearchSearchResults: Codable {
    let realtimeStart, realtimeEnd, orderBy, sortOrder: String
    let count, offset, limit: Int
    let seriess: [FredSeriesS]
    
    enum CodingKeys: String, CodingKey {
        case realtimeStart = "realtime_start"
        case realtimeEnd = "realtime_end"
        case orderBy = "order_by"
        case sortOrder = "sort_order"
        case count, offset, limit, seriess
    }
}
