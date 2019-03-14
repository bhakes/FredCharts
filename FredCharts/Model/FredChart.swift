//
//  FredChart.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/14/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation
import CoreData

class FredChart: Codable{
    
    let series: FredSeriesS
    let observations: Observations
    
    enum CodingKeys: String, CodingKey {
        case series
        case observations
    }
    
    convenience init (series: FredSeriesS,
          observations: Observations,
        context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        self.init(from:context)
        self.series = series
        self.observations = observations
    }
}
