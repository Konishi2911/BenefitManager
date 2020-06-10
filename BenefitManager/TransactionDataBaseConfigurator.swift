//
//  TransactionDataBaseConfigurator.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/07.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

struct TransactionDataBaseConfigurator {
    static let dataBaseFileName = "untitle.bmdb"
    static let dataBaseDirectory = NSHomeDirectory()
    static let dataBaseFilePath = dataBaseDirectory + "/" + dataBaseFileName
    
    static public var dataBaseName: String {
        get {
            return "DB1"
        }
    }
    static public func configure() {
        TransactionDataBase.createNewDataBase(identifier: TransactionDataBaseConfigurator.dataBaseName)
        do {
            try TransactionDataBase.importRecord(to: TransactionDataBaseConfigurator.dataBaseName)
        } catch {
            fatalError()
        }
    }
}
