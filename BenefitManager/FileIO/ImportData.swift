//
//  ImportData.swift
//  BenefitManager2
//
//  Created by Kohei Konishi on 2020/03/29.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Foundation

struct ImportData {
    let className: String
    let variables: [[String]]
    
    init(name className: String, variables vars: [[String]]) {
        self.className = className
        self.variables = vars
    }
}
