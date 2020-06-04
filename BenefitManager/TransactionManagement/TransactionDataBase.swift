//
//  TransactionDataBase.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/03.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

class TransactionDataBase {
    // Notifications for notifying the change of records
    enum NotificationName: String {
        case recordDidChange
    }
    static let recordDidChangeNotification = Notification.Name(NotificationName.recordDidChange.rawValue)
    
    private static var _instances: [String: TransactionDataBase] = [:]
    
    var transactions: [Transaction] = []
    var numberOfRecords: Int {
        get {
            return transactions.count
        }
    }
    
    static func recordDidChange(identifier DBName: String) {
        
    }
    
    /// Imports records from external file to specified DataBase.
    /// - Parameter DBName: the DataBase imported records
    /// - Throws: <#description#>
    static func importRecord(to DBName: String) throws {
        let fi = FileImporter()
        
        TransactionDataBase.deleteAllRecords(on: DBName)
        try fi.importData()
        
        for data in fi.analyzedData {
            TransactionDataBase.append(on: DBName, Transaction(importFrom: data))
        }
        sortRecord(in: DBName)
        TransactionDataBase.getInstance(identifier: DBName)!.processingData()
        
        // Post Notification
        recordDidChange(identifier: DBName)
        NotificationCenter.default.post(Notification(name: recordDidChangeNotification, object: nil))
    }
    private func saveRecords(in DBName: String) {
        do {
            let fe: FileExporter = FileExporter()
            try fe.export(from: TransactionDataBase.getInstance(identifier: DBName)!.transactions)
        } catch {
            
        }
    }
    /// Creates new DataBase that named identifier.
    /// - Parameter name: The name of new DataBase
    static func createNewDataBase (identifier name: String) {
        _instances[name] = .init()
    }
    static func append(on DBName: String, _ record: Transaction) {
        _instances[DBName]!.transactions.append(record)
    }
    static func insert(record content: Transaction, on DBName: String, at index: Int) {
        self._instances[DBName]!.transactions.insert(content, at: index)
        
        // Post Notification
        recordDidChange(identifier: DBName)
        NotificationCenter.default.post(Notification(name: recordDidChangeNotification, object: nil))
    }
    static func delete(on DBName: String, at index: Int) {
        self._instances[DBName]!.transactions.remove(at: index)
        
        // Post Notification
        recordDidChange(identifier: DBName)
        NotificationCenter.default.post(Notification(name: recordDidChangeNotification, object: nil))
    }
    /// Deletes all records on specified DataBase.
    /// If there is no DataBase that specified, error is occurred.
    /// - Parameter DBName: The name specifying DataBase
    static func deleteAllRecords(on DBName: String) {
        _instances[DBName]!.deleteAllRecord()
    }
    /// Returns the specified instance.
    /// If there is no specified instance, nil is returned.
    /// - Parameter DBName: The identifier of the DataBase
    /// - Returns: The instance of specified DataBase
    static func getInstance(identifier DBName: String) -> TransactionDataBase? {
        return _instances[DBName]
    }
    
    private static func margeSort(from data: inout [Transaction], leftIndex left: Int, rightIndex right: Int) {
        if data.isEmpty {
            return
        }
        
        if right - left == 0 {
            return
        }
        
        let mid = (left + right) / 2
        margeSort(from: &data, leftIndex: left, rightIndex: mid)
        margeSort(from: &data, leftIndex: mid + 1, rightIndex: right)
        
        var buf: [Transaction] = []
        for i in left...mid { buf.append(data[i]) }
        for i in (mid + 1...right).reversed() { buf.append(data[i]) }
        
        var itr_left = 0
        var itr_right = buf.count - 1
        for i in left...right {
            if buf[itr_left].date <= buf[itr_right].date {
                data[i] = buf[itr_left]
                itr_left += 1
            }
            else {
                data[i] = buf[itr_right]
                itr_right -= 1
            }
        }
    }
    
    static func sortRecord(in identifier: String) {
        let transactions = TransactionDataBase.getInstance(identifier: identifier)!.transactions
        margeSort(from: &TransactionDataBase.getInstance(identifier: identifier)!.transactions,
                  leftIndex: 0, rightIndex: transactions.count - 1)
    }
    
    func processingData() {
        
    }
    func deleteAllRecord() {
        self.transactions.removeAll()
    }
    
    func processing() {
        
    }
    private init() {  }
}
