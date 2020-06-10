//
//  TransactionAnalyzer.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/06.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

struct TransactionAnalyzer {
    private let _transactionDB: TransactionDataBase
    
    init(_ transactionDataBase: TransactionDataBase) {
        self._transactionDB = transactionDataBase
    }
    
    /// Returns total income for the past week from today.
    /// - Returns: Total income amounts
    func weeklyIncome() -> Int {
        return weeklyIncome(until: Calendar.current.startOfDay(for: Date()))
    }
    /// Returns total income for the past week from specified date
    /// - Parameter date: Start of the day that specify the week to extract transactions
    /// - Returns: Total income amounts
    func weeklyIncome(until date: Date) -> Int {
        var incomes: Int = 0
        for transaction in weeklyTransactions(from: date) {
            if transaction.accountsTitle.transactionType == .Income {
                incomes += transaction.amounts * transaction.pieces
            }
        }
        return incomes
    }
    /// Returns total expense for the past week from today.
    /// - Returns: Total income amounts
    func weeklyExpense() ->Int {
        return weeklyExpense(until: Calendar.current.startOfDay(for: Date()))
    }
    /// Returns total expense for the past week from specified date
    /// - Parameter date: start of the day that specify the week to extract transactions
    /// - Returns: Total income amounts
    func weeklyExpense(until date: Date) -> Int {
        var expenses: Int = 0
        for transaction in weeklyTransactions(from: date) {
            if transaction.accountsTitle.transactionType == .Expense {
                expenses += transaction.amounts * transaction.pieces
            }
        }
        return expenses
    }
    /// Returns the names of weekly breakdown of transactions in this week
    /// - Returns: the name of weekly breakdown of transactions
    func weeklyHeaderBreakdown() -> [String] {
        return weeklyHeaderBreakdown(dateOfWeek: Calendar.current.startOfDay(for: Date()))
    }
    /// Returns the names of weekly breakdown of transactions in specified week
    /// - Parameter date: reference date to decide the week
    /// - Returns: the name of weekly breakdown of transactions
    func weeklyHeaderBreakdown(dateOfWeek date: Date) -> [String] {
        let _ = Calendar.current.component(.weekday, from: date) - 1
        
        var isFirst = true
        var transactionHeaderNames: [String] = []
        for transaction in weeklyTransactions(from: date) {
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
    /// Returns the amounts of weekly breakdown of transactions in this week
    /// - Returns: the amounts of weekly breakdown of transactions
    func weeklyAmountsBreakdown() -> [Int] {
        return weeklyAmountsBreakdown(dateOfWeek: Calendar.current.startOfDay(for: Date()))
    }
    /// Returns the amounts of each header of weekly breakdown of transactions in specified week
    /// - Parameter date: the start of reference date to decide the week
    /// - Returns: the amounts of weekly breakdown of transactions
    func weeklyAmountsBreakdown(dateOfWeek date: Date) -> [Int] {
        _ = Calendar.current.component(.weekday, from: date) - 1
        let weeklyHeader = weeklyHeaderBreakdown(dateOfWeek: date)
        
        var i = 0
        var transactionAmounts: [Int] = Array(repeating: 0, count: weeklyHeader.count)
        for header in weeklyHeader {
            for transaction in weeklyTransactions(from: date) {
                if transaction.accountsTitle.headerString != header { continue }
                transactionAmounts[i] += transaction.amounts
            }
            i += 1
        }
        return transactionAmounts
    }
    func monthlyExpense() -> Int {
        return monthlyExpense(date: Calendar.current.startOfDay(for: Date()))
    }
    func monthlyExpense(date: Date) -> Int {
        var expenses: Int = 0
        for transaction in monthlyTransactions(from: date) {
            if transaction.accountsTitle.transactionType == .Expense {
                expenses += transaction.amounts * transaction.pieces
            }
        }
        return expenses
    }
    /// Returns the names of weekly breakdown of transactions in this week
    /// - Returns: the name of weekly breakdown of transactions
    func monthlyHeaderBreakdown() -> [String] {
        return monthlyHeaderBreakdown(dateOfWeek: Calendar.current.startOfDay(for: Date()))
    }
    /// Returns the names of weekly breakdown of transactions in specified week
    /// - Parameter date: reference date to decide the week
    /// - Returns: the name of weekly breakdown of transactions
    func monthlyHeaderBreakdown(dateOfWeek date: Date) -> [String] {
        let _ = Calendar.current.component(.weekday, from: date) - 1
        
        var isFirst = true
        var transactionHeaderNames: [String] = []
        for transaction in monthlyTransactions(from: date) {
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
    /// Returns the amounts of weekly breakdown of transactions in this week
    /// - Returns: the amounts of weekly breakdown of transactions
    func monthlyAmountsBreakdown() -> [Int] {
        return monthlyAmountsBreakdown(dateOfWeek: Calendar.current.startOfDay(for: Date()))
    }
    /// Returns the amounts of each header of weekly breakdown of transactions in specified week
    /// - Parameter date: the start of reference date to decide the week
    /// - Returns: the amounts of weekly breakdown of transactions
    func monthlyAmountsBreakdown(dateOfWeek date: Date) -> [Int] {
        _ = Calendar.current.component(.weekday, from: date) - 1
        let weeklyHeader = monthlyHeaderBreakdown(dateOfWeek: date)
        
        var i = 0
        var transactionAmounts: [Int] = Array(repeating: 0, count: weeklyHeader.count)
        for header in weeklyHeader {
            for transaction in monthlyTransactions(from: date) {
                if transaction.accountsTitle.headerString != header { continue }
                transactionAmounts[i] += transaction.amounts
            }
            i += 1
        }
        return transactionAmounts
    }
    /// Extractr transactions in the week of specified day.
    /// - Parameter date: the start of specifiying day
    /// - Returns: extracted transactions
    func weeklyTransactions(from date: Date) -> [Transaction] {
        let day = Calendar.current.component(.weekday, from: date) - 1
        let startDate: Date = Calendar.current.date(byAdding: .day, value: -day, to: date)!
        let endDate: Date = Calendar.current.date(byAdding: .day, value: 6 - day, to: date)!
        
        return extractTransaction(from: startDate, to: endDate)
    }
    func monthlyTransactions(from date: Date) -> [Transaction] {
        let day = Calendar.current.component(.day, from: date)
        let lastday = Calendar.current.range(of: .day, in: .month, for: date)!.upperBound
        let startDate: Date = Calendar.current.date(byAdding: .day, value: -day, to: date)!
        let endDate: Date = Calendar.current.date(byAdding: .day, value: lastday - day, to: date)!

        
        return extractTransaction(from: startDate, to: endDate)
    }
    func extractTransaction(from startDate: Date, to endDate: Date) -> [Transaction] {
        var Transactions: [Transaction] = []
        for transaction in _transactionDB.transactions {
            print("\(startDate) >> \(transaction.date) >> \(endDate)")
            if transaction.date >= startDate && transaction.date <= endDate {
                Transactions.append(transaction)
            }
        }
        return Transactions
    }
}
