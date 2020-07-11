//
//  BarChartView_XLableView.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/07/09.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

class BarChartView_XLabelView: NSView {
    private let seriesLabelBaseLayer = CALayer()
    private var seriesLabelLayers: [CATextLayer] = [];
    
    private let fontSize: CGFloat = 14
    private let textColor: CGColor = NSColor.textColor.cgColor;
    private let labelWidth: CGFloat = 20
    
    private var seriesLabels: [String] = []
    
    var xInterval: CGFloat = 0.0;
    var margine: CGFloat = 0.0;
    var maxY: CGFloat = 0.0;
    var minY: CGFloat = 0.0;
    var xSteps: Int = 0;
    
    override var wantsUpdateLayer: Bool { return true }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        
        initiaizeDataLabelBaseView()
    }
    
    func initiaizeDataLabelBaseView() {
        seriesLabelBaseLayer.backgroundColor = .clear
        
        seriesLabelBaseLayer.autoresizingMask = .init(
            arrayLiteral:
            .layerMaxXMargin,
            .layerMaxYMargin,
            .layerMinXMargin,
            .layerMinYMargin,
            .layerHeightSizable,
            .layerWidthSizable
        )
        seriesLabelBaseLayer.actions = [
            "bounds": NSNull(),
            "frame": NSNull(),
            "contents": NSNull(),
            "position": NSNull(),
            "transform": NSNull()
        ]
    }
    
    func setSeriesLables(from seriesNameSource: [String]) {
        self.seriesLabels = seriesNameSource
        self.xSteps = seriesLabels.count - 1
        self.needsDisplay = true
    }
    func updateEachLayerSize() {
        seriesLabelBaseLayer.frame = CGRect(x: margine, y: 0,
                                          width: self.bounds.width,
                                          height: self.bounds.height)
    }
    func drawSeriesLabels() {
        guard xSteps != 0 else { return }
        //yInterval = (dataLabelBaseLayer.bounds.height - 2 * margine) / CGFloat(ySteps)
        
        // Clear Current dataLabels
        for layer in seriesLabelLayers {
            layer.removeFromSuperlayer()
        }
        seriesLabelLayers.removeAll();
        
        for i in 0...(xSteps) {
            let tempLayer = CATextLayer();
            
            tempLayer.backgroundColor = .clear
            
            tempLayer.alignmentMode = .left
            tempLayer.fontSize = fontSize
            tempLayer.foregroundColor = textColor
            tempLayer.frame = CGRect(x: CGFloat(i + 1) * xInterval, y: 0,
                                     width: labelWidth, height: seriesLabelBaseLayer.bounds.height);
            tempLayer.string = seriesLabels[i];
            
            seriesLabelLayers.append(tempLayer);
            seriesLabelBaseLayer.addSublayer(tempLayer);
        }
    }
    
    override func updateLayer() {
        seriesLabelBaseLayer.removeFromSuperlayer()
        
        updateEachLayerSize()
        drawSeriesLabels();
        
        self.layer?.addSublayer(seriesLabelBaseLayer)
    }
}

