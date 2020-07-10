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
    
    private static var selectedRangeSelector: Int = 0
    private var numFormatter = NumberFormatter()
    
    @IBOutlet weak var expensesIndicater: NSTextField!
    @IBOutlet weak var rangeSelector: NSPopUpButtonCell!
    @IBOutlet weak var circleChartView: CircleChartView!
    @IBOutlet weak var circleChartViewArea: NSBox!
    @IBOutlet weak var barChartView: BarChartView!
    
    
    private let extractionRange = [
        "this week",
        "this month",
        "this year"
    ]
    
    @IBAction func extractionRangeDidChange(_ sender: NSPopUpButtonCell) {
        Self.selectedRangeSelector = sender.indexOfSelectedItem
        setExtractionRange()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        
        initialize()
        initializeCircleChart()
        initializeBarChart()
                
        self.transactionAnalyzer = TransactionDataBase.analyzer(
            identifier: TransactionDataBaseConfigurator.dataBaseName
        )
        setExtractionRange()
    }
    func initialize() {
        rangeSelector.removeAllItems()
        rangeSelector.addItems(withTitles: extractionRange)
        rangeSelector.selectItem(at: Self.selectedRangeSelector)
    }
    func initializeCircleChart() {
        circleChartView.setTitle("test")
        circleChartView.setValues(source: [5.5, 2.3])
    }
    func initializeBarChart() {
        barChartView.minY = 0;
        barChartView.maxY = 10;
        barChartView.stepsY = 4;
        barChartView.setDataSource(from: [5.5, 2.3, 8.2, 3, 2.1, 9.4, 9.0, 2.1])
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
