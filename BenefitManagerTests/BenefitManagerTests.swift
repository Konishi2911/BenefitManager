//
//  BenefitManagerTests.swift
//  BenefitManagerTests
//
//  Created by Kohei Konishi on 2020/06/02.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import XCTest
@testable import BenefitManager

class BenefitManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testTransactionAnalyzer() {
        let dataBaseName = "DBMock"
        TransactionDataBase.createNewDataBase(identifier: dataBaseName)
        let database = TransactionDataBase.getInstance(identifier: dataBaseName)!
        
        database.transactions = [
            Transaction.init(title: AccountsTitle.init(title: "Foods"),
                            date: Date(),
                            name: "TestMock1",
                            pieces: 1,
                            amounts: 400,
                            paymentMethod: PaymentMethod.cash,
                            remarks: ""),
            Transaction.init(title: AccountsTitle.init(title: "Foods"),
                            date: Date(),
                            name: "TestMock2",
                            pieces: 1,
                            amounts: 140,
                            paymentMethod: PaymentMethod.cash,
                            remarks: ""),
            Transaction.init(title: AccountsTitle.init(title: "Gas"),
                            date: Date(),
                            name: "TestMock2",
                            pieces: 1,
                            amounts: 2000,
                            paymentMethod: PaymentMethod.cash,
                            remarks: ""),
            Transaction.init(title: AccountsTitle.init(title: "Detergents"),
                            date: Date(),
                            name: "TestMock2",
                            pieces: 1,
                            amounts: 2600,
                            paymentMethod: PaymentMethod.cash,
                            remarks: ""),

        ] as [Transaction]
        
        let analyzer = TransactionAnalyzer(database)
        XCTAssertEqual(analyzer.weeklyExpense(), 5140)
        XCTAssertEqual(analyzer.weeklyHeaderBreakdown(), ["Food", "Utilities", "Daily Uses"])
        XCTAssertEqual(analyzer.weeklyAmountsBreakdown(), [540, 2000, 2600])
        XCTAssertEqual(analyzer.monthlyExpense(), 5140)
        XCTAssertEqual(analyzer.monthlyHeaderBreakdown(), ["Food", "Utilities", "Daily Uses"])
        XCTAssertEqual(analyzer.monthlyAmountsBreakdown(), [540, 2000, 2600])
    }

}
