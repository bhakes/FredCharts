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
        
        guard let units = series.units else { fatalError() }
        // Build Label Settings
        let labelSettingsYAxis = ChartLabelSettings(font: ExamplesDefaults.labelFont, fontColor: .white)
        let labelSettingsXAxis = ChartLabelSettings(font: UIFont.systemFont(ofSize: 10) , fontColor: .white, rotation: CGFloat(0.0), rotationKeep: ChartLabelDrawerRotationKeep.top)
        
        // build chartpoints
        let chartPoints = modelPoints.map{ChartPoint(x: ChartAxisValueDouble($0.0, labelSettings: labelSettingsXAxis), y: ChartAxisValueDouble($0.1))}
        
        // build xValues and yValues
        let xValues = ChartAxisValuesStaticGenerator.generateXAxisValuesWithChartPoints(chartPoints, minSegmentCount: 5, maxSegmentCount: 10, multiple: 2, axisValueGenerator: {ChartAxisValueDate(date: Date(timeIntervalSince1970: $0), formatter: {return self.getDateFormatter(with: $0)}, labelSettings: labelSettingsXAxis)}, addPaddingSegmentIfEdge: false)
        
        let firstModelValue = modelPoints.max {$0.1>$1.1}?.1
        let lastModelValue = modelPoints.min{$0.1>$1.1}?.1
        
        let valuesGenerator = ChartAxisGeneratorMultiplier(((lastModelValue ?? 1) - (firstModelValue ?? 0))/10)
        
        let numberFormatter = NumberFormatter.getNumberFormatter(with: units)
        
        let labelsGenerator = ChartAxisLabelsGeneratorNumber(labelSettings: labelSettingsYAxis, formatter: numberFormatter)
        
//        let yValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 5, maxSegmentCount: 10, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettingsYAxis)}, addPaddingSegmentIfEdge: false)
//
        
        let yModel = ChartAxisModel(firstModelValue: firstModelValue ?? 0, lastModelValue: lastModelValue ?? 1, axisTitleLabel: ChartAxisLabel(text: units, settings: labelSettingsYAxis.defaultVertical()), axisValuesGenerator: valuesGenerator, labelsGenerator: labelsGenerator)
        
        // build xModels and yModels
        let xModel = ChartAxisModel(axisValues: xValues)
//        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: series.units, settings: labelSettingsYAxis.defaultVertical()))
        
        // build chartFrame
        let chartFrame = viewToPlaceChart.bounds
        
        // build settings
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        
        // build coordsSpace
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        
        // build xAxisLayer, yAxisLayer, innerFrame
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        // Line Model
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.white, animDuration: 1, animDelay: 0)
        
        // Chart Points Line Layer
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel], useView: false)
        
        
        let thumbSettings = ChartPointsLineTrackerLayerThumbSettings(thumbSize: Env.iPad ? 24 : 12, thumbBorderWidth: Env.iPad ? 8 : 4)
        let trackerLayerSettings = ChartPointsLineTrackerLayerSettings(thumbSettings: thumbSettings)
        
        var currentPositionLabels: [UILabel] = []
        
        let chartPointsTrackerLayer = ChartPointsLineTrackerLayer<ChartPoint, Any>(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lines: [chartPoints], lineColor: UIColor.mainColor, animDuration: 1, animDelay: 2, settings: trackerLayerSettings) {chartPointsWithScreenLoc in
            
            currentPositionLabels.forEach{$0.removeFromSuperview()}
            
            for (index, chartPointWithScreenLoc) in chartPointsWithScreenLoc.enumerated() {
                
                let label = UILabel()
                let date = Date(timeIntervalSince1970: chartPointWithScreenLoc.chartPoint.x.scalar)
                
                label.text = "\(self.getDateFormatter(with: date)) - \(String(format: "%.2f",chartPointWithScreenLoc.chartPoint.y.scalar))"
                label.sizeToFit()
                label.center = CGPoint(x: chartPointWithScreenLoc.screenLoc.x + label.frame.width / 2, y: chartPointWithScreenLoc.screenLoc.y + chartFrame.minY - label.frame.height / 2)
                label.backgroundColor = index == 0 ? UIColor.white : UIColor.lightAccentColor
                label.textColor = UIColor.mainColor
                
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
    
    
    func updateChart(with modelPoints: [GridPoint], for seriesRep: FredSeriesSRepresentation, in viewToPlaceChart: UIView) -> Chart{
        
        let units = seriesRep.units
        // Build Label Settings
        let labelSettingsYAxis = ChartLabelSettings(font: ExamplesDefaults.labelFont, fontColor: .white)
        let labelSettingsXAxis = ChartLabelSettings(font: UIFont.systemFont(ofSize: 10) , fontColor: .white, rotation: CGFloat(0.0), rotationKeep: ChartLabelDrawerRotationKeep.top)
        
        // build chartpoints
        let chartPoints = modelPoints.map{ChartPoint(x: ChartAxisValueDouble($0.0, labelSettings: labelSettingsXAxis), y: ChartAxisValueDouble($0.1))}
        
        // build xValues and yValues
        let xValues = ChartAxisValuesStaticGenerator.generateXAxisValuesWithChartPoints(chartPoints, minSegmentCount: 5, maxSegmentCount: 10, multiple: 2, axisValueGenerator: {ChartAxisValueDate(date: Date(timeIntervalSince1970: $0), formatter: {return self.getDateFormatter(with: $0)}, labelSettings: labelSettingsXAxis)}, addPaddingSegmentIfEdge: false)
        
        let firstModelValue = modelPoints.max {$0.1>$1.1}?.1
        let lastModelValue = modelPoints.min{$0.1>$1.1}?.1
        
        let valuesGenerator = ChartAxisGeneratorMultiplier(((lastModelValue ?? 1) - (firstModelValue ?? 0))/10)
        
        let numberFormatter = NumberFormatter.getNumberFormatter(with: units)
        
        let labelsGenerator = ChartAxisLabelsGeneratorNumber(labelSettings: labelSettingsYAxis, formatter: numberFormatter)
        
        //        let yValues = ChartAxisValuesStaticGenerator.generateYAxisValuesWithChartPoints(chartPoints, minSegmentCount: 5, maxSegmentCount: 10, multiple: 2, axisValueGenerator: {ChartAxisValueDouble($0, labelSettings: labelSettingsYAxis)}, addPaddingSegmentIfEdge: false)
        //
        
        let yModel = ChartAxisModel(firstModelValue: firstModelValue ?? 0, lastModelValue: lastModelValue ?? 1, axisTitleLabel: ChartAxisLabel(text: units, settings: labelSettingsYAxis.defaultVertical()), axisValuesGenerator: valuesGenerator, labelsGenerator: labelsGenerator)
        
        // build xModels and yModels
        let xModel = ChartAxisModel(axisValues: xValues)
        //        let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: series.units, settings: labelSettingsYAxis.defaultVertical()))
        
        // build chartFrame
        let chartFrame = viewToPlaceChart.bounds
        
        // build settings
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        
        // build coordsSpace
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        
        // build xAxisLayer, yAxisLayer, innerFrame
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        // Line Model
        let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.white, animDuration: 1, animDelay: 0)
        
        // Chart Points Line Layer
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel], useView: false)
        
        
        let thumbSettings = ChartPointsLineTrackerLayerThumbSettings(thumbSize: Env.iPad ? 24 : 12, thumbBorderWidth: Env.iPad ? 8 : 4)
        let trackerLayerSettings = ChartPointsLineTrackerLayerSettings(thumbSettings: thumbSettings)
        
        var currentPositionLabels: [UILabel] = []
        
        let chartPointsTrackerLayer = ChartPointsLineTrackerLayer<ChartPoint, Any>(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lines: [chartPoints], lineColor: UIColor.mainColor, animDuration: 1, animDelay: 2, settings: trackerLayerSettings) {chartPointsWithScreenLoc in
            
            currentPositionLabels.forEach{$0.removeFromSuperview()}
            
            for (index, chartPointWithScreenLoc) in chartPointsWithScreenLoc.enumerated() {
                
                let label = UILabel()
                let date = Date(timeIntervalSince1970: chartPointWithScreenLoc.chartPoint.x.scalar)
                
                label.text = "\(self.getDateFormatter(with: date)) - \(String(format: "%.2f",chartPointWithScreenLoc.chartPoint.y.scalar))"
                label.sizeToFit()
                label.center = CGPoint(x: chartPointWithScreenLoc.screenLoc.x + label.frame.width / 2, y: chartPointWithScreenLoc.screenLoc.y + chartFrame.minY - label.frame.height / 2)
                label.backgroundColor = index == 0 ? UIColor.white : UIColor.lightAccentColor
                label.textColor = UIColor.mainColor
                
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
        dateFormatter.dateFormat = "M/YY"
        dateFormatter.locale = Locale(identifier: "en_US")
        let stringToReturn = dateFormatter.string(from: date)
        return stringToReturn
    }
    
    
}

