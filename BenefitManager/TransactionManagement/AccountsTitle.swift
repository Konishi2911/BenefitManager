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
                "Mail"
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
    
    private let title: String
    private let transactionType: TransactionType
    private let headerIndex: Int
    private let titleIndex: Int
    
    static var Empty: AccountsTitle {
        get {
            return .init(title: "", .Income, headerIndex: -1, titleIndex: -1)
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
        switch tType {
        case .Income:
            return _titles[0][headerIndex]
        case .Expense:
            return _titles[1][headerIndex]
        }
    }
    static func title(at titleIndex: Int, on headerIndex: Int, TransactionType tType: TransactionType) -> AccountsTitle {
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
        return self.title
    }
    
    private init (title t: String, _ tType: TransactionType, headerIndex hi: Int, titleIndex ti: Int) {
        self.title = t
        self.transactionType = tType
        self.headerIndex = hi
        self.titleIndex = ti
    }
    init (title t: AccountsTitle) {
        self.title = t.title
        self.transactionType = t.transactionType
        self.headerIndex = t.headerIndex
        self.titleIndex = t.titleIndex
    }
    init (title t: String) {
        var ii: Int = 0, jj: Int = 0, kk: Int = 0
        var isMatch: Bool = false
        for k in 0...1 {
            for i in 0...Self._header[k].count {
                for j in 0...Self._titles[k][i].count {
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
            self.title = t
            self.transactionType = TransactionType.index(kk)
            self.headerIndex = ii
            self.titleIndex = jj
        }
        else {
            self.title = ""
            self.headerIndex = 0
            self.titleIndex = 0
            self.transactionType = .Income
            fatalError("There is no such title")
        }
    }
}

/*
 private static let _titles = [
     "Income": [
         "Salary": [
             "Salaries"
         ],
         "Scholarship": [
             "Scholarship"
         ],
         "Miscellaneous Expenses": [
             "Miscellaneous Expenses"
         ]
     ],
     "Expense": [
         "Tuition": [
             "Tuition"
         ],
         "Business Expenses": [
             "Business Expenses"
         ],
         "Hobby Expenses": [
             "Hobby Expenses"
         ],
         "Socializing Expenses": [
             "Socializing Expenses"
         ],
         "Transport Costs": [
             "Transport Costs"
         ],
         "Issurance": [
             "Issurance"
         ],
         "Housing Expenses": [
             "Housing Expenses"
         ],
         "Food Expenses": [
             "Food Expenses"
         ],
         "Utility Costs": [
             "Gas Costs",
             "Electricity Costs",
             "Water Costs"
         ],
         "Telecommunications": [
             "Internet Costs",
             "Phone Costs",
             "Mail"
         ],
         "Taxes": [
             "Taxes"
         ],
         "Clothing Expenses": [
             "Clothing Expenses"
         ],
         "Medical Expenses": [
             "Medical Expenses"
         ]
     ]
 ]
 */
