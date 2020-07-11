//
//  BarChartView_ChartView.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/07/09.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

class BarChartView_ChartView: NSView {
    private let axisLayer = CAShapeLayer();
    private let chartLayer = CAShapeLayer();
    private let shadowLayer = CAShapeLayer();
    
    // Axis Line
    var tickLength: CGFloat = 10;
    var minY: CGFloat = 0.0;
    var maxY: CGFloat = 0.0;
    var axisSteps: Int = 1;
    var yInterval: CGFloat = 0.0;
    var margine: CGFloat = 20;

    private var axisLineWidth: CGFloat = 1;
    
    // Chart
    private let chartWidth: CGFloat = 5
    private let chartColor: CGColor = NSColor.yellow.cgColor;
    
    var seriesData: [Double] = []
    var seriesNames: [String] = []
    
    override var wantsUpdateLayer: Bool { return true }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        
        initializeAxis();
        initializeChart();
        initializeShadow();
    }
    
    private func initializeAxis() {
        axisLayer.strokeColor = NSColor.systemGray.cgColor;
        axisLayer.lineWidth = axisLineWidth;
        
        axisLayer.autoresizingMask = .init(
            arrayLiteral:
            .layerMaxXMargin,
            .layerMaxYMargin,
            .layerMinXMargin,
            .layerMinYMargin,
            .layerHeightSizable,
            .layerWidthSizable
        )
        axisLayer.actions = [
            "bounds": NSNull(),
            "frame": NSNull(),
            "contents": NSNull(),
            "position": NSNull(),
            "transform": NSNull(),
            "lineWidth": NSNull()
        ]
    }
    private func initializeChart() {        
        chartLayer.lineWidth = chartWidth;
        chartLayer.strokeColor = chartColor;
        chartLayer.lineCap = .round;
        
        chartLayer.autoresizingMask = .init(
            arrayLiteral:
            .layerMaxXMargin,
            .layerMaxYMargin,
            .layerMinXMargin,
            .layerMinYMargin,
            .layerHeightSizable,
            .layerWidthSizable
        )
        chartLayer.actions = [
            "bounds": NSNull(),
            "frame": NSNull(),
            "contents": NSNull(),
            "position": NSNull(),
            "transform": NSNull(),
            "lineWidth": NSNull()
        ]
    }
    private func initializeShadow() {
        shadowLayer.lineWidth = chartWidth;
        shadowLayer.strokeColor = .black;
        shadowLayer.lineCap = .round;
        
        shadowLayer.fillRule = .evenOdd
        shadowLayer.opacity = 0.8
        
        shadowLayer.shouldRasterize = true
        shadowLayer.shadowColor = .black
        shadowLayer.shadowRadius = 1
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowOffset = CGSize(width: 0, height: 0)
        
        shadowLayer.autoresizingMask = .init(
            arrayLiteral:
            .layerMaxXMargin,
            .layerMaxYMargin,
            .layerMinXMargin,
            .layerMinYMargin,
            .layerHeightSizable,
            .layerWidthSizable
        )
        shadowLayer.actions = [
            "bounds": NSNull(),
            "frame": NSNull(),
            "contents": NSNull(),
            "position": NSNull(),
            "transform": NSNull(),
            "lineWidth": NSNull()
        ]
    }
    
    private func updateEachLayerSize() {
        axisLayer.frame = self.bounds;
        chartLayer.frame = CGRect(x: margine, y: margine,
                                  width: self.bounds.width - 2 * margine,
                                  height: self.bounds.height - 2 * margine);
        shadowLayer.frame = self.bounds;
    }

    private func drawAxis() {
        // Remove Current AxisLAyer
        axisLayer.removeFromSuperlayer();
                
        let xLength = chartLayer.bounds.width;
        let yLength = chartLayer.bounds.height;
        yInterval = chartLayer.bounds.height / CGFloat(axisSteps);
        
        let axisLine = CGMutablePath();
        // draw x
        axisLine.move(to: CGPoint(x: margine, y: margine));
        axisLine.addLine(to: CGPoint(x: xLength + margine, y: margine));
        
        // draw y
        axisLine.move(to: CGPoint(x: margine, y: margine));
        axisLine.addLine(to: CGPoint(x: margine, y: margine + yLength));
        
        for i in 0...(axisSteps) {
            axisLine.move(to: CGPoint(x: margine,
                                      y: margine + CGFloat(i) * yInterval));
            axisLine.addLine(to: CGPoint(x: margine + tickLength,
                                         y: margine + CGFloat(i) * yInterval));
        }
        
        axisLayer.path = axisLine
    }
    
    func drawChart() {
        guard seriesData.count != 0 else { return }
        
        let xInterval: CGFloat = chartLayer.bounds.width / CGFloat(seriesData.count + 1);
        
        let chartBar = CGMutablePath();
        var i = 1;
        for data in seriesData {
            if data == 0 {
                i += 1
                continue
            }
            
            chartBar.move(to: CGPoint(x: xInterval * CGFloat(i),
                                      y: chartWidth / 2));
            chartBar.addLine(
                to: CGPoint(x: xInterval * CGFloat(i),
                            y: chartLayer.bounds.height * (CGFloat(data) - minY) / (maxY - minY)
            ));
            i += 1;
        }
        
        chartLayer.path = chartBar;
    }
    
    func drawShadow() {
        guard seriesData.count != 0 else { return }
        
        let xInterval: CGFloat = chartLayer.bounds.width / CGFloat(seriesData.count + 1);
        
        let shadowBar = CGMutablePath();
        var i = 1;
        for data in seriesData {
            if data == 0 {
                i += 1
                continue
            }
            
            shadowBar.move(to: CGPoint(x: margine + xInterval * CGFloat(i),
                                      y: margine + chartWidth / 2));
            shadowBar.addLine(
                to: CGPoint(x: margine + xInterval * CGFloat(i),
                            y: margine + chartLayer.bounds.height * (CGFloat(data) - minY) / (maxY - minY)
            ));
            i += 1;
        }
        
        shadowLayer.path = shadowBar;
    }
    
    override func updateLayer() {
        axisLayer.removeFromSuperlayer();
        shadowLayer.removeFromSuperlayer();
        chartLayer.removeFromSuperlayer();
        
        updateEachLayerSize();
        drawAxis();
        drawShadow();
        drawChart();
        
        self.layer?.addSublayer(axisLayer);
        self.layer?.addSublayer(shadowLayer);
        self.layer?.addSublayer(chartLayer);
    }
}
