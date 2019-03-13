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

class ChartViewController: UIViewController, UITableViewDataSource ,UITableViewDelegate, ChartSegementedControlDelegate {

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
                    self.updateChart(with: self.modelPoints)
                    self.chartDetailsTableView.reloadData()
                }
            }

        }
        
    }
    
    // MARK: - Private Methods
    
    private func setupViews(){
        
        chartDetailsTableView.delegate = self
        chartDetailsTableView.dataSource = self
        chartDetailsTableView.tableFooterView = UIView()
        headerContainer.backgroundColor = .mainColor
        seriesLabel.textColor = .white
        seriesLabel.text = series?.title
        seriesLabel.adjustsFontSizeToFitWidth = true
        seriesLabel.minimumScaleFactor = 0.7
        peakLabel.adjustsFontSizeToFitWidth = true
        peakLabel.minimumScaleFactor = 0.5
        lastLabel.adjustsFontSizeToFitWidth = true
        lastLabel.minimumScaleFactor = 0.5
        chartContainerView.backgroundColor = .mainColor
        idLabel.text = series?.id
        idLabel.textColor = .white
        
        registerTableViewCellNibs()
    }
    
    func filterChartDates(by filterYears: Int){
        
        var newModelPoints: [GridPoint] = []
        
        if (filterYears == 0) {
            let months = 6
            newModelPoints = modelPoints.filter({
                Date.dateXMonthsAgo(numberOfMonthsAgo: months).timeIntervalSince1970 < $0.0
            })
        } else {
            newModelPoints = modelPoints.filter({ (x, y) -> Bool in
                Date.dateXYearsAgo(numberOfYearsAgo: filterYears).timeIntervalSince1970 < x
            })
        }

        DispatchQueue.main.async {
            self.chart?.view.removeFromSuperview()
            self.updateChart(with: newModelPoints)
        }
        
    }
    
    private func registerTableViewCellNibs(){
        chartDetailsTableView.register(UINib(nibName: "ChartSegmentedControlTableViewCell", bundle: nil), forCellReuseIdentifier: segmentedControlReuseID)
        chartDetailsTableView.register(UINib(nibName: "ChartNormalControlTableViewCell", bundle: nil), forCellReuseIdentifier: normalControlReuseID)
        chartDetailsTableView.register(UINib(nibName: "ChartSliderControlTableViewCell", bundle: nil), forCellReuseIdentifier: sliderControlReuseID)
    }
    
    func updateChart(with modelPoints: [GridPoint]){
        
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
    
    // MARK: - ChartSegementedControlDelegate
    func segmentedControlDidChange(with integer: Int?) {
        
        // catch if the data is old and
        // cannot be filtered by the segmented control0
        let lastDate = self.modelPoints.last?.0
        if lastDate! < (Date.dateXMonthsAgo(numberOfMonthsAgo: 6).timeIntervalSince1970), (lastDate! < (Date.dateXYearsAgo(numberOfYearsAgo: integer ?? 0).timeIntervalSince1970) && integer ?? 0 > 0) {
            return
        }
        guard let integer = integer else {
            DispatchQueue.main.async {
                self.chart?.view.removeFromSuperview()
                self.updateChart(with: self.modelPoints)
                
            }
            return
        }
        
        filterChartDates(by: integer)
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
                cell.delegate = self
                
                return cell
                
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: normalControlReuseID, for: indexPath) as? ChartNormalControlTableViewCell else { fatalError("Unable to deque cell as chart segmenet control cell")}
                
                cell.attributeTitleLabel.text = "Begin Date:"
                
                let beginDate = self.modelPoints.min {$0.0<$1.0}?.0
                
                let dateF = DateFormatter()
                dateF.dateFormat = "MM-dd-YYYY"
                let dateStr = dateF.string(from: Date(timeIntervalSince1970: beginDate ?? 0))
                
                cell.attributeValueLabel.text = "\(dateStr)"
                return cell
            
            case 2:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: normalControlReuseID, for: indexPath) as? ChartNormalControlTableViewCell else { fatalError("Unable to deque cell as chart segmenet control cell")}
                
                cell.attributeTitleLabel.text = "End Date:"
                
                let endDate = self.modelPoints.max {$0.0<$1.0}?.0
                
                let dateF = DateFormatter()
                dateF.dateFormat = "MM-dd-YYYY"
                let dateStr = dateF.string(from: Date(timeIntervalSince1970: endDate ?? 0))
                
                cell.attributeValueLabel.text = "\(dateStr)"
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

    
    // MARK: - Properties
    var seriesObservations: Observations?
    var chartController: ChartController = ChartController()
    fileprivate var chart: Chart?
    var series: FredSeriesS?
    
    var modelPoints: [GridPoint] = [] {
        didSet {
            DispatchQueue.main.async {
                
                var units: String
                if self.series?.units != nil {
                    units = (self.series?.units)!
                } else {
                    units = "Units"
                }
                
                let peakValue = self.modelPoints.max {$0.1<$1.1}?.1
                let peakDate = self.modelPoints.max {$0.1<$1.1}?.0
                
                let lastValue = self.modelPoints.last?.1
                let lastDate = self.modelPoints.last?.0
                
                let formattedPeakValue = UnitDefinition.bestDefinition(for: units).format(peakValue!)
                let formattedLastValue = UnitDefinition.bestDefinition(for: units).format(lastValue!)
                
                self.peakLabel.text = formattedPeakValue
                self.lastLabel.text = formattedLastValue
                let dateF = DateFormatter()
                dateF.dateFormat = "M/YY"
                let dateStr = dateF.string(from: Date(timeIntervalSince1970: peakDate ?? 0))
                
                let dateStr2 = dateF.string(from: Date(timeIntervalSince1970: lastDate ?? 0))
                
                self.peakDateLabel.text = "\(dateStr)"
                self.lastDateLabel.text = "\(dateStr2)"

            }
        }
    }
    var fredController: FredController?
    @IBOutlet weak var seriesLabel: UILabel!
    @IBOutlet weak var chartContainerView: UIView!
    @IBOutlet weak var chartDetailsTableView: ChartDetailsTableView!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var lastLabel: UILabel!
    @IBOutlet weak var peakLabel: UILabel!
    @IBOutlet weak var lastDateLabel: UILabel!
    @IBOutlet weak var peakDateLabel: UILabel!
    
    let segmentedControlReuseID = "SegmentedControlCell"
    let normalControlReuseID = "NormalControlCell"
    let sliderControlReuseID = "SliderControlCell"
}
