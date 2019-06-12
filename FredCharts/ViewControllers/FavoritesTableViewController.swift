//
//  FavoritesTableViewController.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 6/11/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.tableView!.register(UINib(nibName: "FavoritesTableViewCell", bundle: nil), forCellReuseIdentifier: favoritesCellReuseID)
        tableView.tableFooterView = UIView()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "FedCharts"
        getDataUpdates()
    }

    // reload the data when the new collection view re-appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = "FedCharts"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        adjustLargeTitleSize()
    }
    
    // MARK: - Private Methods
    
    private func getDataUpdates(forceUpdate: Bool = false){
        
        let operation1 = BlockOperation {
            
            let group = DispatchGroup()
            let refreshThresholdDate = Date(timeIntervalSinceNow: -60 * 60 * 12)
            
            for series in self.fetchedResultsController.fetchedObjects ?? [] {
                
                group.enter()
                // Only refresh if it's been more than 12 hours since the last sync
                if let lastSyncDate = series.lastObservationSyncDate, lastSyncDate >= refreshThresholdDate, forceUpdate == false {
                    group.leave()
                    continue
                }
                
                guard let id = series.id else { fatalError("Error: The series has no id!")}
                
                self.fredController.getObservationsForFredSeries(with: id, descendingSortOrder: true, observationCount: 2) { (observation, error) in
                    
                    if let lastValue = observation?.observations[0].value {
                        if let doubleLastValue = Double(lastValue){
                            series.lastObservationValue = doubleLastValue
                        }
                    } else {
                        series.lastObservationValue = 0.0
                    }
                    
                    if let prevValue = observation?.observations[1].value {
                        if let doublePrevValue = Double(prevValue){
                            series.prevObservationValue = doublePrevValue
                        }
                    } else {
                        series.prevObservationValue = 0.0
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    series.lastObservationDate = dateFormatter.date(from: (observation?.observations[0].date)!)
                    
                    series.prevObservationDate = dateFormatter.date(from: (observation?.observations[1].date)!)
                    
                    series.lastObservationSyncDate = Date(timeIntervalSinceNow: 0)
                    print("Done with: \(id)")
                    group.leave()
                }
                
            }
            
            group.wait()
            print("Done with all.")
            
        }
        
        let operation2 = BlockOperation {
            do {
                try CoreDataStack.shared.mainContext.save()
            } catch {
                print("Error saving managed object context.")
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        
        operation2.addDependency(operation1)
        
        let fetchQueue = OperationQueue()
        fetchQueue.addOperation(operation1)
        fetchQueue.addOperation(operation2)
        
    }
    
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if fetchedResultsController.sections?.count ?? 0 > 0 {
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: favoritesCellReuseID, for: indexPath) as? FavoritesTableViewCell else { fatalError("Could not dequeue cell as FavoritesTableViewCell") }
        
        let series = fetchedResultsController.object(at: indexPath)
        
        if let frequency = series.frequency {
            cell.frequencyLabel.text = "Frequency: \(frequency)"
        }
        if let units = series.units {
            cell.unitsLabel.text = "Units: \(units)"
        }
        
        cell.titleLabel.text = series.title
        cell.idLabel.text = series.id
        
        var units = "Units"
        if series.units != nil {
            units = series.units!
        }
        
        print(units)
        
        let formattedLastValue = UnitDefinition.bestDefinition(for: units).format(series.lastObservationValue)
        let formattedPrevValue = UnitDefinition.bestDefinition(for: units).format(series.prevObservationValue)
        
        cell.lastObservationValueLabel.text = formattedLastValue
        cell.previousObservationValueLabel.text = formattedPrevValue
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yy"
        
        if let lastObservationDate = series.lastObservationDate {
            let lastUpdatedDateString = dateFormatter.string(from: lastObservationDate)
            cell.lastDateLabel.text = "Last: \(lastUpdatedDateString)"
        }
        
        if let prevObservationDate = series.prevObservationDate {
            let prevUpdatedDateString = dateFormatter.string(from: prevObservationDate)
            cell.prevDateLabel.text = "Prev: \(prevUpdatedDateString)"
        }
        
        
        cell.series = series
        
        operationDict[indexPath] = series
        
        // Configure the cell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: favoritesCellReuseID, for: indexPath) as? FavoritesTableViewCell else { fatalError("Could not dequeue cell as FavoritesTableViewCell") }
        
        performSegue(withIdentifier: "ViewChartSegue", sender: cell)
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "ViewChartSegue" {
            guard let destVC = segue.destination as? ChartViewController else { fatalError("Destination segue is not recognized as a ChartTestViewController") }
            guard let indexPath = self.tableView.indexPathForSelectedRow else { fatalError("Could not get indexPath for selected item.") }
            destVC.fredController = self.fredController
            destVC.series = fetchedResultsController.object(at: indexPath)
            destVC.chartAlreadySaved = true
            
        } else if segue.identifier == "SearchSegue" {
            guard let destVC = segue.destination as? SearchResultsTableViewController else { fatalError("Destination segue is not recognized as a ChartTestViewController") }
            destVC.fredController = self.fredController
        }
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperation = BlockOperation()
    }
    
    // MARK: - Display Alert View Controller
    func displayAlertViewController(for indexPath: IndexPath){
        
        let chartToDelete = self.fetchedResultsController.object(at: indexPath)
        var chartId = ""
        if chartToDelete.id != nil{
            chartId = chartToDelete.id!
        }
        let alert = UIAlertController(title: "Are you sure you want to delete series \(chartId)?", message: "Press okay to remove it from the Library", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            if action.style == .destructive {
                self.fetchedResultsController.managedObjectContext.delete(chartToDelete)
                do {
                    try self.fetchedResultsController.managedObjectContext.save()
                } catch {
                    print("failure saving moc")
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func editTapped(sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Editing Style
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let chartToDelete = self.fetchedResultsController.object(at: indexPath)
            self.fetchedResultsController.managedObjectContext.delete(chartToDelete)
            do {
                try self.fetchedResultsController.managedObjectContext.save()
            } catch {
                print("failure saving moc")
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    // MARK: - Properties
    let favoritesCellReuseID = "FavoritesCell"
    let fredController = FredController()
    private var blockOperation = BlockOperation()
    var results : [FredSeriesS] = []
    var operationDict: [IndexPath: FredSeriesS] = [:]
    
    lazy var fetchedResultsController: NSFetchedResultsController<FredSeriesS> = {
        
        let fetchRequest: NSFetchRequest<FredSeriesS> = FredSeriesS.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "realtimeStart", ascending: true)
        ]
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "frequency", cacheName: nil)
        
        frc.delegate = self
        try? frc.performFetch()
        
        return frc
        
    }()

}
