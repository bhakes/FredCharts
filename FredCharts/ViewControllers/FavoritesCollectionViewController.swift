//
//  FavoritesCollectionViewController.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/14/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "Cell"

class FavoritesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UINib(nibName: "FavoritesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: favoritesCellReuseID)
        // Do any additional setup after loading the view.
        getDataUpdates()
        
    }
    
    // reload the data when the new collection view re-appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupLongPress()
    }
    
    // Private Methods
    private func setupLongPress(){
        let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FavoritesCollectionViewController.handleLongPress(gestureRecognizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = true
        self.collectionView?.addGestureRecognizer(lpgr)
    }
    
    // Private Methods
    
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
                    
                    series.lastObservationValue = Double(observation?.observations[0].value ?? "0.0")!
                    series.prevObservationValue = Double(observation?.observations[1].value ?? "0.0")!
                    
                    
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
                self.collectionView.reloadData()
            }
        }
        
        
        operation2.addDependency(operation1)
        
        let fetchQueue = OperationQueue()
        fetchQueue.addOperation(operation1)
        fetchQueue.addOperation(operation2)
        
    }
    

    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if fetchedResultsController.sections?.count ?? 0 > 0 {
            return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: favoritesCellReuseID, for: indexPath) as? FavoritesCollectionViewCell else { fatalError("Could not dequeue cell as FavoritesCollectionViewCell") }
    
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.bounds.size.width, height: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let kWhateverHeightYouWant = 100
        return CGSize(width: collectionView.bounds.size.width - 12, height: CGFloat(kWhateverHeightYouWant))
    }

    // MARK: UICollectionViewDelegate
    
    

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: favoritesCellReuseID, for: indexPath) as? FavoritesCollectionViewCell else { fatalError("Could not dequeue cell as FavoritesCollectionViewCell") }
        
        performSegue(withIdentifier: "ViewChartSegue", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "ViewChartSegue" {
            guard let destVC = segue.destination as? ChartViewController else { fatalError("Destination segue is not recognized as a ChartTestViewController") }
            let iPath = self.collectionView.indexPathsForSelectedItems
            let indexPath : IndexPath = iPath![0]
            destVC.fredController = self.fredController
            destVC.series = fetchedResultsController.object(at: indexPath)
            
        } else if segue.identifier == "SearchSegue" {
            guard let destVC = segue.destination as? SearchResultsTableViewController else { fatalError("Destination segue is not recognized as a ChartTestViewController") }
            destVC.fredController = self.fredController
        }
        
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperation = BlockOperation()
    }
    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        blockOperation = BlockOperation()
//    }
    
    
    // MARK: - Tap gesture Recognizer
    @objc (handleLongPressWithGestureRecognizer:)
    func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        
        if (gestureRecognizer.state != UIGestureRecognizer.State.ended){
            return
        }
        
        let p = gestureRecognizer.location(in: self.collectionView)
        
        if let indexPath : IndexPath = (self.collectionView?.indexPathForItem(at: p)){
            //do whatever you need to do
            displayAlertViewController(for: indexPath)
            
        }
        
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
                    self.collectionView.reloadData()
                }
            
            }}))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Properties
    let favoritesCellReuseID = "FavoritesCell"
    let fredController = FredController()
    private var blockOperation = BlockOperation()
    var results : [FredSeriesS] = []
    var operationDict: [IndexPath: FredSeriesS] = [:]
    
//    let frc: NSFetchedResultsController<FetchRequestResult>
//    weak var collectionView: UICollectionView?
//    weak var delegate: FRCCollectionViewDelegate?
    
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
