//
//  MenuTableItemViewController.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/02.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

class MenuTableCellView: NSTableCellView, XibInstanceable {
    static var xibName: String {
        get {
            return "MenuTableItemView"
        }
    }
    
    @IBOutlet weak var icon: NSImageView!
    @IBOutlet weak var label: NSTextField!
    
    init (frameWidth width: Double) {
        let frameRect = NSRect(x: 0, y: 0, width: width, height: 36.0)
        
        super.init(frame: frameRect)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setWidth (tableWidth width: CGFloat) {
        self.frame = NSRect(x: 0, y: 0, width: width, height: 36)
    }
    func setLabel(_ text: String) {
        label.stringValue = text
    }
    func setIcon(fromURL url: URL) {
        let iconImage = NSImage(byReferencing: url)
        icon.image = iconImage
    }
}
