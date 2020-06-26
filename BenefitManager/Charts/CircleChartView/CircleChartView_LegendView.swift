//
//  CircleChartView_LegendView.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/26.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

class CircleChartView_LegendView: NSView, CALayerDelegate {
    private var legendRegion = CGRect()
    
    private let legendLayer = CALayer()
    private var legendIconLayers: [CALayer] = []
    private var legendTextLayers: [CATextLayer] = []
    private var legendDetailLayers: [CALayer] = []
    
    private var _dataSource: [Double] = []
    private var _relativeSource: [Double] = []
    private var itemsNameSource: [String] = []
    private var colorSet: [NSColor] = [.init(red: 0.49, green: 0.81, blue: 0.42, alpha: 1),
                                       .init(red: 0.39, green: 0.65, blue: 0.34, alpha: 1),
                                       .init(red: 0.29, green: 0.49, blue: 0.34, alpha: 1),
                                       .init(red: 0.20, green: 0.32, blue: 0.17, alpha: 1),
                                       .init(red: 0.10, green: 0.16, blue: 0.08, alpha: 1)
    ]
    
    override var wantsUpdateLayer: Bool { get { return true } }
    var dataSource: [Double] {
        get { return _dataSource }
        set(source) {
            _dataSource = source
        }
    }
    var relativeDataSource: [Double] {
        get { return _relativeSource }
        set(source) {
            _relativeSource = source
        }
    }
    var nameSource: [String] {
        get { return itemsNameSource }
        set(source) {
            itemsNameSource = source
        }
    }
    
    private let xMargine: CGFloat = 5
    private let iconMargine: CGFloat = 20
    private let iconSize: CGFloat = 15
    private let nameHeight: CGFloat = 22
    private let nameMargine: CGFloat = 10
    private let nameMargineTop: CGFloat = 2
    private let detailMargine: CGFloat = 15
    private let detailMargineTop: CGFloat = 2
    private let detailHeight: CGFloat = 20
    private let itemMargine: CGFloat = 3
    private let nameFontSize: CGFloat = 18
    private let detailFontSize: CGFloat = 14
    private var itemHeight: CGFloat {
        get { return nameMargineTop + nameHeight + detailMargineTop + detailHeight }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layerContentsRedrawPolicy = .onSetNeedsDisplay
        
        makeRegion()
    }
    
    private func makeRegion() {
        // Set View Size
        self.frame = CGRect(x: self.frame.minX, y: frame.minY,
                            width: self.frame.width,
                            height: CGFloat(dataSource.count) * (itemHeight + itemMargine) + itemMargine)
        
        // Make Region
        legendRegion = CGRect(x: 0.0,
                              y: 0.0,
                              width: self.bounds.width,
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
        
        for value in self._relativeSource {
            // ignore the data if it is zero
            if value == 0 { continue }
            
            // Locations
            let itemOriginY = self.bounds.height - CGFloat(dataIterator + 1) * (itemHeight + itemMargine)
            
            // Legend Icon
            let iconLayer = CALayer()
            iconLayer.opacity = 1
            iconLayer.frame = CGRect(x: iconMargine,
                                     y: itemOriginY + 0.5 * (itemHeight - iconSize),
                                     width: iconSize,
                                     height: iconSize)
            // Legend Text
            let textLayer = CATextLayer()
            textLayer.foregroundColor = NSColor.textColor.cgColor
            textLayer.frame = CGRect(x: iconMargine + iconSize + nameMargine,
                                     y: itemOriginY + detailHeight + detailMargineTop,
                                     width: legendLayer.bounds.width - 50,
                                     height: nameHeight)
            textLayer.fontSize = nameFontSize
            
            // Legend Details
            let detailLayer = CATextLayer()
            detailLayer.foregroundColor = NSColor.controlTextColor.cgColor
            detailLayer.frame = CGRect(x: iconMargine + iconSize + detailMargine,
                                     y: itemOriginY,
                                     width: legendLayer.bounds.width - 50,
                                     height: detailHeight)
            detailLayer.fontSize = detailFontSize
            
            // Set Legend Title
            if itemsNameSource.count > dataIterator {
                textLayer.string = itemsNameSource[dataIterator]
            } else {
                textLayer.string = "items\(dataIterator + 1)"
            }
            // Set Detail Datas
            if _relativeSource.count > dataIterator {
                detailLayer.string = String(format: "%.1f", (_relativeSource[dataIterator] * 1000).rounded() * 0.1)
                    + " %  |  ¥\(_dataSource[dataIterator])"
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
    override func updateLayer() {
        makeRegion()

        setUpLegendLayer()
        setUpLegendItemLayers()
    }
}
