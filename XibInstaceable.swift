//
//  XibInstaceable.swift
//  BenefitManager
//
//  Created by Kohei Konishi on 2020/06/02.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Cocoa

protocol XibInstanceable where Self: NSView {
    static var xibName: String { get }
}

extension XibInstanceable where Self: NSView {
    static var xibInstance: NSNib {
        get {
            return NSNib(nibNamed: xibName, bundle: nil)!
        }
    }
    
    static func getInstance(withOwner: Any?) -> Self? {
        var instances: NSArray? = []
        if xibInstance.instantiate(withOwner: self, topLevelObjects: &instances) {
            for object in instances! {
                if let view = object as? Self {
                    return view
                }
            }
        }
        return nil
    }
}
