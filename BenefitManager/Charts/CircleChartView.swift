//
//  CircleChartView.swift
//  BenefitManager2
//
//  Created by Kohei Konishi on 2020/05/03.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

class CircleChartView: NSView, CAAnimationDelegate {
    private var debuggingCounter = 0
    
    private var chartRegion = CGRect()
    private var legendRegion = CGRect()
    
    private let legendLayer = CALayer()
    private let chartBaseLayer = CALayer()
    private let animationLayer = CAShapeLayer()
    private var chartLayers: [CAShapeLayer] = []
    private let shadowLayer = CAShapeLayer()
    private let titleLayer = CATextLayer()
    private var legendIconLayers: [CALayer] = []
    private var legendTextLayers: [CATextLayer] = []
    private let titleLayer_deprecated = CATextLayer()
    private var displayLinks: CVDisplayLink? = nil
    
    private var chartCircleRadius: CGFloat = 0.0
    private var chartCircleWidth: CGFloat = 0.0
    
    private var chartTitle = ""
    private var firstAppearing = true
    private var values: [Double] = []
    private var dataSource: [Double] = []
    private var ratioSource: [Double] = []
    private var colorSet: [NSColor] = [.init(red: 0.49, green: 0.81, blue: 0.42, alpha: 1),
                                       .init(red: 0.39, green: 0.65, blue: 0.34, alpha: 1),
                                       .init(red: 0.29, green: 0.49, blue: 0.34, alpha: 1),
                                       .init(red: 0.20, green: 0.32, blue: 0.17, alpha: 1),
                                       .init(red: 0.10, green: 0.16, blue: 0.08, alpha: 1)
    ]
    override var wantsUpdateLayer: Bool { return true }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        // Make Region
        makeRegion()
        
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        autoresizesSubviews = true
        
        postsBoundsChangedNotifications = true
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(type(of: self).frameSizeDidChageNotification(notification:)),
                       name: CircleChartView.frameDidChangeNotification,
                       object: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func makeRegion() {
        // Make Region
        let widthHeightDif = self.bounds.width * 0.5 - self.bounds.height
        
        var margineMinX: CGFloat = 0.0
        var legendWidth: CGFloat = self.bounds.height
        if widthHeightDif > 0.0 {
            margineMinX = widthHeightDif
            legendWidth = self.bounds.width * 0.5
        }
        
        chartRegion = CGRect(x: margineMinX,
                             y: 0.0,
                             width: self.bounds.height,
                             height: self.bounds.height
        )
        legendRegion = CGRect(x: legendWidth,
                              y: 0.0,
                              width: legendWidth,
                              height: self.bounds.height
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
        for value in self.ratioSource {
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
    
    private func setUpLegendLayer() {
        legendLayer.frame = legendRegion
        legendLayer.backgroundColor = .clear
        legendLayer.autoresizingMask = .init(
            arrayLiteral:
            .layerHeightSizable,
            .layerWidthSizable
        )
        self.layer?.addSublayer(legendLayer)
        legendLayer.actions = [
            "bounds": NSNull(),
            "frame": NSNull(),
            "contents": NSNull(),
            "position": NSNull(),
            "transform": NSNull()
        ]

    }
    private func setUpLegendItemLayers() {
        let margineLeftside: CGFloat = 10
        let margineTop: CGFloat = 15
        let iconSize: CGFloat = 15
        let textMargineLeft: CGFloat = 10
        let fontSize: CGFloat = 18
        var dataIterator: Int = 0
        
        // Remove Current ChartLAyer
        for layer in self.legendIconLayers {
            layer.removeFromSuperlayer()
        }
        for layer in self.legendTextLayers {
            layer.removeFromSuperlayer()
        }
        legendIconLayers.removeAll()
        legendTextLayers.removeAll()
        
        for value in self.ratioSource {
            // ignore the data if it is zero
            if value == 0 { continue }
            
            // Legend Icon
            let iconLayer = CALayer()
            iconLayer.opacity = 1
            iconLayer.frame = CGRect(x: CGFloat(margineLeftside),
                                     y: legendLayer.bounds.height * 0.8 - CGFloat(dataIterator + 1) * CGFloat(margineTop + iconSize),
                                     width: iconSize,
                                     height: iconSize)
            // Legend Text
            let textLayer = CATextLayer()
            textLayer.frame = CGRect(x: CGFloat(margineLeftside + iconSize + textMargineLeft),
                                     y: legendLayer.bounds.height * 0.8 - CGFloat(dataIterator + 1) * CGFloat(margineTop + iconSize),
                                     width: legendLayer.bounds.width - 50,
                                     height: 20)
            textLayer.fontSize = fontSize
            textLayer.string = "test \(dataIterator + 1)"
            
            // Set Chart Color
            if dataIterator >= colorSet.count { dataIterator = 0 }
            iconLayer.backgroundColor = colorSet[dataIterator].cgColor
            dataIterator += 1
            
            iconLayer.actions = [
                "bounds": NSNull(),
                "frame": NSNull(),
                "contents": NSNull(),
                "position": NSNull(),
                "transform": NSNull(),
                "lineWidth": NSNull()
            ]
            textLayer.actions = [
                "bounds": NSNull(),
                "frame": NSNull(),
                "contents": NSNull(),
                "position": NSNull(),
            ]

            // Add tempLayers to Collection
            self.legendIconLayers.append(iconLayer)
            self.legendTextLayers.append(textLayer)
            legendLayer.addSublayer(iconLayer)
            legendLayer.addSublayer(textLayer)
        }
    }
    private func setUpTitleLayer() {
        titleLayer.frame = CGRect(x: 0,
                                  y: legendRegion.height * 0.8,
                                  width: legendRegion.width,
                                  height: legendRegion.height * 0.2)
        titleLayer.backgroundColor = .clear
        titleLayer.foregroundColor = NSColor.systemGray.cgColor
        titleLayer.font = NSFont.boldSystemFont(ofSize: 16)
        titleLayer.alignmentMode = .left
        titleLayer.autoresizingMask = .init(
            arrayLiteral:
            .layerMaxXMargin,
            .layerMaxYMargin,
            .layerMinXMargin,
            .layerMinYMargin,
            .layerHeightSizable,
            .layerWidthSizable
        )
        titleLayer.actions = [
            "bounds": NSNull(),
            "frame": NSNull(),
            "fontSize": NSNull(),
            "position": NSNull()
        ]
        
        legendLayer.addSublayer(titleLayer)
        titleLayer.string = "Title"
    }
    
    private func setUpTitleLayer_Deprecated() {
        //titleLayer.isWrapped = true
        titleLayer_deprecated.backgroundColor = .clear
        titleLayer_deprecated.foregroundColor = NSColor.systemGray.cgColor
        titleLayer_deprecated.font = NSFont.boldSystemFont(ofSize: 10)
        titleLayer_deprecated.alignmentMode = .center
        titleLayer_deprecated.autoresizingMask = .init(
            arrayLiteral:
            .layerMaxXMargin,
            .layerMaxYMargin,
            .layerMinXMargin,
            .layerMinYMargin,
            .layerHeightSizable,
            .layerWidthSizable
        )
        
        titleLayer_deprecated.actions = [
            "bounds": NSNull(),
            "frame": NSNull(),
            "fontSize": NSNull(),
            "position": NSNull()
        ]
        
        self.layer?.addSublayer(titleLayer_deprecated)
        if !firstAppearing {
            setTitleLayerFrame(chartTitle)
        }
    }
    
    private func setTitleLayerFrame(_ title: String?) {
        // Temporary FontSize
        var tempFontSize: CGFloat = chartRegion.height * 0.1
        let chartCentralInterval = (2 * chartCircleRadius - chartCircleWidth) * 0.8
        
        // Configure Paragraph Style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        let constraintsSize = NSSize(width: chartRegion.width, height: chartRegion.height)
        
        var textSize: NSRect
        if title != nil {
            // Calculate Text Size
            textSize = NSString(string: title!).boundingRect(
                with: constraintsSize,
                options: NSString.DrawingOptions.usesLineFragmentOrigin,
                attributes: [ NSAttributedString.Key.font: NSFont.systemFont(ofSize: tempFontSize),
                              NSAttributedString.Key.paragraphStyle: paragraphStyle ],
                context: nil)
            
            // Adjust testLabel width if the textLabel width is overhanged
            let ovehangRatio = (textSize.width) / chartCentralInterval
            tempFontSize = tempFontSize / ovehangRatio
            
            // Set title Label Size
            textSize = NSRect(x: 0, y: 0,
                              width: textSize.width,
                              height: textSize.height / ovehangRatio)
        } else {
            textSize = NSRect(x: 0, y: 0, width: 100, height: 100)
        }
        
        titleLayer_deprecated.string = title
        titleLayer_deprecated.fontSize = (tempFontSize)
        titleLayer_deprecated.frame = CGRect(x: chartRegion.minX,
                                  y: chartRegion.height * 0.5 - ceil(textSize.height) * 0.5,
                                  width: chartRegion.maxX,
                                  height: ceil(textSize.height))
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
    
    func setTitle(_ title: String) {
        self.chartTitle = title
        //setTitleLayerFrame(chartTitle)
    }
    func setValues(source valueSet: [Int]) {
        var doubleValueSet: [Double] = []
        for value in valueSet {
            doubleValueSet.append(Double(value))
        }
        setValues(source: doubleValueSet)
    }
    func setValues(source valueSet: [Double]) {
        self.values = valueSet
        
        // Calculate Total
        var totalVal = 0.0
        for value in valueSet {
            totalVal += value
        }
        
        // Convert value to relative value
        var ratioValue: [Double] = []
        for value in valueSet {
            ratioValue.append(value / totalVal)
        }
        
        self.dataSource = valueSet
        self.ratioSource = ratioValue
        
        self.needsDisplay = true
        //draw(self.bounds)
        //updateLayer()
    }
    
    override func updateLayer() {
        print("updating layer\(debuggingCounter)")
        debuggingCounter += 1
        
        makeRegion()
        
        setUpChartBaseLayer()
        setUpAnimationLayer()
        setUpShadowLayer()
        setUpChartLayer()
        setUpLegendLayer()
        setUpLegendItemLayers()
        setUpTitleLayer()
        
        if firstAppearing {
            appearingAnimation(chartRegion)
        } else {
            animationLayer.setNeedsLayout()
        }
        titleLayer_deprecated.setNeedsLayout()
    }
    override func draw(_ dirtyRect: NSRect) {
        // configure the line Styles
        let context = NSGraphicsContext.current?.cgContext
        context?.setLineWidth(dirtyRect.height * 0.2)
        context?.setLineCap(.butt)
        context?.setShadow(offset: CGSize(width: 0, height: -0.2), blur: 3, color: .black)
        
        var colorIterator: Int = 0
        var previousAngle = (.pi / 2.0)
        for data in self.ratioSource {
            // ignore the data if it is zero
            if data == 0 { continue }
            
            // Set Chart Color
            if colorIterator >= colorSet.count { colorIterator = 0 }
            colorSet[colorIterator].set()
            colorIterator += 1
            
            // Add and Draw Chart Arc
            context?.addArc(center: CGPoint(x: dirtyRect.width / 2.0, y: dirtyRect.height / 2.0),
                            radius: dirtyRect.height * 0.3,
                            startAngle: CGFloat(previousAngle),
                            endAngle: CGFloat(previousAngle + (2 * .pi * data)),
                            clockwise: false)
            context?.strokePath()
            previousAngle += (2 * .pi * data)
        }
    }
    
    @objc func frameSizeDidChageNotification(notification: Notification) {
        self.needsDisplay = true
    }
    func animationDidStart(_ anim: CAAnimation) {
        //
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            firstAppearing = false
            animationLayer.removeAnimation(forKey: "appearingAnimation")
            //animationLayer.removeFromSuperlayer()
            
            setUpTitleLayer()
        }
    }
    override func viewWillStartLiveResize() {
        let callback: CVDisplayLinkOutputCallback = {
            (displayLink, inNow, inOutputTime, flagsIn, flagsOut, displayLinkContext) -> CVReturn in
            let mySelf = Unmanaged<CircleChartView>.fromOpaque(UnsafeRawPointer(displayLinkContext!)).takeUnretainedValue()
            
            // Execute on MainThread
            DispatchQueue.main.async {
                mySelf.needsDisplay = true
                //mySelf.needsLayout = true
            }
            return kCVReturnSuccess
        }
        
        let userInfo = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLinks)
        CVDisplayLinkSetOutputCallback(displayLinks!, callback, userInfo)
        //CVDisplayLinkStart(displayLinks!)
        
    }
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        
        //self.needsDisplay = true
        // Stop DisplayLink
        //CVDisplayLinkStop(displayLinks!)
    }
}
