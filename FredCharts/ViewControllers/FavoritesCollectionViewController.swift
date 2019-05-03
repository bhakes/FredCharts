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
        cell.titleLabel.text = series.title
        cell.idLabel.text = series.id
        cell.frequencyLabel.text = "Frequency: \(series.frequency!)"
        cell.lastObservationValueLabel.text = 
        cell.lastObservationDateLabel.text = "Last Updated: \(series.lastUpdated!.prefix(10))"
        cell.series = series
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
        return CGSize(width: collectionView.bounds.size.width - 16, height: CGFloat(kWhateverHeightYouWant))
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
                let chartToDelete = self.fetchedResultsController.object(at: indexPath)
                let moc = CoreDataStack.shared.mainContext
                moc.perform {
                    moc.delete(chartToDelete)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
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
