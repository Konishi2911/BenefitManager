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
    
    let week: WeeklyTransactionAnalyzer
    let month: MonthlyTransactionAnalyzer
    
    init(_ transactionDataBase: TransactionDataBase) {
        self._transactionDB = transactionDataBase
        
        week = WeeklyTransactionAnalyzer(dataBase: _transactionDB)
        month = MonthlyTransactionAnalyzer(dataBase: _transactionDB)
    }
}
