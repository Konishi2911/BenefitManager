//
//  CircleChartViewChartView.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/26.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

class CircleChartViewChartView: NSView, CAAnimationDelegate {
    private var firstAppearing = true
    
    private var chartRegion = CGRect()
    private let chartBaseLayer = CALayer()
    private let animationLayer = CAShapeLayer()
    private var chartLayers: [CAShapeLayer] = []
    private let shadowLayer = CAShapeLayer()
    
    private var chartCircleRadius: CGFloat = 0.0
    private var chartCircleWidth: CGFloat = 0.0
    
    private var relativeSource: [Double] = []
    private var colorSet: [NSColor] = [.init(red: 0.49, green: 0.81, blue: 0.42, alpha: 1),
                                       .init(red: 0.39, green: 0.65, blue: 0.34, alpha: 1),
                                       .init(red: 0.29, green: 0.49, blue: 0.34, alpha: 1),
                                       .init(red: 0.20, green: 0.32, blue: 0.17, alpha: 1),
                                       .init(red: 0.10, green: 0.16, blue: 0.08, alpha: 1)
    ]
    
    override var wantsUpdateLayer: Bool { return true }
    var relativeDataSource: [Double] {
        get {
            return relativeSource
        }
        set(source) {
            relativeSource = source
            self.needsDisplay = true
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        
        makeRegion()
        
        print("chartViewChartView: \(self.bounds)")
    }
    
    private func makeRegion() {
        let margineMinX: CGFloat = 20.0
        chartRegion = CGRect(x: margineMinX,
                             y: 10.0,
                             width: self.bounds.height,
                             height: self.bounds.height - 20
        )
    }
    
    private func setUpChartBaseLayer() {
        chartBaseLayer.frame = chartRegion
        chartBaseLayer.autoresizingMask = .init(
            arrayLiteral:
            .layerHeightSizable,
            //.layerMaxXMargin,
            .layerMaxYMargin,
            .layerMinXMargin,
            .layerMinYMargin,
            .layerWidthSizable
        )
        chartBaseLayer.actions = [
            "bounds": NSNull(),
            "frame": NSNull(),
            "contents": NSNull(),
            "position": NSNull(),
            "transform": NSNull(),
            "lineWidth": NSNull()
        ]
        self.layer?.addSublayer(chartBaseLayer)
        
        print("chartBase: \(chartBaseLayer.frame)")
    }
    private func setUpAnimationLayer() {
        animationLayer.frame = chartBaseLayer.bounds
        animationLayer.lineCap = .butt
        animationLayer.lineWidth = animationLayer.bounds.height * 0.8
        //animationLayer.lineWidth = 1
        animationLayer.strokeColor = NSColor.blue.cgColor
        animationLayer.fillColor = NSColor.clear.cgColor
        animationLayer.autoresizingMask = .init(
            arrayLiteral:
            .layerHeightSizable,
            //.layerMaxXMargin,
            //.layerMaxYMargin,
            //.layerMinXMargin,
            //.layerMinYMargin,
            .layerWidthSizable
        )
        //self.layer?.addSublayer(animationLayer)
        chartBaseLayer.mask = (animationLayer)
        
        animationLayer.actions = [
            "bounds": NSNull(),
            "frame": NSNull(),
            "contents": NSNull(),
            "position": NSNull(),
            "transform": NSNull(),
            "lineWidth": NSNull()
        ]
        
        // Set Animation Path
        let coveringPath1 = CGMutablePath()
        coveringPath1.addArc(center: CGPoint(x: animationLayer.bounds.width / 2.0,
                                             y: animationLayer.bounds.height / 2.0),
                             radius: animationLayer.bounds.height * 0.4,
                            startAngle: CGFloat(0.5 * .pi),
                            endAngle: CGFloat(2.5 * .pi),
                            clockwise: false)
        
        animationLayer.path = coveringPath1
    }
    
    private func setUpChartLayer() {
        var colorIterator: Int = 0
        var previousAngle: Double = 0.5 * Double.pi
        
        // Remove Current ChartLAyer
        for layer in self.chartLayers {
            layer.removeFromSuperlayer()
        }
        chartLayers.removeAll()
        
        self.chartCircleWidth = chartBaseLayer.bounds.height * 0.2
        for value in self.relativeSource {
            // ignore the data if it is zero
            if value == 0 { continue }
            
            let tempLayer = CAShapeLayer()
            tempLayer.opacity = 1
            tempLayer.frame = chartBaseLayer.bounds
            tempLayer.lineCap = .butt
            tempLayer.lineWidth = chartCircleWidth
            
            // Set Chart Color
            if colorIterator >= colorSet.count { colorIterator = 0 }
            tempLayer.strokeColor = colorSet[colorIterator].cgColor
            tempLayer.fillColor = .clear
            colorIterator += 1
            
            tempLayer.autoresizingMask = .init(
                arrayLiteral:
                .layerHeightSizable,
                .layerWidthSizable
            )
            tempLayer.actions = [
                "bounds": NSNull(),
                "frame": NSNull(),
                "contents": NSNull(),
                "position": NSNull(),
                "transform": NSNull(),
                "lineWidth": NSNull()
            ]
            self.chartLayers.append(tempLayer)
            chartBaseLayer.addSublayer(tempLayer)
            
            // Set Chart Circle Path
            let chartPath = CGMutablePath()
            self.chartCircleRadius = tempLayer.bounds.height * 0.35
            chartPath.addArc(center: CGPoint(x: tempLayer.bounds.width / 2.0,
                                             y: tempLayer.bounds.height / 2.0),
                            radius: chartCircleRadius,
                            startAngle: CGFloat(previousAngle),
                            endAngle: CGFloat(previousAngle + (2 * .pi * value)),
                            clockwise: false)
            tempLayer.path = chartPath
            previousAngle += (2 * .pi * value)
        }
    }
    
    private func setUpShadowLayer() {
         //let shadowMask = CAShapeLayer()
         //shadowMask.frame = shadowLayer.bounds
         
         shadowLayer.frame = chartBaseLayer.bounds
         //shadowLayer.fillColor = .black
         shadowLayer.fillRule = .evenOdd
         shadowLayer.opacity = 0.8
         
         shadowLayer.shouldRasterize = true
         shadowLayer.shadowColor = .black
         shadowLayer.shadowRadius = 5
         shadowLayer.shadowOpacity = 1
         shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
         
         shadowLayer.autoresizingMask = .init(
             arrayLiteral:
             .layerHeightSizable,
             .layerWidthSizable
         )
         chartBaseLayer.addSublayer(shadowLayer)
         
         chartBaseLayer.actions = [
             "bounds": NSNull(),
             "frame": NSNull(),
             "contents": NSNull(),
             "position": NSNull(),
             "transform": NSNull(),
             "lineWidth": NSNull()
         ]
         
         // Set Animation Path
         let shadowPathOut = CGMutablePath()
         //let shadowPathIn = CGMutablePath()
         shadowPathOut.addArc(center: CGPoint(x: shadowLayer.bounds.width / 2.0,
                                              y: shadowLayer.bounds.height / 2.0),
                             radius: shadowLayer.bounds.height * 0.45,
                             startAngle: CGFloat(0.5 * .pi),
                             endAngle: CGFloat(2.5 * .pi),
                             clockwise: false)
         shadowPathOut.addArc(center: CGPoint(x: shadowLayer.bounds.width / 2.0 ,
                                              y: shadowLayer.bounds.height / 2.0),
                             radius: shadowLayer.bounds.height * 0.25,
                             startAngle: CGFloat(0.5 * .pi),
                             endAngle: CGFloat(2.5 * .pi),
                             clockwise: false)
     
         shadowLayer.path = shadowPathOut
         //shadowLayer.mask
     }
    private func appearingAnimation(_ dirtyRect: NSRect) {
        let animation = CAKeyframeAnimation(keyPath: "strokeEnd")
        animation.values = [0,1]
        animation.keyTimes = [0, 1.0]
        animation.duration = 0.5
        animation.delegate = self
        
        animation.isRemovedOnCompletion = false
        animationLayer.add(animation, forKey: "appearingAnimation")
    }
    override func updateLayer() {
        makeRegion()
        
        setUpChartBaseLayer()
        setUpAnimationLayer()
        setUpShadowLayer()
        setUpChartLayer()
        
        if firstAppearing {
            appearingAnimation(chartRegion)
        } else {
            animationLayer.setNeedsLayout()
        }
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        //
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            firstAppearing = false
            animationLayer.removeAnimation(forKey: "appearingAnimation")
        }
    }
}
