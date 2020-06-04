//
//  CircleChartView.swift
//  BenefitManager2
//
//  Created by Kohei Konishi on 2020/05/03.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

class CircleChartView: NSView, CAAnimationDelegate {
    private let animationLayer = CAShapeLayer()
    private var chartLayers: [CAShapeLayer] = []
    private let shadowLayer = CAShapeLayer()
    private let titleLayer = CATextLayer()
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
    
    private func setUpAnimationLayer() {
        animationLayer.frame = self.bounds
        animationLayer.lineCap = .butt
        animationLayer.lineWidth = self.bounds.height * 0.8
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
        self.layer?.mask = (animationLayer)
        
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
        coveringPath1.addArc(center: CGPoint(x: self.bounds.width / 2.0,
                                             y: self.bounds.height / 2.0),
                            radius: self.bounds.height * 0.4,
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
        
        self.chartCircleWidth = self.bounds.height * 0.2
        for value in self.ratioSource {
            // ignore the data if it is zero
            if value == 0 { continue }
            
            let tempLayer = CAShapeLayer()
            tempLayer.opacity = 1
            tempLayer.frame = self.bounds
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
            self.layer?.addSublayer(tempLayer)
            
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
        
        shadowLayer.frame = self.bounds
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
        self.layer?.addSublayer(shadowLayer)
        
        shadowLayer.actions = [
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
    
    private func setUpTitleLayer() {
        //titleLayer.isWrapped = true
        titleLayer.backgroundColor = .clear
        titleLayer.foregroundColor = NSColor.systemGray.cgColor
        titleLayer.font = NSFont.boldSystemFont(ofSize: 10)
        titleLayer.alignmentMode = .center
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
        
        self.layer?.addSublayer(titleLayer)
        if !firstAppearing {
            setTitleLayerFrame(chartTitle)
        }
    }
    
    private func setTitleLayerFrame(_ title: String?) {
        // Temporary FontSize
        var tempFontSize: CGFloat = self.bounds.height * 0.1
        let chartCentralInterval = (2 * chartCircleRadius - chartCircleWidth) * 0.8
        
        // Configure Paragraph Style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        let constraintsSize = NSSize(width: self.bounds.width, height: self.bounds.height)
        
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
        
        titleLayer.string = title
        titleLayer.fontSize = (tempFontSize)
        titleLayer.frame = CGRect(x: self.bounds.minX,
                                  y: self.bounds.height * 0.5 - ceil(textSize.height) * 0.5,
                                  width: self.bounds.maxX,
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
        setUpAnimationLayer()
        setUpShadowLayer()
        setUpChartLayer()
        setUpTitleLayer()
        
        if firstAppearing {
            appearingAnimation(self.bounds)
        } else {
            animationLayer.setNeedsLayout()
        }
        titleLayer.setNeedsLayout()
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
