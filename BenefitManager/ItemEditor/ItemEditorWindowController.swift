//
//  ItemEditorWindowController.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/03.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

class ItemEditorWindowController: NSWindowController {
    var newRecordFlag: Bool = true
    var dataBaseName: String = ""
    var recordNumber: Int = -1
    
    var caller: ItemEditorViewDelegate?
    var newRecord: Transaction?
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
}
