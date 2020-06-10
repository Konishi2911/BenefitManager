//
//  JournalViewController.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/03.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

class JournalViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, ItemEditorViewDelegate {
    
    private let dataBaseName: String = TransactionDataBaseConfigurator.dataBaseName
    private var recordForEdit: RecordInformationWrapper?
    
    @IBOutlet weak var journalTableView: NSTableView!
    
    @IBAction func addButtonDidClick(_ sender: NSButton) {
        let itemEditorWC = ItemEditorWindowController(windowNibName: "ItemEditorWindow")
        itemEditorWC.caller = self
        
        recordForEdit = .init(newRecord: nil,
                              recordNumber: 0,
                              isNewRecord: true)
        
        itemEditorWC.newRecordFlag = true
        itemEditorWC.dataBaseName = dataBaseName
        itemEditorWC.recordNumber = -1
        NSApp.runModal(for: itemEditorWC.window!)
    }
    @IBAction func deleteButtonDidClick(_ sender: NSButton) {
        if journalTableView.selectedRow != -1 {
            deleteData(at: journalTableView.selectedRow)
            
            journalTableView.reloadData()
        }
    }
    @IBAction func itemDidDoubleClick(_ sender: NSTableView) {
        guard sender.selectedRow != -1 else {
            return
        }
        
        let itemEditorWC = ItemEditorWindowController(windowNibName: "ItemEditorWindow")
        itemEditorWC.caller = self
        
        let selectedRecord =
            TransactionDataBase.getInstance(identifier: dataBaseName)?.transactions[sender.selectedRow]
        recordForEdit = .init(newRecord: selectedRecord,
                              recordNumber: sender.selectedRow,
                              isNewRecord: false)
        
        itemEditorWC.newRecordFlag = false
        itemEditorWC.newRecord = selectedRecord
        itemEditorWC.dataBaseName = dataBaseName
        itemEditorWC.recordNumber = sender.selectedRow
        NSApp.runModal(for: itemEditorWC.window!)
    }
    
    func saveRecords() {
        TransactionDataBase.saveRecords(in: TransactionDataBaseConfigurator.dataBaseName)
    }
    func editData(at index: Int, newRecord: Transaction) {
        TransactionDataBase.delete(on: dataBaseName, at: index)
        TransactionDataBase.insert(record: newRecord, on: dataBaseName, at: index)
        
        TransactionDataBase.sortRecord(in: dataBaseName)
        journalTableView.reloadData()
        
        saveRecords()
    }
    func appendData(_ newRecord: Transaction) {
        TransactionDataBase.append(on: dataBaseName, newRecord)
        
        TransactionDataBase.sortRecord(in: dataBaseName)
        journalTableView.reloadData()

        saveRecords()
    }
    func deleteData(at index: Int) {
        TransactionDataBase.delete(on: dataBaseName, at: index)
        
        saveRecords()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func recordInformation() -> RecordInformationWrapper {
        return recordForEdit!
    }
    func editingDidFinish(recordInformation: RecordInformationWrapper) {
        if recordInformation.isNewRecord {
            self.appendData(recordInformation.newRecord!)
        } else {
            self.editData(at: recordInformation.recordNumber, newRecord: recordInformation.newRecord!)
        }
    }
    
    func numberOfRows (in tableView: NSTableView) -> Int {
        return TransactionDataBase.getInstance(identifier: dataBaseName)!.transactions.count
    }
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let transactions = TransactionDataBase.getInstance(identifier: dataBaseName)!.transactions
        
        if let tcol = tableColumn {
            switch tcol.identifier.rawValue{
            case "Date":
                let formatter: DateFormatter = DateFormatter()
                formatter.dateFormat = "yy/MM/dd"
                return formatter.string(from: transactions[row].date)
                
            case "AccountsTitle" :
                return transactions[row].accountsTitle.string()
                
            case "Name" :
                return transactions[row].name
                
            case "Pcs" :
                return transactions[row].pieces
                
            case "Subtotal" :
                return transactions[row].amounts * transactions[row].pieces
                
            case "Remarks" :
                return transactions[row].remarks
                
            default :
                return ""
            }
        }
        return ""
    }
}
