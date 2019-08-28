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
        
        updateViews()
        getDataUpdates()
    }

    // reload the data when the new collection view re-appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if !initialLoad {
            getDataUpdates()
        } else {
            initialLoad = false
        }
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    // MARK: - Private Methods
    
    private func updateViews() {
        
        tableView.tableFooterView = UIView()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // Create and Assign Edit Button to Left Bar Button Item
        navigationItem.leftBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped(sender:)))
        
        // Create and Assign the Search Bar Button to the Right Bar Button Item
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped(sender:)))
        
    }
    
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
                
                guard let id = series.id else { return }
                
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
                    
                    group.leave()
                }
                
            }
            
            group.wait()
            
            
        }
        
        let operation2 = BlockOperation {
            do {
                try CoreDataStack.shared.save()
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
        autoreleasepool {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: favoritesCellReuseID, for: indexPath) as? FavoritesTableViewCell else { fatalError("Could not dequeue cell as FavoritesTableViewCell") }
            performSegue(withIdentifier: "ViewChartSegue", sender: cell)
        }
       
        
        
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
       
        guard var seriesList = fetchedResultsController.fetchedObjects else { return }
        let seriesToMove = seriesList[sourceIndexPath.row]
        seriesList.remove(at: sourceIndexPath.row)
        seriesList.insert(seriesToMove, at: destinationIndexPath.row)
        
        for (i, series) in seriesList.enumerated() {
            series.setValue(i, forKey: "position")
        }
        
        do
        {
            try CoreDataStack.shared.save()
            
        } catch{
            print("Difficulty saving main context")
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @objc func editing(sender: UIBarButtonItem) {
        
        isEditing = !isEditing
        
    }
    
    @objc func searchButtonTapped(sender: UIBarButtonItem) {
        
        let searchResultsTableVC = SearchResultsTableViewController()
        searchResultsTableVC.fredController = fredController
        present(searchResultsTableVC, animated: true, completion: nil)
        
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "ViewChartSegue" {
            guard let destVC = segue.destination as? ChartViewController else { fatalError("Destination segue is not recognized as a ChartTestViewController") }
            guard let indexPath = self.tableView.indexPathForSelectedRow else { fatalError("Could not get indexPath for selected item.") }
            destVC.fredController = self.fredController
            destVC.series = fetchedResultsController.object(at: indexPath)
            destVC.chartAlreadySaved = true
            destVC.chartController = ChartController()
            
        } else if segue.identifier == "SearchSegue" {
            guard let destVC = segue.destination as? SearchResultsTableViewController else { fatalError("Destination segue is not recognized as a ChartTestViewController") }
            destVC.fredController = self.fredController
        }
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
        blockOperation = BlockOperation()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    @objc func editTapped(sender: UIBarButtonItem) {
        
        isEditing = !isEditing
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped(sender:)))
        self.navigationItem.leftBarButtonItem = doneBarButton
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
    }
    
    @objc func doneTapped(sender: UIBarButtonItem) {
        
        isEditing = !isEditing
        let editBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped(sender:)))
        self.navigationItem.leftBarButtonItem = editBarButton
        self.navigationItem.rightBarButtonItem?.isEnabled = true
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
            
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                        didChange anObject: Any,
                        at indexPath: IndexPath?,
                        for type: NSFetchedResultsChangeType,
                        newIndexPath: IndexPath?) {
        
            switch type {
            case .insert:
                guard let newIndexPath = newIndexPath else { return }
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            case .delete:
                guard let indexPath = indexPath else { return }
                tableView.deleteRows(at: [indexPath], with: .automatic)
            default:
                break
            }
        }
    
    // MARK: - Properties
    let favoritesCellReuseID = "FavoritesCell"
    let fredController = FredController()
    private var blockOperation = BlockOperation()
    var results : [FredSeriesS] = []
    var operationDict: [IndexPath: FredSeriesS] = [:]
    private var initialLoad: Bool = true
    
    lazy var fetchedResultsController: NSFetchedResultsController<FredSeriesS> = {
        
        let fetchRequest: NSFetchRequest<FredSeriesS> = FredSeriesS.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "position", ascending: true)
        ]
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        
        frc.delegate = self
        try? frc.performFetch()
        
        return frc
        
    }()

}
