//
//  BarChartView.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/07/09.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

class BarChartView: NSView {
    private let _xLableViewHeight: CGFloat = 40
    private let _yLableViewWidth: CGFloat = 45
    
    private var _minY: CGFloat = 0.0
    private var _maxY: CGFloat = 0.0
    private var _stepsY: Int = 0;
    private var _intervalX: CGFloat = 0.0
    private var _intervalY: CGFloat = 0.0
    private var _margine: CGFloat = 10
    
    var axisXLabel: String = ""
    
    private var seriesData: [Double] = []
    private var seriesNames: [String] = []
    
    @IBOutlet weak var chartView: BarChartView_ChartView!
    @IBOutlet weak var yLabelView: BarChartView_YLabelView!
    @IBOutlet weak var xLabelView: BarChartView_XLabelView!
    
    var enableAutoAdjustYScale: Bool = false
    var minY: CGFloat {
        get {
            return _minY
        }
        set(t) {
            _minY = t
            chartView.minY = _minY;
            yLabelView.minY = _minY;
            
            makeCommonVals()
        }
    }
    var maxY: CGFloat {
        get {
            return _maxY
        }
        set(t) {
            _maxY = t
            chartView.maxY = _maxY;
            yLabelView.maxY = _maxY;
            
            makeCommonVals()
        }
    }
    var stepsY: Int {
        get {
            return _stepsY;
        }
        set(t) {
            _stepsY = t
            chartView.axisSteps = _stepsY;
            yLabelView.ySteps = _stepsY;
            
            makeCommonVals();
        }
    }
    
    override var wantsUpdateLayer: Bool { get { return true } }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        autoresizesSubviews = true
        
        postsBoundsChangedNotifications = true
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(type(of: self).frameSizeDidChageNotification(notification:)),
                       name: BarChartView.frameDidChangeNotification,
                       object: nil)
        
        loadNib()
    }
    
    private func adjuxtYScalse() {
        guard seriesData.count != 0 else { return }
        
        var maxVal: Double = seriesData[0]
        for data in seriesData {
            if maxVal < data {
                maxVal = data
            }
        }
        var iteration: Int = 0
        while(true) {
            if (maxVal < 10) { break }
            maxVal *= 0.1
            iteration += 1
        }
        maxVal = round(maxVal) * pow(10, Double(iteration))
        
        maxY = CGFloat(maxVal * 1.1)
        self.needsDisplay = true
    }
    private func makeCommonVals() {
        guard _stepsY != 0 else { return }
        _intervalX = (chartView.bounds.width - 2 * _margine) / CGFloat(seriesNames.count + 1)
        _intervalY = (chartView.bounds.height - 2 * _margine) / CGFloat(_stepsY)
    }
    private func loadNib() {
        if let success = NSNib(nibNamed: "BarChartView", bundle: nil)?.instantiate(withOwner: self, topLevelObjects: nil), success {
            
            chartView?.frame = CGRect(x: _yLableViewWidth, y: _xLableViewHeight,
                                      width: self.frame.width - _yLableViewWidth,
                                      height: self.frame.height - _xLableViewHeight)
            xLabelView.frame = CGRect(x: _xLableViewHeight, y: 0,
                                      width: self.bounds.width - _yLableViewWidth,
                                      height: _xLableViewHeight);
            yLabelView.frame = CGRect(x: 0, y: _xLableViewHeight,
                                      width: _yLableViewWidth,
                                      height: self.bounds.height - _xLableViewHeight);
            self.addSubview(chartView!)
            self.addSubview(xLabelView)
            self.addSubview(yLabelView);
        }
    }
    
    func setSeriesNameSource<T: LosslessStringConvertible>(from names: [T]) {
        var seriesNames: [String] = []
        for name in names {
            seriesNames.append(String(name))
        }
        setSeriesNameSource(from: seriesNames)
    }
    func setSeriesNameSource(from names: [String]) {
        self.seriesNames = names
        xLabelView.setSeriesLables(from: names);
        self.needsDisplay = true
    }
    func setDataSource(from data: [Int]) {
        var doubleData: [Double] = []
        for value in data {
            doubleData.append(Double(value))
        }
        
        setDataSource(from: doubleData)
    }
    func setDataSource(from data: [Double]) {
        self.seriesData = data
        chartView.seriesData = data
        self.needsDisplay = true
        
        if enableAutoAdjustYScale {
            adjuxtYScalse()
        }
    }
    
    override func updateLayer() {
        makeCommonVals();
        chartView.margine = _margine;
        xLabelView.margine = _margine
        xLabelView.xInterval = _intervalX
        yLabelView.margine = _margine;
        yLabelView.yInterval = _intervalY
        
        chartView.needsDisplay = true
        xLabelView.needsDisplay = true
        yLabelView.needsDisplay = true
    }
    
    @objc func frameSizeDidChageNotification(notification: Notification) {
        self.needsDisplay = true
    }
}
