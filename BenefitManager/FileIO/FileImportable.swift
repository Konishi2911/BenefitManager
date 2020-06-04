//
//  FileImportableProtocol.swift
//  BenefitManager2
//
//  Created by Kohei Konishi on 2020/03/31.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Foundation

protocol FileImportable {
    mutating func importFile(from imdata: ImportData) -> Void
}

/*
extension FileImportable where Self: struct {
    mutating func importFile(from imdata: ImportData) -> Void
}

extension FileImportable where Self: AnyObject {
    func importFile(from imdata: ImportData) -> Void
}
 */

