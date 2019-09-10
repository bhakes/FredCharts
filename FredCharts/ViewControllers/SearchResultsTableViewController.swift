//
//  SearchResultsTableViewController.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/9/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        self.tableView?.register(SearchResultTableViewCell.self, forCellReuseIdentifier: searchResultCellReuseID)
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBar.text = ""
        tableView.reloadData()
    }
    
    // MARK: - Private Methods
    
    func setupViews(){
        self.tableView.tableFooterView = UIView()
        tableView.separatorInset = .init(top: 0, left: 12, bottom: 0, right: 12)
        navigationController?.navigationBar.layer.borderWidth = 0.0
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        searchBar.constrainToFill(tableView.tableHeaderView!)
        tableView.backgroundColor = .mainColor
        
        // setup title
        navigationItem.title = "Search"
        
        
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fredController.searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as? SearchResultTableViewCell else { fatalError("Could not dequeue cell as SearchResultTableViewCell") }
        
        // Configure the cell...
        cell.titleLabel.text = fredController.searchResults[indexPath.row].title
        cell.detailLabel.text = fredController.searchResults[indexPath.row].id

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let seriesRepresentation = self.fredController.searchResults[indexPath.row]
        let chartVC = ChartViewController(fredController: fredController, seriesRepresentation: seriesRepresentation)
        self.navigationController?.pushViewController(chartVC, animated: true)
    }

    // MARK: - UISearchBarDelegateMethods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchText = searchBar.text else { return }
        
        fredController.searchForFredSeries(with: searchText){ [weak self] _,_ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PreviewSegue" {
            guard let destVC = segue.destination as? ChartViewController else { fatalError("Destination segue is not recognized as a ChartTestViewController") }
            guard let indexPath = tableView.indexPathForSelectedRow else { fatalError("Could not get IndexPath for selected row.") }
            
            let seriesRepresentation = self.fredController.searchResults[indexPath.row]
            destVC.fredController = self.fredController
            destVC.seriesRepresentation = seriesRepresentation
            destVC.chartController = ChartController()
        }
        
    }

    // MARK: - Properties
    let searchResultCellReuseID = "SearchResultCell"
    var fredController: FredController = FredController()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.barTintColor = .mainColor
        searchBar.layer.borderWidth = 0.0
        searchBar.placeholder = "Try \"Inflation\", \"Oil\", or \"10-Year\""
        return searchBar
    }()
    
}
