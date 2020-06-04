//
//  BaseWondowManager.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/02.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    // Name of MenuItems
    private let menuItemLabels: [String] =
    [
        "Overview",
        "Statistics",
        "Journal"
    ]
    // URLs of image on menu item
    private let menuItemIconsURL: [URL] =
    [
        URL(fileURLWithPath: "/Volumes/Elements/Personal/Programming/pictures/icon/icon1.png" ),
        URL(fileURLWithPath: "/Volumes/Elements/Personal/Programming/pictures/icon/icon1.png" ),
        URL(fileURLWithPath: "/Volumes/Elements/Personal/Programming/pictures/icon/icon1.png" )
    ]
    
    @IBOutlet weak var menuTableView: NSTableView!
    @IBOutlet weak var contentsView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Confugure the height of MenuTableCellView
        menuTableView.rowHeight = 36
        // Select first row
        menuTableView.selectRowIndexes(IndexSet(0...0), byExtendingSelection: false)
        
        // Set Page
        switchPage()
    }
    
    func switchPage() {
        // Deallocate relationship
        for child in self.children {
            child.viewWillDisappear()
            child.removeFromParent()
        }
        // Remove current view
        for subview in contentsView.subviews {
            contentsView.willRemoveSubview(subview)
            subview.removeFromSuperview()
        }
        
        var childView: NSViewController? = nil
    
        switch menuTableView.selectedRow {
        // Overview View
        case 0:
            childView = OverviewViewController(nibName: "OverviewViewLayout", bundle: nil)
        // Statistics View
        case 1:
            childView = StatisticsViewController(nibName: "StatisticsViewLayout", bundle: nil)
        // Journal View
        case 2:
            childView = JournalViewController(nibName: "JournalViewLayout", bundle: nil)
        // invalid selection
        default:
            return
        }
        
        // Add content view selected by menu table, as child view
        self.addChild(childView!)
        childView!.view.frame = self.contentsView.bounds
        contentsView.addSubview(childView!.view)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return menuItemLabels.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Get width of tableView and set width of menuItem
        let tableWidth = tableView.bounds.width
        
        // Create instance of menu item
        let menuItem = MenuTableCellView.getInstance(withOwner: self)!
        // Configure bounds of MenuItem
        menuItem.setWidth(tableWidth: tableWidth)
        // Name and assign the icon image to menuItem
        menuItem.setLabel(menuItemLabels[row])
        menuItem.setIcon(fromURL: menuItemIconsURL[row])
        
        return menuItem
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        // Switch content view
        switchPage()
    }
}
