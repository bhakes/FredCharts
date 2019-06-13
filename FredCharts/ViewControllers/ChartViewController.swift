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

class ChartViewController: UIViewController, UITableViewDataSource ,UITableViewDelegate, ChartSegementedControlDelegate, PickerControlDelegate {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        guard let fredController = fredController else { fatalError("FredController is empty")}
        guard let series = series else { return }
        guard let id = series.id else { return }

        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        fredController.getObservationsForFredSeries(with: id) { resultingObservations, error in
            
            print(resultingObservations?.count)
            self.seriesObservations = resultingObservations
            if let seriesObservations = self.seriesObservations {
                
                self.modelPoints = self.parseObseration(for: seriesObservations)
                self.originalModelPoints = self.modelPoints
                
                DispatchQueue.main.async {
                    self.updateChart(with: self.modelPoints)
                    self.chartDetailsTableView.reloadData()
                }
            }

        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        CoreDataStack.shared.mainContext.reset()
    }
    
    // MARK: - Private Methods
    
    private func setupViews(){
        
        chartDetailsTableView.delegate = self
        chartDetailsTableView.dataSource = self
        chartDetailsTableView.tableFooterView = UIView()
        headerContainer.backgroundColor = .mainColor
        
        // title label
        titleLabel.text = series?.title
        titleLabel.font = .boldSystemFont(ofSize: 32)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.4
        titleLabel.textColor = .white
        
        peakLabel.adjustsFontSizeToFitWidth = true
        peakLabel.minimumScaleFactor = 0.5
        lastLabel.adjustsFontSizeToFitWidth = true
        lastLabel.minimumScaleFactor = 0.5
        chartContainerView.backgroundColor = .mainColor
        idLabel.text = series?.id
        idLabel.textColor = .white
        
        registerTableViewCellNibs()
        checkIfChartAlreadySaved()
    }
    
    private func filterChartDates(by filterYears: Int){
        
        var newModelPoints: [GridPoint] = []
        
        if (filterYears == 0) {
            let months = 6
            newModelPoints = originalModelPoints.filter({
                Date.dateXMonthsAgo(numberOfMonthsAgo: months).timeIntervalSince1970 < $0.0
            })
            if newModelPoints.count == 0 {
                newModelPoints = originalModelPoints.filter({
                    
                    endDate?.dateXMonthsAgo(numberOfMonthsAgo: months).timeIntervalSince1970 ?? 0 < $0.0
                })
            }
        } else {
            newModelPoints = originalModelPoints.filter({ (x, y) -> Bool in
                Date.dateXYearsAgo(numberOfYearsAgo: filterYears).timeIntervalSince1970 < x
            })
        }

        DispatchQueue.main.async {
            self.chart?.view.removeFromSuperview()
            self.updateChart(with: newModelPoints)
            self.chartDetailsTableView.reloadData()
        }
        
    }
    
    private func checkIfChartAlreadySaved(){
        if chartAlreadySaved {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func filterChartDates(){
        
        var newModelPoints: [GridPoint] = []
        guard let startDate = startDate, let endDate = endDate else { return }
        
        newModelPoints = originalModelPoints.filter({ (arg) -> Bool in
            
            let (x, _) = arg
            return (startDate.timeIntervalSince1970 <= x && x <= endDate.timeIntervalSince1970)
        })
        
        DispatchQueue.main.async {
            self.chart?.view.removeFromSuperview()
            self.updateChart(with: newModelPoints)
            self.chartDetailsTableView.reloadData()
        }
        
    }
    
    private func registerTableViewCellNibs(){
        chartDetailsTableView.register(UINib(nibName: "ChartSegmentedControlTableViewCell", bundle: nil), forCellReuseIdentifier: segmentedControlReuseID)
        chartDetailsTableView.register(UINib(nibName: "ChartNormalControlTableViewCell", bundle: nil), forCellReuseIdentifier: normalControlReuseID)
        chartDetailsTableView.register(UINib(nibName: "ChartSliderControlTableViewCell", bundle: nil), forCellReuseIdentifier: sliderControlReuseID)
    }
    
    func updateChart(with modelPoints: [GridPoint]){
        
        guard let series = series else { fatalError("Could not produce chart b/c there is no series present") }
        
        self.modelPoints = []
        switch modelPoints.count {
        
        case 0..<400:
            self.modelPoints = modelPoints
        default:
            for i in stride(from: 0, to: modelPoints.count - 3, by: 4) {
                 self.modelPoints += modelPoints[i..<i+3]
            }
        }
        print(self.modelPoints.count)
        chart = chartController.updateChart(with: modelPoints, for: series, in: chartContainerView)
        guard let chart = chart else { fatalError("Could not produce chart") }
        chartContainerView.addSubview(chart.view)
        
    }
    
    // Mark: - Parse Observation into ChartModel
    
    func parseObseration (for seriesObservations: Observations) ->[GridPoint]{
        
        var tempModelPoints:[GridPoint] = []
        for observation in seriesObservations.observations {
            
            guard let value = Double(observation.value) else { continue }
            
            let date = DateHelper.makeDateFromString(with: observation.date)
            
            let gp = GridPoint( date.timeIntervalSince1970, value)
            tempModelPoints.append(gp)
        }
        
        return tempModelPoints
        
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
                self.updateChart(with: self.originalModelPoints)
                self.chartDetailsTableView.reloadData()
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
        return /*4*/1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 3
//        case 1:
//            return 1
//        case 2:
//            return 1
//        case 3:
//            return 7
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
                cell.selectionStyle = .none
                return cell
                
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: normalControlReuseID, for: indexPath) as? ChartNormalControlTableViewCell else { fatalError("Unable to deque cell as chart segmenet control cell")}
                cell.tag = 1
                cell.attributeTitleLabel.text = "Begin Date:"
                
                let beginDate = self.modelPoints.min {$0.0<$1.0}?.0
                
                let dateF = DateFormatter()
                dateF.dateFormat = "MM-dd-YYYY"
                let dateStr = dateF.string(from: Date(timeIntervalSince1970: beginDate ?? 0))
                
                cell.attributeValueLabel.text = "\(dateStr)"
                return cell
            
            case 2:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: normalControlReuseID, for: indexPath) as? ChartNormalControlTableViewCell else { fatalError("Unable to deque cell as chart segmenet control cell")}
                cell.tag = 1
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        guard let startDate = startDate, let endDate = endDate else { return }
        if cell.tag == 1 {
            
            let controller = PickerViewController(nibName: "PickerViewController", bundle: nil)
            controller.modalPresentationStyle = .overCurrentContext
            controller.delegate = self
            controller.startDate = startDate
            controller.endDate = endDate
            controller.startFlag = indexPath.row == 1 ? true : false
            
            self.present(controller, animated: true, completion: nil)
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

    // MARK: - TapGesture
    
    @IBAction func longPressed(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        
        
        if gestureRecognizer.state == .began {      // Move the view down and to the right when tapped.
            
            
            trackerLabel.text = "Actived"
            
            let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut, animations: {
                self.statsStackView.center.y -= 50
                self.statsStackView.alpha = 0
                self.trackerStatsView.alpha = 1
                
            })
            animator.startAnimation()
            
        } else if gestureRecognizer.state == .ended{
            trackerLabel.text = "Test"
            let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeIn, animations: {
                self.statsStackView.center.y += 50
                self.statsStackView.alpha = 1
                self.trackerStatsView.alpha = 0
            })
            animator.startAnimation()
            
        }
    }
    
    // MARK: - PickerControlDelegateMethods
    
    func pickerStartDateSelected(with date: Date) {
        guard let endDate = endDate else { return }
        
        /* if the user uses the picker to try pass a start date that's
        greater than the end date, return the startDate as the endDate minus a week.
        */
        if date >= endDate {
            startDate = endDate - 1 // return a different date
        } else {
            startDate = date
        }
        filterChartDates()
        chartDetailsTableView.reloadData()
    }
    
    func pickerEndDateSelected(with date: Date) {
        endDate = date
        filterChartDates()
        chartDetailsTableView.reloadData()
    }
    
    // MARK: - IBActions
    @IBAction func saveChart(_ sender: Any) {
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            print("could not save to core data")
        }
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    // MARK: - Properties
    var seriesObservations: Observations?
    var chartController: ChartController = ChartController()
    fileprivate var chart: Chart?
    var series: FredSeriesS?
    var seriesRepresentation: FredSeriesSRepresentation?
    
    var modelPoints: [GridPoint] = [] {
        didSet {
            DispatchQueue.main.async {
                
                var units: String
                if self.series?.units != nil {
                    units = (self.series?.units)!
                } else {
                    units = "Units"
                }
                
                //
                
                let peakValue = self.modelPoints.max {$0.1<$1.1}?.1
                let peakDate = self.modelPoints.max {$0.1<$1.1}?.0
                
                let lastValue = self.modelPoints.last?.1
                let lastDate = self.modelPoints.last?.0
                self.startDate = Date(timeIntervalSince1970: self.modelPoints.first!.0)
                self.endDate = Date(timeIntervalSince1970: lastDate!)
                
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
    
    var originalModelPoints: [GridPoint] = []
    var fredController: FredController?
    @IBOutlet weak var chartContainerView: UIView!
    @IBOutlet weak var chartDetailsTableView: ChartDetailsTableView!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statsStackView: UIStackView!
    @IBOutlet weak var trackerStatsView: UIView!
    @IBOutlet weak var trackerLabel: UILabel!
    @IBOutlet weak var lastLabel: UILabel!
    @IBOutlet weak var peakLabel: UILabel!
    @IBOutlet weak var lastDateLabel: UILabel!
    @IBOutlet weak var peakDateLabel: UILabel!
    var startDate: Date?
    var endDate: Date?
    
    let segmentedControlReuseID = "SegmentedControlCell"
    let normalControlReuseID = "NormalControlCell"
    let sliderControlReuseID = "SliderControlCell"
    var chartAlreadySaved: Bool = false
}
