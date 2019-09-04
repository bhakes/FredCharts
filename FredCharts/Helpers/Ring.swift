//
//  Ring.swift
//  FredCharts
//
//  Created by Benjamin Hakes on 8/29/19.
//  Copyright © 2019 Benjamin Hakes. All rights reserved.
//


import UIKit

/// make the UIView a ring of color
class Ring:UIView
{
    override func draw(_ rect: CGRect)
    {
        drawRingFittingInsideView()
    }
    
    internal func drawRingFittingInsideView()->()
    {
        let halfSize:CGFloat = min( bounds.size.width/2, bounds.size.height/2)
        let desiredLineWidth:CGFloat = 4   // your desired value
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x:halfSize,y:halfSize),
            radius: CGFloat( halfSize - (desiredLineWidth/2) ),
            startAngle: CGFloat(0),
            endAngle: CGFloat(Double.pi * 2),
            clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.mainColor.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        layer.addSublayer(shapeLayer)
    }
}
