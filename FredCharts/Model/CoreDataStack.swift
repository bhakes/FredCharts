//
//  CoreDataStack.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/14/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    /** singleton for accessesing CoreDataStack class methods
     */
    static let shared = CoreDataStack()
    private init() {}
    
    lazy var container: NSPersistentContainer = { () -> NSPersistentContainer in
        let container = NSPersistentContainer(name: "FredCharts")
        container.loadPersistentStores(completionHandler: { [weak self](_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = false
        
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
        
        var error: Error?
        context.performAndWait {
            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }
        // If there was an error, the error var will be non nil
        if let error = error {
            throw error
        }
    }
}

