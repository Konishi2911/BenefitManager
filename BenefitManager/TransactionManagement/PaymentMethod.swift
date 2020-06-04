//
//  PaymentMethod.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/04.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

enum PaymentMethod: String, CaseIterable {
    case cash = "Cash"
    case auWallet = "au Wallet"
    case rEdy = "R Edy"
    case credit = "Credit"
    
    static func allRawCases() -> [String] {
         var temp: [String] = []
         for element in PaymentMethod.allCases {
             temp.append(element.rawValue)
         }
         return temp
     }
}
