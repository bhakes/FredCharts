//
//  FredChart+Convenience.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/14/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation
import CoreData

extension FredChart {
    convenience init(title: String,
        identifier: String,
        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
    
        self.init(context:context)
        self.title = title
        self.identifier = identifier
        
    }
}
