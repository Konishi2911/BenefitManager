//
//  ItemEditorViewController.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/03.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

class ItemEditorViewController: NSViewController {
    var delegate: ItemEditorViewDelegate?
    var recordInformation: RecordInformationWrapper!
    
    @IBOutlet weak var windowController: ItemEditorWindowController!
    @IBOutlet weak var headerLabel: NSTextField!
    @IBOutlet weak var transactionTypeSelector: NSSegmentedControl!
    @IBOutlet weak var datePicker: NSDatePicker!
    @IBOutlet weak var accountsHeaderList: NSPopUpButton!
    @IBOutlet weak var accountsTitleList: NSPopUpButton!
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var piecesField: NSTextField!
    @IBOutlet weak var amountsField: NSTextField!
    @IBOutlet weak var paymentMethodsList: NSPopUpButton!
    @IBOutlet weak var remarksField: NSTextField!
    @IBOutlet weak var confirmButton: NSButton!
    
    @IBAction func transactionTypeDidChange(_ sender: NSSegmentedControl) {
        setHeaderList()
        setTitleList()
    }
    @IBAction func accountsHeaderDidChanged(_ sender: NSPopUpButton) {
        setTitleList()
    }
    @IBAction func confirmButtonDidClick(_ sender: Any) {
        let newRecord = Transaction(
            title: AccountsTitle(title: accountsTitleList.selectedItem?.title ?? ""),
            date: datePicker.dateValue,
            name: nameField.stringValue,

            pieces: Int(piecesField.stringValue)!,
            amounts: Int(amountsField.stringValue)!,
            paymentMethod: PaymentMethod.init(rawValue: paymentMethodsList.selectedItem!.title)!,
            remarks: remarksField.stringValue
        )
        guard self.delegate != nil else {
            closeDialog()
            return
        }
        self.delegate!.editingDidFinish(
            recordInformation: .init(newRecord: newRecord,
                                     recordNumber: recordInformation.recordNumber,
                                     isNewRecord: recordInformation.isNewRecord)
        )
        
        self.closeDialog()
    }
    @IBAction func cancelButtonDidClick(_ sender: NSButton) {
        self.closeDialog()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialValue()
        
        delegate = windowController.caller
        receiveRecordInformation()
        
        if recordInformation.isNewRecord {
            headerLabel.stringValue = "New Item"
            confirmButton.title = "Add"
        }
        else {
            headerLabel.stringValue = "Edit Item"
            confirmButton.title = "Update"
            
            guard recordInformation.newRecord != nil else {
                return
            }
            let selectedRecord = recordInformation.newRecord!
            
            switch selectedRecord.accountsTitle.transactionType {
            case .Income:
                transactionTypeSelector.selectedSegment = 0
            case .Expense:
                transactionTypeSelector.selectedSegment = 1
            }
            datePicker.dateValue = selectedRecord.date
            accountsHeaderList.selectItem(at: selectedRecord.accountsTitle.headerIndex)
            accountsTitleList.selectItem(at: selectedRecord.accountsTitle.titleIndex)
            nameField.stringValue = selectedRecord.name
            piecesField.stringValue = String(selectedRecord.pieces)
            amountsField.stringValue = String(selectedRecord.amounts)
            paymentMethodsList.selectItem(withTitle: selectedRecord.paymentMethod.rawValue)
            remarksField.stringValue = selectedRecord.remarks
            
        }
    }
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        NSApp.stopModal()
    }
    func receiveRecordInformation() {
        recordInformation = .init(newRecord: windowController.newRecord,
                                  recordNumber: windowController.recordNumber,
                                  isNewRecord: windowController.newRecordFlag
        )
    }
    func setInitialValue() {
        datePicker.dateValue = Date()
        datePicker.timeZone = TimeZone.current
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
    func closeDialog() {
        windowController.close()
    }
}
