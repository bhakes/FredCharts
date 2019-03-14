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

class FavoritesCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    // reload the data when the new collection view re-appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        collectionView.reloadData()
        
    }
    
    // Private Methods
    private func registerTableViewCellNibs(){
//        self.register(UINib(nibName: "FavoritesCollectionViewCell", bundle: nil), forCellReuseIdentifier: favoritesCellReuseID)
    }
    
    private func performFetch(){
        let moc = CoreDataStack.shared.mainContext
        let fetchRequest: NSFetchRequest<FredChart> = FredChart.fetchRequest()
        
        do {
            results = try moc.fetch(fetchRequest)
        } catch { // error stuff
            print("error fetching")
        }
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }

    // MARK: UICollectionViewDataSource


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return results.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: favoritesCellReuseID, for: indexPath) as? FavoritesCollectionViewCell else { fatalError("Could not dequeue cell as FavoritesCollectionViewCell") }
        
        results[indexPath.row].title
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperation = BlockOperation()
    }
    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        blockOperation = BlockOperation()
//    }
    
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            collectionView.insertSections(IndexSet(integer: sectionIndex))
        case .delete:
            collectionView.deleteSections(IndexSet(integer: sectionIndex))
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
            collectionView.insertItems(at: [newIndexPath])
        case .update:
            guard let indexPath = indexPath else { return }
            collectionView.reloadItems(at: [indexPath])
        case .move:
            guard let oldIndexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            collectionView.deleteItems(at: [oldIndexPath])
            collectionView.insertItems(at: [newIndexPath])
        case .delete:
            guard let indexPath = indexPath else { return }
            collectionView.deleteItems(at: [indexPath])
        }
    }
    
    // MARK: - Properties
    let favoritesCellReuseID = "FavoritesCell"
    private var blockOperation = BlockOperation()
    var results : [FredChart] = []
//    let frc: NSFetchedResultsController<FetchRequestResult>
//    weak var collectionView: UICollectionView?
//    weak var delegate: FRCCollectionViewDelegate?
    

}
