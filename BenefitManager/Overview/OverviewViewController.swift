//
//  OverviewViewController.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/02.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

class OverviewViewController: NSViewController {
    private var transactionAnalyzer: TransactionAnalyzer!
    
    @IBOutlet weak var expensesIndicater: NSTextField!
    @IBOutlet weak var rangeSelector: NSPopUpButtonCell!
    @IBOutlet weak var circleChartView: CircleChartView!
    @IBOutlet weak var circleChartViewArea: NSBox!
    
    private let extractionRange = [
        "this week",
        "this month",
        "this year"
    ]
    
    @IBAction func extractionRangeDidChange(_ sender: NSPopUpButtonCell) {
        setExtractionRange()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        
        initialize()
        initializeCircleChart()
                
        self.transactionAnalyzer = TransactionDataBase.analyzer(
            identifier: TransactionDataBaseConfigurator.dataBaseName
        )
        setExtractionRange()
    }
    func initialize() {
        rangeSelector.removeAllItems()
        rangeSelector.addItems(withTitles: extractionRange)
    }
    func initializeCircleChart() {
        let chartView = CircleChartView(frame: circleChartView.bounds)
        chartView.autoresizingMask = NSView.AutoresizingMask(
            arrayLiteral:
            .height,
            .width,
            .maxXMargin,
            .maxYMargin,
            .minXMargin,
            .minYMargin
        )
        circleChartView = chartView
        circleChartViewArea.addSubview(chartView)
        chartView.setTitle("test")
        chartView.setValues(source: [5.5, 2.3])
    }
    func setExtractionRange() {
        switch rangeSelector.titleOfSelectedItem ?? "" {
        case "this week":
            expensesIndicater.stringValue
                = "¥ " + String(transactionAnalyzer.week.totalAmounts(type: .Expense))
            circleChartView.setValues(source: transactionAnalyzer.week.amountsBreakdown(type: .Expense))
            circleChartView.setItemNames(source: transactionAnalyzer.week.headersBreakdown(type: .Expense))
        case "this month":
            expensesIndicater.stringValue
                = "¥ " + String(transactionAnalyzer.month.totalAmounts(type: .Expense))
            circleChartView.setValues(source: transactionAnalyzer.month.amountsBreakdown(type: .Expense))
            circleChartView.setItemNames(source: transactionAnalyzer.month.headersBreakdown(type: .Expense))
        default:
            break
        }
    }
}
