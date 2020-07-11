//
//  WeeklyTransactionAnalyzer.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/10.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

struct WeeklyTransactionAnalyzer: PeriodicTransactionAnalyzer {
    internal var _transactionDB: TransactionDataBase
    
    init(dataBase transactionDB: TransactionDataBase) {
        _transactionDB = transactionDB
    }
    
    func totalAmounts(type tType: AccountsTitle.TransactionType) -> Int {
        return totalAmounts(of: Calendar.current.startOfDay(for: Date()), type: tType)
    }
    func totalAmounts(of refDate: Date, type tType: AccountsTitle.TransactionType) -> Int {
        let day = Calendar.current.component(.weekday, from: refDate) - 1
        let startDate: Date = Calendar.current.date(byAdding: .day, value: -day, to: refDate)!
        let endDate: Date = Calendar.current.date(byAdding: .day, value: 6 - day, to: refDate)!
        
        return totalAmounts(from: startDate, to: endDate, type: tType)
    }
    
    func headersBreakdown(type tType: AccountsTitle.TransactionType) -> [String] {
        headersBreakdown(of: Calendar.current.startOfDay(for: Date()), type: tType)
    }
    func headersBreakdown(of refDate: Date, type tType: AccountsTitle.TransactionType) -> [String] {
        let day = Calendar.current.component(.weekday, from: refDate) - 1
        let startDate: Date = Calendar.current.date(byAdding: .day, value: -day, to: refDate)!
        let endDate: Date = Calendar.current.date(byAdding: .day, value: 6 - day, to: refDate)!
        
        return headersBreakdown(from: startDate, to: endDate, type: tType)
    }
    
    func amountsBreakdown(type tType: AccountsTitle.TransactionType) -> [Int] {
        amountsBreakdown(of: Calendar.current.startOfDay(for: Date()), type: tType)
    }
    func amountsBreakdown(of refDate: Date, type tType: AccountsTitle.TransactionType) -> [Int] {
        let day = Calendar.current.component(.weekday, from: refDate) - 1
        let startDate: Date = Calendar.current.date(byAdding: .day, value: -day, to: refDate)!
        let endDate: Date = Calendar.current.date(byAdding: .day, value: 6 - day, to: refDate)!
        
        return amountsBreakdown(from: startDate, to: endDate, type: tType)
    }
    
    func getDayList() -> [String] {
        return getDayList(of: Calendar.current.startOfDay(for: Date()))
    }
    func getDayList(of refDate: Date) -> [String] {
        let day = Calendar.current.component(.weekday, from: refDate) - 1
        let startDate: Date = Calendar.current.date(byAdding: .day, value: -day, to: refDate)!
        let endDate: Date = Calendar.current.date(byAdding: .day, value: 6 - day, to: refDate)!
        
        return getDayList(from: startDate, to: endDate)
    }
    func amountsBreakdownByDay(type tType: AccountsTitle.TransactionType) -> [Int] {
        amountsBreakdownByDay(of: Calendar.current.startOfDay(for: Date()), type: tType)
    }
    func amountsBreakdownByDay(of refDate: Date, type tType: AccountsTitle.TransactionType) -> [Int] {
        let day = Calendar.current.component(.weekday, from: refDate) - 1
        let startDate: Date = Calendar.current.date(byAdding: .day, value: -day, to: refDate)!
        let endDate: Date = Calendar.current.date(byAdding: .day, value: 6 - day, to: refDate)!
        
        return amountsBreakdownByDay(from: startDate, to: endDate, type: tType);
    }
}
