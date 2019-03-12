//
//  ChartTestViewController.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/9/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import UIKit
import SwiftCharts

typealias GridPoint = (Double, Double)

class ChartTestViewController: UIViewController, UITableViewDataSource ,UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        guard let fredController = fredController else { fatalError("FredController is empty")}
        guard let series = series else { fatalError("FredController is empty")}
        
        fredController.getObservationsForFredSeries(with: series.id) { resultingObservations, error in
            
            self.seriesObservations = resultingObservations
            if let seriesObservations = self.seriesObservations {
                
                self.modelPoints = self.parseObseration(for: seriesObservations)
                DispatchQueue.main.async {
                    self.updateChart()
                }
            }

        }
        
    }
    
    // MARK: - Private Methods
    
    func setupViews(){
        
        chartDetailsTableView.delegate = self
        chartDetailsTableView.dataSource = self
        chartDetailsTableView.tableFooterView = UIView()
        headerContainer.backgroundColor = .mainColor
        seriesLabel.textColor = .lightAccentColor
        seriesLabel.text = series?.title
        seriesLabel.adjustsFontSizeToFitWidth = true
        seriesLabel.minimumScaleFactor = 0.7
        
        idLabel.text = series?.id
        idLabel.textColor = .lightAccentColor
        
        registerTableViewCellNibs()
    }
    
    func registerTableViewCellNibs(){
        chartDetailsTableView.register(UINib(nibName: "ChartSegmentedControlTableViewCell", bundle: nil), forCellReuseIdentifier: segmentedControlReuseID)
        chartDetailsTableView.register(UINib(nibName: "ChartNormalControlTableViewCell", bundle: nil), forCellReuseIdentifier: normalControlReuseID)
        chartDetailsTableView.register(UINib(nibName: "ChartSliderControlTableViewCell", bundle: nil), forCellReuseIdentifier: sliderControlReuseID)
    }
    
    func updateChart(){
        
        guard let series = series else { fatalError("Could not produce chart b/c there is no series present") }
        chart = chartController.updateChart(with: modelPoints, for: series, in: chartContainerView)
        guard let chart = chart else { fatalError("Could not produce chart") }
        chartContainerView.addSubview(chart.view)
        
    }
    
    // Mark: - Parse Observation into ChartModel
    
    func parseObseration (for seriesObservations: Observations) ->[GridPoint]{
        
        for observation in seriesObservations.observations {
            
            guard let value = Double(observation.value) else { continue }
            
            let date = DateHelper.makeDateFromString(with: observation.date)
            
            let gp = GridPoint( date.timeIntervalSince1970, value)
            modelPoints.append(gp)
        }
        
        return modelPoints
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - TableView Data Source Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 3
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 7
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: segmentedControlReuseID, for: indexPath) as? ChartSegmentedControlTableViewCell else { fatalError("Unable to deque cell as chart segmenet control cell")}
                
                return cell
            
            default:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: normalControlReuseID, for: indexPath) as? ChartNormalControlTableViewCell else { fatalError("Unable to deque cell as chart segmenet control cell")}
               
                return cell
            }
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: normalControlReuseID, for: indexPath) as? ChartNormalControlTableViewCell else { fatalError("Unable to deque cell as chart segmenet control cell")}
            
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: normalControlReuseID, for: indexPath) as? ChartNormalControlTableViewCell else { fatalError("Unable to deque cell as chart segmenet control cell")}
            
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: normalControlReuseID, for: indexPath) as? ChartNormalControlTableViewCell else { fatalError("Unable to deque cell as chart segmenet control cell")}
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Viewing Options"
        case 1:
            return "Graph Appearance"
        case 2:
            return "Add Series"
        default:
            return "Edit Series: \(String(describing: series!.title))"
        }
    }
    
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let view = UIView()
//        view.backgroundColor = UIColor.lightGray
//        return view
//    }

//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 10
//    }
//

    
    // MARK: - Properties
    var seriesObservations: Observations?
    var chartController: ChartController = ChartController()
    fileprivate var chart: Chart?
    var series: FredSeriesS?
    
    var modelPoints: [GridPoint] = []
    var fredController: FredController?
    @IBOutlet weak var seriesLabel: UILabel!
    @IBOutlet weak var chartContainerView: UIView!
    @IBOutlet weak var chartDetailsTableView: ChartDetailsTableView!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var idLabel: UILabel!
    
    let segmentedControlReuseID = "SegmentedControlCell"
    let normalControlReuseID = "NormalControlCell"
    let sliderControlReuseID = "SliderControlCell"
}
