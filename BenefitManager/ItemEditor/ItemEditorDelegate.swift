//
//  ItemEditorDelegate.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/05.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

protocol ItemEditorDelegate {
    func editingDidFinish(newRecord: Transaction)
}
