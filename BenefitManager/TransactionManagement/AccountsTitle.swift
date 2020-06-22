//
//  AccountsTitle.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/03.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

/// This class represents the accounts title
struct AccountsTitle {
    private static let _header = [
        // Income
        [
            "Salary",
            "Other"
        ],
        // Espense
        [
            "Food",
            "Daily Uses",
            "Utilities",
            "Communications",
            "Entertainments",
            "Transports",
            "Clothings",
            "Medic",
            "Housing",
            "Insurances",
            "Taxes"
        ]
    ]
    private static let _titles = [
        [
            // Salary
            [
                "Salaries"
            ],
            // Other
            [
                "Scholarships",
                "Miscellaneous Incomes"
            ]
        ],
        [
            // Foods
            [
                "Foods"
            ],
            //Daily Uses
            [
                "Cleanings",
                "Detergents",
                "Miscellaneous"
            ],
            // Utilities
            [
                "Water",
                "Gas",
                "Electricity"
            ],
            // Communications
            [
                "Phone",
                "Internet",
                "Mail",
                "Stamp"
            ],
            // Entertainments
            [
                "Hobby",
                "Socializing"
            ],
            // Transpots
            [
                "Common",
                "Regular",
                "Fuel"
            ],
            // Clothings
            [
                "Clothing",
                "Cleaning"
            ],
            // Medic
            [
                "Medic",
                "Medication"
            ],
            // Housing
            [
                "Housing",
                "Repair"
            ],
            // Insurance
            [
                "Insurance"
            ],
            // Taxes
            [
                "Taxes"
            ]
        ]
    ]
    enum TransactionType {
        case Income
        case Expense
        
        static func index(_ index: Int) -> TransactionType {
            if index == 0 { return .Income }
            else { return .Expense }
        }
    }
    
    private let _title: String
    private let _transactionType: TransactionType
    private let _headerIndex: Int
    private let _titleIndex: Int
    
    var transactionType: TransactionType {
        get { return _transactionType }
    }
    var headerIndex: Int {
        get { return _headerIndex }
    }
    var headerString: String {
        get { return AccountsTitle.headersString(transactionType: _transactionType)[_headerIndex] }
    }
    var titleIndex: Int {
        get { return _titleIndex }
    }
    var titleString: String {
        get {
            guard AccountsTitle.titlesString(at: _headerIndex, transactionType: _transactionType).count >= 1 else {
                return ""
            }
            return AccountsTitle.titlesString(at: _headerIndex,
                                                transactionType: _transactionType)[_titleIndex]
        }
    }
    
    static var Empty: AccountsTitle {
        get {
            return .init(title: "empty", .Income, headerIndex: -1, titleIndex: -1)
        }
    }
    static func headersString(transactionType tType: TransactionType) -> [String] {
        switch tType {
        case .Income:
            return _header[0]
        case .Expense:
            return _header[1]
        }
    }
    static func titlesString(at headerIndex: Int, transactionType tType: TransactionType) -> [String] {
        guard headerIndex >= 0 else {
            return []
        }
        
        switch tType {
        case .Income:
            return _titles[0][headerIndex]
        case .Expense:
            return _titles[1][headerIndex]
        }
    }
    static func title(at titleIndex: Int, on headerIndex: Int, TransactionType tType: TransactionType) -> AccountsTitle {
        guard titleIndex >= 0 && headerIndex >= 0 else {
            return AccountsTitle.Empty
        }
        
        switch tType {
        case .Income:
            return AccountsTitle(title: _titles[0][headerIndex][titleIndex], .Income,
                                 headerIndex: headerIndex,
                                 titleIndex: titleIndex)
        case .Expense:
            return AccountsTitle(title: _titles[1][headerIndex][titleIndex], .Expense,
                                 headerIndex: headerIndex,
                                 titleIndex: titleIndex)
        }
    }
    func string() ->String {
        return self._title
    }
    
    private init (title t: String, _ tType: TransactionType, headerIndex hi: Int, titleIndex ti: Int) {
        self._title = t
        self._transactionType = tType
        self._headerIndex = hi
        self._titleIndex = ti
    }
    init (title t: AccountsTitle) {
        self._title = t._title
        self._transactionType = t._transactionType
        self._headerIndex = t._headerIndex
        self._titleIndex = t._titleIndex
    }
    /// Initializes with title name as string.
    /// If there is no specified title, AccountsTitle will be Empty
    /// - Parameter t: specifiying title as string
    init (title t: String) {
        var ii: Int = 0, jj: Int = 0, kk: Int = 0
        var isMatch: Bool = false
        for k in 0...1 {
            for i in 0..<Self._header[k].count {
                for j in 0..<Self._titles[k][i].count {
                    if t == Self._titles[k][i][j] {
                        ii = i
                        jj = j
                        kk = k
                        isMatch = true
                        break
                    }
                }
                if isMatch {break}
            }
            if isMatch {break}
        }
        if (isMatch) {
            self._title = t
            self._transactionType = TransactionType.index(kk)
            self._headerIndex = ii
            self._titleIndex = jj
        }
        else {
            self._title = "empty"
            self._headerIndex = -1
            self._titleIndex = -1
            self._transactionType = .Income
        }
    }
}
