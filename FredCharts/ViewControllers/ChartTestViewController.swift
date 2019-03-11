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
        
        self.title = series.title
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
        registerTableViewCellNibs()
    }
    
    func registerTableViewCellNibs(){
        chartDetailsTableView.register(UINib(nibName: "ChartSegmentedControlTableViewCell", bundle: nil), forCellReuseIdentifier: segmentedControlReuseID)
        chartDetailsTableView.register(UINib(nibName: "ChartNormalControlTableViewCell", bundle: nil), forCellReuseIdentifier: normalControlReuseID)
        chartDetailsTableView.register(UINib(nibName: "ChartSliderControlTableViewCell", bundle: nil), forCellReuseIdentifier: sliderControlReuseID)
    }
    
    func updateChart(){
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let chartPoints = modelPoints.map{ChartPoint(x: ChartAxisValueDouble($0.0, labelSettings: labelSettings), y: ChartAxisValueDouble($0.1))}
        
        let xValues = chartPoints.map{$0.x}
        
        let yValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 10, maxSegmentCount: 20, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettings)}, addPaddingSegmentIfEdge: false)
        
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Year", settings: labelSettings))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: series?.units ?? "", settings: labelSettings.defaultVertical()))
        let chartFrame = chartContainerView.bounds
        
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.red, animDuration: 1, animDelay: 0)
        
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel], useView: false)
        
        let thumbSettings = ChartPointsLineTrackerLayerThumbSettings(thumbSize: Env.iPad ? 20 : 10, thumbBorderWidth: Env.iPad ? 4 : 2)
        let trackerLayerSettings = ChartPointsLineTrackerLayerSettings(thumbSettings: thumbSettings)
        
        var currentPositionLabels: [UILabel] = []
        
        let chartPointsTrackerLayer = ChartPointsLineTrackerLayer<ChartPoint, Any>(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lines: [chartPoints], lineColor: UIColor.black, animDuration: 1, animDelay: 2, settings: trackerLayerSettings) {chartPointsWithScreenLoc in
            
            currentPositionLabels.forEach{$0.removeFromSuperview()}
            
            for (index, chartPointWithScreenLoc) in chartPointsWithScreenLoc.enumerated() {
                
                let label = UILabel()
                label.text = chartPointWithScreenLoc.chartPoint.description
                label.sizeToFit()
                label.center = CGPoint(x: chartPointWithScreenLoc.screenLoc.x + label.frame.width / 2, y: chartPointWithScreenLoc.screenLoc.y + chartFrame.minY - label.frame.height / 2)
                
                label.backgroundColor = index == 0 ? UIColor.red : UIColor.blue
                label.textColor = UIColor.white
                
                currentPositionLabels.append(label)
                self.chartContainerView.addSubview(label)
            }
        }
        
//        let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.black, linesWidth: ExamplesDefaults.guidelinesWidth)
//        let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: settings)
        
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
//                guidelinesLayer,
                chartPointsLineLayer,
                chartPointsTrackerLayer
            ]
        )
        
        chartContainerView.addSubview(chart.view)
        self.chart = chart
        
    }
    
    // Mark: - Parse Observation into ChartModel
    
    func parseObseration (for seriesObservations: Observations) ->[GridPoint]{
        
        
        var counter = 0
        for observation in seriesObservations.observations {
            
            guard let value = Double(observation.value) else { continue }
          
            let dateValue = Double(counter)
            let gp = GridPoint(dateValue, value)
            modelPoints.append(gp)
            counter += 1
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
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 10
//    }
//

    
    // MARK: - Properties
    var seriesObservations: Observations?
    fileprivate var chart: Chart?
    var series: FredSeriesS?
    var modelPoints: [GridPoint] = []
    var fredController: FredController?
    @IBOutlet weak var chartContainerView: UIView!
    @IBOutlet weak var chartDetailsTableView: ChartDetailsTableView!
    
    let segmentedControlReuseID = "SegmentedControlCell"
    let normalControlReuseID = "NormalControlCell"
    let sliderControlReuseID = "SliderControlCell"
}
