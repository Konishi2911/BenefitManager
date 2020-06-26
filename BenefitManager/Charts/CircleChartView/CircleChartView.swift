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
    private var legendDetailLayers: [CALayer] = []
    private let titleLayer_deprecated = CATextLayer()
    private var displayLinks: CVDisplayLink? = nil
    
    private var chartCircleRadius: CGFloat = 0.0
    private var chartCircleWidth: CGFloat = 0.0
    
    private var chartTitle = ""
    private var firstAppearing = true
    private var dataSource: [Double] = []
    private var ratioSource: [Double] = []
    private var itemsNameSource: [String] = []
    private var colorSet: [NSColor] = [.init(red: 0.49, green: 0.81, blue: 0.42, alpha: 1),
                                       .init(red: 0.39, green: 0.65, blue: 0.34, alpha: 1),
                                       .init(red: 0.29, green: 0.49, blue: 0.34, alpha: 1),
                                       .init(red: 0.20, green: 0.32, blue: 0.17, alpha: 1),
                                       .init(red: 0.10, green: 0.16, blue: 0.08, alpha: 1)
    ]
    private let titleViewHeight: CGFloat = 30
    private let chartLegendRatio: CGFloat = 0.5
    
    override var wantsUpdateLayer: Bool { return true }
    
    @IBOutlet weak var chartView: CircleChartViewChartView?
    @IBOutlet weak var legendScrollView: NSScrollView!
    @IBOutlet weak var legendView: CircleChartView_LegendView?
    
    override private init(frame frameRect: NSRect) {
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
        super.init(coder: coder)
        
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
        loadNib()
    }
    private func loadNib() {
        if let success = NSNib(nibNamed: "CircleChartVeiwLayout", bundle: nil)?.instantiate(withOwner: self, topLevelObjects: nil), success {
                        
            chartView?.frame = CGRect(x: 0, y: 0,
                                      width: self.frame.width * chartLegendRatio,
                                      height: self.frame.height)
            legendScrollView.frame = CGRect(x: self.frame.width * chartLegendRatio, y: 0,
                                            width: self.frame.width * (1 - chartLegendRatio),
                                            height: self.frame.height - titleViewHeight)
            //legendView?.frame = CGRect(x: 0, y: self.frame.width * 0.5,
              //                         width: self.frame.width * 0.5,
                //                       height: self.frame.height)
            self.addSubview(chartView!)
            self.addSubview(legendScrollView!)
        }
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
        let margineLeftside: CGFloat = 20
        let margineTop: CGFloat = 7
        let iconSize: CGFloat = 15
        let textMargineLeft: CGFloat = 10
        let textHeight: CGFloat = 22
        let detailMargineTop: CGFloat = 0
        let detailMargineLeft: CGFloat = 14
        let detailHeight: CGFloat = 20
        let fontSize: CGFloat = 18
        
        let itemHeight: CGFloat = margineTop + textHeight + detailMargineTop + detailHeight
        
        var dataIterator: Int = 0
        
        // Remove Current ChartLAyer
        for layer in self.legendIconLayers {
            layer.removeFromSuperlayer()
        }
        for layer in self.legendTextLayers {
            layer.removeFromSuperlayer()
        }
        for layer in self.legendDetailLayers {
            layer.removeFromSuperlayer()
        }
        legendIconLayers.removeAll()
        legendTextLayers.removeAll()
        legendDetailLayers.removeAll()
        
        for value in self.ratioSource {
            // ignore the data if it is zero
            if value == 0 { continue }
            
            // Legend Icon
            let iconLayer = CALayer()
            iconLayer.opacity = 1
            iconLayer.frame = CGRect(x: CGFloat(margineLeftside),
                                     y: legendLayer.bounds.height * 0.8
                                        - CGFloat(Double(dataIterator) + 0.5) * itemHeight
                                        - (iconSize + margineTop) * 0.5,
                                     width: iconSize,
                                     height: iconSize)
            // Legend Text
            let textLayer = CATextLayer()
            textLayer.foregroundColor = NSColor.textColor.cgColor
            textLayer.frame = CGRect(x: CGFloat(margineLeftside + iconSize + textMargineLeft),
                                     y: legendLayer.bounds.height * 0.8
                                        - CGFloat(dataIterator + 1) * itemHeight
                                        + detailHeight + detailMargineTop,
                                     width: legendLayer.bounds.width - 50,
                                     height: textHeight)
            textLayer.fontSize = fontSize
            
            // Legend Details
            let detailLayer = CATextLayer()
            detailLayer.foregroundColor = NSColor.darkGray.cgColor
            detailLayer.frame = CGRect(x: CGFloat(margineLeftside + iconSize + detailMargineLeft),
                                     y: legendLayer.bounds.height * 0.8
                                        - CGFloat(dataIterator + 1) * itemHeight,
                                     width: legendLayer.bounds.width - 50,
                                     height: detailHeight * 0.8)
            detailLayer.fontSize = fontSize * 0.8
            
            // Set Legend Title
            if itemsNameSource.count > dataIterator {
                textLayer.string = itemsNameSource[dataIterator]
            } else {
                textLayer.string = "items\(dataIterator + 1)"
            }
            // Set Detail Datas
            if ratioSource.count > dataIterator {
                detailLayer.string = String(format: "%.1f", (ratioSource[dataIterator] * 1000).rounded() * 0.1)
                    + " %  |  ¥\(dataSource[dataIterator])"
            } else {
                detailLayer.string = "---"
            }
            
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
            self.legendDetailLayers.append(detailLayer)
            legendLayer.addSublayer(iconLayer)
            legendLayer.addSublayer(textLayer)
            legendLayer.addSublayer(detailLayer)
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
        
        self.chartView?.relativeDataSource = ratioValue
        self.legendView?.dataSource = valueSet
        self.legendView?.relativeDataSource = ratioValue
        
        self.needsDisplay = true
        //draw(self.bounds)
        //updateLayer()
    }
    func setItemNames(source strArray: [String]) {
        self.itemsNameSource = strArray
        
        self.legendView?.nameSource = strArray
    }
    
    override func updateLayer() {
        chartView?.needsDisplay = true
        legendView?.needsDisplay = true
        
        /*
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
 */
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
