//
//  FredChart+Convenience.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/14/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation

extension FredChart: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case title
        case identifier
    }
    
    // MARK: - Encode
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(identifier, forKey: .identifier)
    }
    
    
}
