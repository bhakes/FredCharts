//
//  ChartTestViewController.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/9/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import UIKit
import CoreData

typealias GridPoint = (Double, Double)

class ChartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupProgressHUD()
        
        guard let fredController = fredController else { fatalError("FredController is empty")}
        guard let id = chartAlreadySaved ? series?.id : seriesRepresentation?.id else { return }
        
//        fredController.getObservationsForFredSeries(with: id) { [unowned self] resultingObservations, error in
//
//            self.seriesObservations = resultingObservations
//            if let seriesObservations = self.seriesObservations {
//
//                let newModelPoints = self.parseObseration(for: seriesObservations)
//                self.originalModelPoints = newModelPoints
//
//                self.filterChartDates(by: 1)
//
//            }
//
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    // MARK: - Private Methods
    
    private func setupViews(){
        
        self.view.backgroundColor = .mainColor
        
        setupInfoContainerView()
        setupStatsContainerView()
        setupChartContainerView()
        setupChartDetailsTableView()
        registerTableViewCellNibs()
        checkIfChartAlreadySaved()
    }
    
    private func setupInfoContainerView() {
        
        infoContainerView = UIView()
        self.view.addSubview(infoContainerView)
        
        // setup title label
        let titleLabel = UILabel()
        titleLabel.text = chartAlreadySaved ? series?.title : seriesRepresentation?.title
        titleLabel.font = .boldSystemFont(ofSize: 30)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1
        
        // setup id label
        let idLabel = UILabel()
        idLabel.text = chartAlreadySaved ? series?.id : seriesRepresentation?.id
        idLabel.font = .systemFont(ofSize: 12)
        idLabel.textColor = .white
        
        let titleStackView = UIStackView()
        titleStackView.axis = .vertical
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(idLabel)
        titleStackView.distribution = .fillProportionally
        
        titleStackView.constrainToFill(infoContainerView)
        infoContainerView.constrainToSuperView(self.view, safeArea: true, top: 4, leading: 8, trailing: 8)
        
    }
    
    private func setupStatsContainerView(){
        
        // Stats Container View
        statsContainerView = UIView()
        statsContainerView.constrain(height: 80, width: 200)
        
        // Last Label
        let lastLabel = UILabel.label(for: .caption2, with: "Last:")
        lastLabel.textColor = .white
        lastLabel.textAlignment = .center
        
        // Last Value Label
        lastValueLabel = UILabel.label(for: .header2, with: " ")
        lastValueLabel.textColor = .white
        lastValueLabel.textAlignment = .center
        lastValueLabel.adjustsFontSizeToFitWidth = true
        lastValueLabel.minimumScaleFactor = 0.5
        
        // Last Date Label
        lastDateLabel = UILabel.label(for: .caption1, with: " ")
        lastDateLabel.textColor = .white
        lastDateLabel.textAlignment = .center
        
        // Last Stack view
        let lastStackView = UIStackView()
        lastStackView.axis = .vertical
        lastStackView.addArrangedSubview(lastLabel)
        lastStackView.addArrangedSubview(lastValueLabel)
        lastStackView.addArrangedSubview(lastDateLabel)
        lastStackView.distribution = .fillProportionally
        
        // Peak Label
        let peakLabel = UILabel.label(for: .caption2, with: "Peak:")
        peakLabel.textColor = .white
        peakLabel.textAlignment = .center
        
        // Peak Value Label
        peakValueLabel = UILabel.label(for: .header2, with: " ")
        peakValueLabel.textColor = .white
        peakValueLabel.textAlignment = .center
        peakValueLabel.adjustsFontSizeToFitWidth = true
        peakValueLabel.minimumScaleFactor = 0.5
        
        // Peak Date Label
        peakDateLabel = UILabel.label(for: .caption1, with: " ")
        peakDateLabel.textColor = .white
        peakDateLabel.textAlignment = .center
        
        // Peak Stack view
        let peakStackView = UIStackView()
        peakStackView.axis = .vertical
        peakStackView.addArrangedSubview(peakLabel)
        peakStackView.addArrangedSubview(peakValueLabel)
        peakStackView.addArrangedSubview(peakDateLabel)
        peakStackView.distribution = .fillProportionally
        
        // SeparatorView
        let separatorView = UIView(frame: CGRect.zero)
        separatorView.constrain(width: 2)
        separatorView.backgroundColor = .white
        
        // stats stack view
        let statsStackView = UIStackView()
        statsStackView.axis = .horizontal
        statsStackView.addArrangedSubview(lastStackView)
        statsStackView.addArrangedSubview(separatorView)
        statsStackView.addArrangedSubview(peakStackView)
        statsStackView.spacing = 12
        statsStackView.distribution = .equalCentering
        
        statsStackView.constrainToCenterIn(statsContainerView)
        self.view.addSubview(statsContainerView)
        statsContainerView.constrainToSiblingView(infoContainerView, below: 0, equalWidth: 0)
        
    }
    
    private func setupChartContainerView(){
        
        chartContainerView = UIView()
        chartContainerView.backgroundColor = .mainColor
        self.view.addSubview(chartContainerView)
        chartContainerView.constrainToSiblingView(statsContainerView, below: 4, equalWidth: 1, height: 300)
    
    }
    
    private func setupChartDetailsTableView() {
        
        chartDetailsTableView = ChartDetailsTableView()
        chartDetailsTableView.delegate = self
        chartDetailsTableView.dataSource = self
        chartDetailsTableView.tableFooterView = UIView()
        
        self.view.addSubview(chartDetailsTableView)
        chartDetailsTableView.constrainToSiblingView(statsContainerView, below: 4, equalWidth: 0)
        chartDetailsTableView.constrainToSuperView(self.view, safeArea: true, bottom: 0)
    }
    
    private func registerTableViewCellNibs(){
        chartDetailsTableView.register(UINib(nibName: "ChartSegmentedControlTableViewCell", bundle: nil), forCellReuseIdentifier: segmentedControlReuseID)
        chartDetailsTableView.register(UINib(nibName: "ChartNormalControlTableViewCell", bundle: nil), forCellReuseIdentifier: normalControlReuseID)
        chartDetailsTableView.register(UINib(nibName: "ChartSliderControlTableViewCell", bundle: nil), forCellReuseIdentifier: sliderControlReuseID)
    }
    
    private func checkIfChartAlreadySaved(){
        if !chartAlreadySaved {
            // Create and Assign the Save BarButtonItem to the Right Bar Button Item
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped(sender:)))
        }
    }
    
    private func setupProgressHUD(){
        let progressHUD = ProgressHUD(text: "Loading Chart")
        self.progressHUD = progressHUD
        progressHUD.constrainToSuperView(chartContainerView, safeArea: true, centerX: 0, centerY: 0, height: 200, width: 200)
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
            autoreleasepool{
                self.chart?.view.removeFromSuperview()
                self.progressHUD?.removeFromSuperview()
                print("Updating the chart!")
                self.updateChart(with: newModelPoints)
                self.chartDetailsTableView.reloadData()
            }
            
        }
        
    }
    
    
    
    private func filterChartDates(){
        
        var newModelPoints: [GridPoint] = []
//        guard let startDate = startDate, let endDate = endDate else { return }
        newModelPoints = originalModelPoints /*.filter({ (arg) -> Bool in
            
            let (x, _) = arg
            return (startDate.timeIntervalSince1970 <= x && x <= endDate.timeIntervalSince1970)
        })*/
        
        DispatchQueue.main.async {
            autoreleasepool{
                self.chart?.view.removeFromSuperview()
                self.progressHUD?.removeFromSuperview()
                print("Updating the chart!")
                self.updateChart(with: newModelPoints)
                self.chartDetailsTableView.reloadData()
            }
        }
        
    }
    
    
    
    private func updateDatesAndLables(modelPoints: [GridPoint]) {

        var units: String
        if self.series?.units != nil {
            units = (self.series?.units)!
        } else {
            units = "Units"
        }
        let dateF = DateFormatter()
        dateF.dateFormat = "M/YY"
        let peakValue = modelPoints.max {$0.1<$1.1}?.1
        let peakDate = modelPoints.max {$0.1<$1.1}?.0
        let lastValue = modelPoints.last?.1
        let lastDate = modelPoints.last?.0
        
        self.startDate = Date(timeIntervalSince1970: modelPoints.first!.0)
        self.endDate = Date(timeIntervalSince1970: lastDate!)
        
        let formattedPeakValue = UnitDefinition.bestDefinition(for: units).format(peakValue!)
        let formattedLastValue = UnitDefinition.bestDefinition(for: units).format(lastValue!)
        let dateStr = dateF.string(from: Date(timeIntervalSince1970: peakDate ?? 0))
        
        let dateStr2 = dateF.string(from: Date(timeIntervalSince1970: lastDate ?? 0))
        
        DispatchQueue.main.async {
            self.peakValueLabel.text = formattedPeakValue
            self.lastValueLabel.text = formattedLastValue
            
            self.peakDateLabel.text = "\(dateStr)"
            self.lastDateLabel.text = "\(dateStr2)"
        }
        
    }
    
    func updateChart(with modelPoints: [GridPoint]){
        
        self.modelPoints = modelPoints
        updateDatesAndLables(modelPoints: modelPoints)

        if chartAlreadySaved {
            guard let series = series else { fatalError("Could not produce chart b/c there is no series present") }
            chart = chartController?.updateChart(with: modelPoints, for: series, in: chartSubContainerView)
        } else {
            guard let seriesRep = seriesRepresentation else { fatalError("Could not produce chart b/c there is no series present") }
            chart = chartController?.updateChart(with: modelPoints, for: seriesRep, in: chartSubContainerView)
        }
        
        guard let chart = chart else { fatalError("Could not produce chart") }
        chartSubContainerView.addSubview(chart.view)
        
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
    
    
    // MARK: - IBActions
    @objc func saveButtonTapped(sender: UIBarButtonItem) {
        
        guard let seriesRep = seriesRepresentation else {
            return
        }
        FredSeriesS(fredSeriesSRepresentation: seriesRep)
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("could not save to core data")
        }
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Properties
    var seriesObservations: Observations?
    var chartController: ChartController?
    fileprivate var chart: Chart?
    var series: FredSeriesS?
    var seriesRepresentation: FredSeriesSRepresentation?
    var progressHUD: ProgressHUD?
    var modelPoints: [GridPoint] = []
    
    var originalModelPoints: [GridPoint] = []
    var fredController: FredController?
    var backgroundMOC: NSManagedObjectContext?
    
    // UI Properties
    var infoContainerView: UIView!
    var statsContainerView: UIView!
    var chartContainerView: UIView!
    var chartSubContainerView: UIView!
    var chartDetailsTableView: ChartDetailsTableView!
    var statsStackView: UIStackView!
    var trackerStatsView: UIView!
    var trackerLabel: UILabel!
    var lastValueLabel: UILabel!
    var peakValueLabel: UILabel!
    var lastDateLabel: UILabel!
    var peakDateLabel: UILabel!
    
    
    var startDate: Date?
    var endDate: Date?
    var isInitialUpdate: Bool = true
    let segmentedControlReuseID = "SegmentedControlCell"
    let normalControlReuseID = "NormalControlCell"
    let sliderControlReuseID = "SliderControlCell"
    var chartAlreadySaved: Bool = false
}


extension ChartViewController: ChartSegementedControlDelegate {
    
    // MARK: - ChartSegementedControlDelegate
    func segmentedControlDidChange(with integer: Int?) {
        
        if let progressHUD = self.progressHUD {
            self.chartSubContainerView.addSubview(progressHUD)
        }
        
        // catch if the data is old and
        // cannot be filtered by the segmented control0
//        let lastDate = self.modelPoints.last?.0
        if let lastDate = self.modelPoints.last?.0, lastDate < (Date.dateXMonthsAgo(numberOfMonthsAgo: 6).timeIntervalSince1970), (lastDate < (Date.dateXYearsAgo(numberOfYearsAgo: integer ?? 0).timeIntervalSince1970) && integer ?? 0 > 0) {
            return
        }
        guard let integer = integer else {
            print("Filtering Dates for all dates")
            filterChartDates()
            return
        }
        print("Filtering Dates by \(integer)")
        filterChartDates(by: integer)
    }
}


extension ChartViewController: PickerControlDelegate {
    
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
}
