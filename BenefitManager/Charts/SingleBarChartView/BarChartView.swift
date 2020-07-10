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
    private let _yLableViewWidth: CGFloat = 40
    
    private var _minY: CGFloat = 0.0
    private var _maxY: CGFloat = 0.0
    private var _stepsY: Int = 0;
    private var _intervalY: CGFloat = 0.0
    private var _margine: CGFloat = 10
    
    var axisXLabel: String = ""
    
    var seriesData: [Double] = []
    var seriesNames: [String] = []
    
    @IBOutlet weak var chartView: BarChartView_ChartView!
    @IBOutlet weak var yLabelView: BarChartView_YLabelView!
    
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
    
    private func makeCommonVals() {
        guard _stepsY != 0 else { return }
        _intervalY = (chartView.bounds.height - 2 * _margine) / CGFloat(_stepsY)
    }
    private func loadNib() {
        if let success = NSNib(nibNamed: "BarChartView", bundle: nil)?.instantiate(withOwner: self, topLevelObjects: nil), success {
            
            chartView?.frame = CGRect(x: _yLableViewWidth, y: _xLableViewHeight,
                                      width: self.frame.width - _yLableViewWidth,
                                      height: self.frame.height - _xLableViewHeight)
            yLabelView.frame = CGRect(x: 0, y: _yLableViewWidth,
                                      width: _yLableViewWidth,
                                      height: self.bounds.height - _yLableViewWidth);
            self.addSubview(chartView!)
            self.addSubview(yLabelView);
        }
    }
    
    func setDataSource(from data: [Double]) {
        chartView.seriesData = data
        self.needsDisplay = true;
    }
    
    override func updateLayer() {
        makeCommonVals();
        chartView.margine = _margine;
        yLabelView.margine = _margine;
        yLabelView.yInterval = _intervalY
        
        chartView.needsDisplay = true
        yLabelView.needsDisplay = true
    }
    
    @objc func frameSizeDidChageNotification(notification: Notification) {
        self.needsDisplay = true
    }
}
