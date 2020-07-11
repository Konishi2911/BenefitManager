//
//  BarChartView_YLabelView.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/07/09.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

class BarChartView_YLabelView: NSView {
    private let dataLabelBaseLayer = CALayer()
    private var dataLabelLayers: [CATextLayer] = [];
    
    private let fontSize: CGFloat = 14
    private let textColor: CGColor = NSColor.textColor.cgColor;
    private let labelHeight: CGFloat = 20
    
    var yInterval: CGFloat = 0.0;
    var margine: CGFloat = 0.0;
    var maxY: CGFloat = 0.0;
    var minY: CGFloat = 0.0;
    var ySteps: Int = 0;
    
    override var wantsUpdateLayer: Bool { return true }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        
        initiaizeDataLabelBaseView()
    }
    
    func initiaizeDataLabelBaseView() {
        dataLabelBaseLayer.autoresizingMask = .init(
            arrayLiteral:
            .layerMaxXMargin,
            .layerMaxYMargin,
            .layerMinXMargin,
            .layerMinYMargin,
            .layerHeightSizable,
            .layerWidthSizable
        )
        dataLabelBaseLayer.actions = [
            "bounds": NSNull(),
            "frame": NSNull(),
            "contents": NSNull(),
            "position": NSNull(),
            "transform": NSNull()
        ]
    }
    
    func updateEachLayerSize() {
        dataLabelBaseLayer.frame = CGRect(x: 0, y: margine,
                                          width: self.bounds.width,
                                          height: self.bounds.height)
    }
    func drawDataLabels() {
        guard ySteps != 0 else { return }
        //yInterval = (dataLabelBaseLayer.bounds.height - 2 * margine) / CGFloat(ySteps)
        
        // Clear Current dataLabels
        for layer in dataLabelLayers {
            layer.removeFromSuperlayer()
        }
        dataLabelLayers.removeAll();
        
        for i in 0...(ySteps) {
            let tempLayer = CATextLayer();
            
            tempLayer.backgroundColor = .clear
            
            tempLayer.alignmentMode = .right
            tempLayer.fontSize = fontSize
            tempLayer.foregroundColor = textColor
            tempLayer.frame = CGRect(x: 0, y: CGFloat(i) * yInterval - 0.5 * labelHeight,
                                     width: dataLabelBaseLayer.bounds.width, height: labelHeight);
            tempLayer.string = String(format: "%.1f", Double(
                minY + (maxY - minY) * CGFloat(i) / CGFloat(ySteps)
            ));
            dataLabelLayers.append(tempLayer);
            dataLabelBaseLayer.addSublayer(tempLayer);
        }
    }
    
    override func updateLayer() {
        dataLabelBaseLayer.removeFromSuperlayer()
        
        updateEachLayerSize()
        drawDataLabels();
        
        self.layer?.addSublayer(dataLabelBaseLayer)
    }
}
