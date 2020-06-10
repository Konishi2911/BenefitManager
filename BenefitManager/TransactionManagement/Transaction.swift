//
//  Transaction.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/03.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

struct Transaction {
    var accountsTitle: AccountsTitle = AccountsTitle.Empty
    var date: Date = Date()
    var name: String = ""
    var pieces: Int = -1
    var amounts: Int = -1
    var paymentMethod: PaymentMethod = .auWallet
    var remarks: String = ""
    
    // Add variables to this enum when new variables are added
    enum variables: String, CaseIterable {
        case accountsTitle
        case date
        case name
        case pieces
        case amounts
        case paymentMethod
        case remarks
        
        static func getElements() -> [String] {
            var temp: [String] = []
            for element in variables.allCases {
                temp.append(element.rawValue)
            }
            return temp
        }
    }
    
    let dateFormatter: DateFormatter = .init()
    
    init (importFrom source: ImportData) {
        self.initializeFields()
        self.importFile(from: source)
    }
    init (title actsTitle: AccountsTitle, date _date: Date, name _name: String, pieces _pieces: Int, amounts _amounts: Int, paymentMethod pMethod: PaymentMethod, remarks _remarks: String) {
        accountsTitle = actsTitle
        date = _date
        name = _name
        pieces = _pieces
        amounts = _amounts
        paymentMethod = pMethod
        remarks = _remarks
        
        initializeFields()
    }
    func initializeFields() {
        dateFormatter.dateFormat = "yyyy/MM/dd"
    }
}

extension Transaction: IFileExportalbe {
    func makeExportingDataSet() -> ExportingDataSet {
        let variableNames: [String] = variables.getElements()
        let values: [String] = [
            accountsTitle.string(),
            dateFormatter.string(from: date),
            name,
            String(pieces),
            String(amounts),
            paymentMethod.rawValue,
            remarks
        ]
        return .init(className: String(describing: type(of: self)),
                     variableNames: variableNames,
                     values: values)
    }
}

extension Transaction: FileImportable {
    mutating func importFile(from imdata: ImportData) {
        if imdata.className == String(describing: type(of: self)) {
            for variable in imdata.variables {
                switch variable[0] {
                case "accountsTitle":
                    self.accountsTitle = AccountsTitle(title: variable[1])
                case "date":
                    self.date = dateFormatter.date(from: variable[1])!
                case "name":
                    self.name = variable[1]
                case "pieces":
                    self.pieces = Int(variable[1])!
                case "amounts":
                    self.amounts = Int(variable[1])!
                case "paymentMethod":
                    self.paymentMethod = PaymentMethod(rawValue: variable[1])!
                case "remarks":
                    self.remarks = variable[1]
                default:
                    break
                }
            }
        }
    }
}
