//
//  PeriodicTransactionAnalyzer.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/10.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

protocol PeriodicTransactionAnalyzer {
    /// the TransactionDataBase object for reference
    var _transactionDB: TransactionDataBase { get set }
    
    init(dataBase transactionDB: TransactionDataBase)
    
    func totalAmounts(type tType: AccountsTitle.TransactionType) -> Int
    /// Returns the latest headers breakdown during the ranges of each implementation.
    func headersBreakdown(type tType: AccountsTitle.TransactionType) -> [String]
    /// Returns the latest amouts breakdown during the ranges of each implementation.
    func amountsBreakdown(type tType: AccountsTitle.TransactionType) -> [Int]
}
extension PeriodicTransactionAnalyzer {
    func totalAmounts(from startDate: Date, to endDate: Date, type tType: AccountsTitle.TransactionType) -> Int {
        var amounts: Int = 0
        for transaction in extractTransactions(from: startDate, to: endDate, type: tType) {
            if transaction.accountsTitle.transactionType == tType {
                amounts += transaction.amounts * transaction.pieces
            }
        }
        return amounts
    }
    func headersBreakdown(from startDate: Date, to endDate: Date, type tType: AccountsTitle.TransactionType) -> [String] {
        var isFirst = true
        var transactionHeaderNames: [String] = []
        for transaction in extractTransactions(from: startDate, to: endDate, type: tType) {
            if transaction.accountsTitle.transactionType != .Expense { continue }
            
            // Add header to HeaderNames if current transaction header is not existed
            var i = 0
            if isFirst {
                transactionHeaderNames.append(transaction.accountsTitle.headerString)
                isFirst = false
                continue
            }
            for header in transactionHeaderNames {
                if transaction.accountsTitle.headerString == header { break }
                if transactionHeaderNames.count == i + 1 {
                    transactionHeaderNames.append(transaction.accountsTitle.headerString)
                    break
                }
                i += 1
            }
        }
        return transactionHeaderNames
    }
    func amountsBreakdown(from startDate: Date, to endDate: Date, type tType: AccountsTitle.TransactionType) -> [Int] {
        let headers = headersBreakdown(from: startDate, to: endDate, type: tType)
        
        var i = 0
        var transactionAmounts: [Int] = Array(repeating: 0, count: headers.count)
        for header in headers {
            for transaction in extractTransactions(from: startDate, to: endDate, type: tType) {
                if transaction.accountsTitle.headerString != header { continue }
                transactionAmounts[i] += transaction.amounts * transaction.pieces
            }
            i += 1
        }
        return transactionAmounts
    }
    func extractTransactions(from startDate: Date, to endDate: Date, type tType: AccountsTitle.TransactionType) -> [Transaction] {
        var Transactions: [Transaction] = []
        for transaction in _transactionDB.transactions {
            guard transaction.accountsTitle.transactionType == tType else { continue }
            print("\(startDate) >> \(transaction.date) >> \(endDate)")
            if transaction.date >= startDate && transaction.date <= endDate {
                Transactions.append(transaction)
            }
        }
        return Transactions
    }
}

