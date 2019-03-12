//
//  ChartController.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 3/11/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//

import Foundation
import SwiftCharts



class ChartController {
    
    func updateChart(with modelPoints: [GridPoint], for series: FredSeriesS, in viewToPlaceChart: UIView) -> Chart{
        
        // Build Label Settings
        let labelSettingsYAxis = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        let labelSettingsXAxis = ChartLabelSettings(font: UIFont.systemFont(ofSize: 8) , rotation: CGFloat(90.0), rotationKeep: ChartLabelDrawerRotationKeep.top)
        
        // build chartpoints
        let chartPoints = modelPoints.map{ChartPoint(x: ChartAxisValueDouble($0.0, labelSettings: labelSettingsXAxis), y: ChartAxisValueDouble($0.1))}
        
        // build xValues and yValues
        let xValues = ChartAxisValuesStaticGenerator.generateXAxisValuesWithChartPoints(chartPoints, minSegmentCount: 5, maxSegmentCount: 10, multiple: 2, axisValueGenerator: {ChartAxisValueDate(date: Date(timeIntervalSince1970: $0), formatter: {return self.getDateFormatter(with: $0)}, labelSettings: labelSettingsXAxis)}, addPaddingSegmentIfEdge: false)
        let yValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 5, maxSegmentCount: 10, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettingsYAxis)}, addPaddingSegmentIfEdge: false)
        
        // build xModels and yModels
        let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Test", settings: labelSettingsYAxis))
        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: series.units, settings: labelSettingsYAxis.defaultVertical()))
        
        // build chartFrame
        let chartFrame = viewToPlaceChart.bounds
        
        // build settings
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        
        // build coordsSpace
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        
        // build xAxisLayer, yAxisLayer, innerFrame
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        // Line Model
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.darkAccentColor, animDuration: 1, animDelay: 0)
        
        // Chart Points Line Layer
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel], useView: false)
        
        
        let thumbSettings = ChartPointsLineTrackerLayerThumbSettings(thumbSize: Env.iPad ? 12 : 6, thumbBorderWidth: Env.iPad ? 4 : 2)
        let trackerLayerSettings = ChartPointsLineTrackerLayerSettings(thumbSettings: thumbSettings)
        
        var currentPositionLabels: [UILabel] = []
        
        let chartPointsTrackerLayer = ChartPointsLineTrackerLayer<ChartPoint, Any>(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lines: [chartPoints], lineColor: UIColor.black, animDuration: 1, animDelay: 2, settings: trackerLayerSettings) {chartPointsWithScreenLoc in
            
            currentPositionLabels.forEach{$0.removeFromSuperview()}
            
            for (index, chartPointWithScreenLoc) in chartPointsWithScreenLoc.enumerated() {
                
                let label = UILabel()
                let date = Date(timeIntervalSince1970: chartPointWithScreenLoc.chartPoint.x.scalar)
                
                label.text = "\(self.getDateFormatter(with: date)) - \(String(format: "%.2f",chartPointWithScreenLoc.chartPoint.y.scalar))"
                label.sizeToFit()
                label.center = CGPoint(x: chartPointWithScreenLoc.screenLoc.x + label.frame.width / 2, y: chartPointWithScreenLoc.screenLoc.y + chartFrame.minY - label.frame.height / 2)
                label.backgroundColor = index == 0 ? UIColor.darkAccentColor : UIColor.darkAccentColor
                label.textColor = UIColor.lightAccentColor
                
                currentPositionLabels.append(label)
                viewToPlaceChart.addSubview(label)
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
        return chart

    }
    
    func getDateFormatter(with date: Date) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM-YYYY"
        dateFormatter.locale = Locale(identifier: "en_US")
        let stringToReturn = dateFormatter.string(from: date)
        return stringToReturn
    }
    
    func formatChartDates(for chart: Chart, with beginDate: Date, and endDate: Date){
        
        
        
    }
    
}

