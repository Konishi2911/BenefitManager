//
//  ItemEditorDelegate.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/05.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa
struct RecordInformationWrapper {
    let newRecord: Transaction?
    let recordNumber: Int
    let isNewRecord: Bool
}

protocol ItemEditorViewDelegate {
    func recordInformation() -> RecordInformationWrapper
    func editingDidFinish(recordInformation: RecordInformationWrapper)
}
