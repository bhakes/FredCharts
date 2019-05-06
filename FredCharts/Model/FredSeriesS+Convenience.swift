//
//  FredChart+Convenience.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/14/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation
import CoreData

extension FredSeriesS {
    
    convenience init(title: String,
                     id: String,
                     realtimeStart: String,
                     realtimeEnd: String,
                     observationStart: String,
                     observationEnd: String,
                     frequency: String,
                     frequencyShort: String,
                     units: String,
                     unitsShort: String,
                     seasonalAdjustment: String,
                     seasonalAdjustmentShort: String,
                     lastUpdated: String,
                     popularity: Int,
                     groupPopularity: Int,
                     notes: String?,
                     lastObservationValue: Double? = nil,
                     prevObservationValue: Double? = nil,
                     lastObservationDate: Date? = nil,
                     prevObservationDate: Date? = nil,
                     lastObservationSyncDate: Date? = nil,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
    
        
        self.init(context:context)
        
        self.title = title
        self.id = id
        self.realtimeStart = realtimeStart
        self.realtimeEnd = realtimeEnd
        self.observationStart = observationStart
        self.observationEnd = observationEnd
        self.frequency = frequency
        self.frequencyShort = frequencyShort
        self.units = units
        self.unitsShort = unitsShort
        self.seasonalAdjustment = seasonalAdjustment
        self.seasonalAdjustmentShort = seasonalAdjustmentShort
        self.lastUpdated = lastUpdated
        self.popularity = Int16(popularity)
        self.groupPopularity = Int16(groupPopularity)
        self.notes = notes
        
        // Observation fetch request related entries
        if let lastObservationValue = lastObservationValue {
            self.lastObservationValue = lastObservationValue
        }
        if let prevObservationValue = prevObservationValue {
            self.prevObservationValue = prevObservationValue
        }
    
    }
    
    convenience init?(fredSeriesSRepresentation: FredSeriesSRepresentation) {
        
        let title = fredSeriesSRepresentation.title
        let id = fredSeriesSRepresentation.id
        let realtimeStart = fredSeriesSRepresentation.realtimeStart
        let realtimeEnd = fredSeriesSRepresentation.realtimeEnd
        let observationStart = fredSeriesSRepresentation.observationStart
        let observationEnd = fredSeriesSRepresentation.observationEnd
        let frequency = fredSeriesSRepresentation.frequency
        let frequencyShort = fredSeriesSRepresentation.frequencyShort
        let units = fredSeriesSRepresentation.units
        let unitsShort = fredSeriesSRepresentation.unitsShort
        let seasonalAdjustment = fredSeriesSRepresentation.seasonalAdjustment
        let seasonalAdjustmentShort = fredSeriesSRepresentation.seasonalAdjustmentShort
        let popularity = fredSeriesSRepresentation.popularity
        let groupPopularity = fredSeriesSRepresentation.groupPopularity
        let notes = fredSeriesSRepresentation.notes
        let lastUpdated = fredSeriesSRepresentation.lastUpdated
        
        self.init(title: title, id : id, realtimeStart: realtimeStart, realtimeEnd: realtimeEnd, observationStart: observationStart, observationEnd: observationEnd, frequency: frequency, frequencyShort: frequencyShort, units: units, unitsShort: unitsShort, seasonalAdjustment: seasonalAdjustment, seasonalAdjustmentShort: seasonalAdjustmentShort, lastUpdated: lastUpdated, popularity: popularity, groupPopularity: groupPopularity, notes: notes)
    }
    
    convenience init?(fredSeriesSRepresentation: FredSeriesSRepresentation, with context: NSManagedObjectContext) {
        
        let title = fredSeriesSRepresentation.title
        let id = fredSeriesSRepresentation.id
        let realtimeStart = fredSeriesSRepresentation.realtimeStart
        let realtimeEnd = fredSeriesSRepresentation.realtimeEnd
        let observationStart = fredSeriesSRepresentation.observationStart
        let observationEnd = fredSeriesSRepresentation.observationEnd
        let frequency = fredSeriesSRepresentation.frequency
        let frequencyShort = fredSeriesSRepresentation.frequencyShort
        let units = fredSeriesSRepresentation.units
        let unitsShort = fredSeriesSRepresentation.unitsShort
        let seasonalAdjustment = fredSeriesSRepresentation.seasonalAdjustment
        let seasonalAdjustmentShort = fredSeriesSRepresentation.seasonalAdjustmentShort
        let popularity = fredSeriesSRepresentation.popularity
        let groupPopularity = fredSeriesSRepresentation.groupPopularity
        let notes = fredSeriesSRepresentation.notes
        let lastUpdated = fredSeriesSRepresentation.lastUpdated
        
        self.init(title: title, id : id, realtimeStart: realtimeStart, realtimeEnd: realtimeEnd, observationStart: observationStart, observationEnd: observationEnd, frequency: frequency, frequencyShort: frequencyShort, units: units, unitsShort: unitsShort, seasonalAdjustment: seasonalAdjustment, seasonalAdjustmentShort: seasonalAdjustmentShort, lastUpdated: lastUpdated, popularity: popularity, groupPopularity: groupPopularity, notes: notes, context: context)
    }
    
    convenience init(fredSeriesS: FredSeriesS, with context: NSManagedObjectContext) {
        
        let title = fredSeriesS.title!
        let id = fredSeriesS.id!
        let realtimeStart = fredSeriesS.realtimeStart!
        let realtimeEnd = fredSeriesS.realtimeEnd!
        let observationStart = fredSeriesS.observationStart!
        let observationEnd = fredSeriesS.observationEnd!
        let frequency = fredSeriesS.frequency!
        let frequencyShort = fredSeriesS.frequencyShort!
        let units = fredSeriesS.units!
        let unitsShort = fredSeriesS.unitsShort!
        let seasonalAdjustment = fredSeriesS.seasonalAdjustment!
        let seasonalAdjustmentShort = fredSeriesS.seasonalAdjustmentShort!
        let lastUpdated = fredSeriesS.lastUpdated!
        let popularity = Int(fredSeriesS.popularity)
        let groupPopularity = Int(fredSeriesS.groupPopularity)
        let notes = fredSeriesS.notes
        
        
        self.init(title: title, id : id, realtimeStart: realtimeStart, realtimeEnd: realtimeEnd, observationStart: observationStart, observationEnd: observationEnd, frequency: frequency, frequencyShort: frequencyShort, units: units, unitsShort: unitsShort, seasonalAdjustment: seasonalAdjustment, seasonalAdjustmentShort: seasonalAdjustmentShort, lastUpdated: lastUpdated, popularity: popularity, groupPopularity: groupPopularity, notes: notes, context: context)
    }
    
}
