//
//  JournalViewController.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/03.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

class JournalViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    private let dataBaseName: String = AppDelegate.dataBaseName
    
    @IBOutlet weak var journalTableView: NSTableView!
    
    @IBAction func addButtonDidClick(_ sender: NSButton) {
        let itemEditorWC = ItemEditorWindowController(windowNibName: "ItemEditorWindow")
        itemEditorWC.dataBaseName = dataBaseName
        itemEditorWC.recordNumber = -1
        NSApp.runModal(for: itemEditorWC.window!)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
                return transactions[row].accountsTitle
                
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
