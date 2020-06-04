//
//  ItemEditorViewController.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/03.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

class ItemEditorViewController: NSViewController {
    @IBOutlet weak var windowController: ItemEditorWindowController!
    @IBOutlet weak var headerLabel: NSTextField!
    @IBOutlet weak var transactionTypeSelector: NSSegmentedControl!
    @IBOutlet weak var datePicker: NSDatePicker!
    @IBOutlet weak var accountsHeaderList: NSPopUpButton!
    @IBOutlet weak var accountsTitleList: NSPopUpButton!
    @IBOutlet weak var paymentMethodsList: NSPopUpButton!
    
    @IBAction func transactionTypeDidChange(_ sender: NSSegmentedControl) {
        setHeaderList()
        setTitleList()
    }
    @IBAction func accountsHeaderDidChanged(_ sender: NSPopUpButton) {
        setTitleList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInitialValue()
        if windowController.newRecordFlag {
            headerLabel.stringValue = "New Item"
            
        }
        else {
            headerLabel.stringValue = "Edit Item"
        }
    }
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        NSApp.stopModal()
    }
    func setInitialValue() {
        datePicker.dateValue = Date()
        setHeaderList()
        setTitleList()
        setPaymentMethods()
    }
    func setHeaderList() {
        accountsHeaderList.removeAllItems()

        switch transactionTypeSelector.selectedSegment {
        case 0:
            accountsHeaderList.addItems(withTitles:
                AccountsTitle.headersString(transactionType: .Income)
            )
        case 1:
            accountsHeaderList.addItems(withTitles:
                AccountsTitle.headersString(transactionType: .Expense)
            )
        default:
            break
        }
    }
    func setTitleList() {
        accountsTitleList.removeAllItems()

        let headerIndex = accountsHeaderList.indexOfSelectedItem
        switch transactionTypeSelector.selectedSegment {
        case 0:
            accountsTitleList.addItems(withTitles:
                AccountsTitle.titlesString(at: headerIndex, transactionType: .Income)
            )
        case 1:
            accountsTitleList.addItems(withTitles:
                AccountsTitle.titlesString(at: headerIndex, transactionType: .Expense)
            )
        default:
            break
        }
    }
    func setPaymentMethods() {
        paymentMethodsList.removeAllItems()
        
        paymentMethodsList.addItems(withTitles: PaymentMethod.allRawCases())
    }
}
