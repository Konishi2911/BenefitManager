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
    func testAccountsTitle() {
        var i = 0;
        for _ in AccountsTitle.headersString(transactionType: .Expense) {
            for titleText in AccountsTitle.titlesString(at: i, transactionType: .Expense) {
                let testInstance = AccountsTitle(title: titleText);
                XCTAssertEqual(testInstance.titleString, titleText)
            }
            i += 1
        }
        
        let testInstance = AccountsTitle(title: "Dammy")
        XCTAssertEqual(testInstance.titleString, "")

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
            Transaction.init(title: AccountsTitle.init(title: "Miscellaneous"),
                            date: Date(),
                            name: "TestMock2",
                            pieces: 1,
                            amounts: 1000,
                            paymentMethod: PaymentMethod.cash,
                            remarks: ""),

        ] as [Transaction]
        
        let analyzer = TransactionAnalyzer(database)
        XCTAssertEqual(analyzer.week.totalAmounts(type: .Expense), 6140)
        XCTAssertEqual(analyzer.week.headersBreakdown(type: .Expense), ["Food", "Utilities", "Daily Uses"])
        XCTAssertEqual(analyzer.week.amountsBreakdown(type: .Expense), [540, 2000, 3600])
        XCTAssertEqual(analyzer.month.totalAmounts(type: .Expense), 6140)
        XCTAssertEqual(analyzer.month.headersBreakdown(type: .Expense), ["Food", "Utilities", "Daily Uses"])
        XCTAssertEqual(analyzer.month.amountsBreakdown(type: .Expense), [540, 2000, 3600])
    }

}
