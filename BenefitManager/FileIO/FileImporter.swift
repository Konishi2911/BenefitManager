//
//  FileImporter.swift
//  BenefitManager2
//
//  Created by Kohei Konishi on 2020/03/29.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Foundation

class FileImporter {
    private let _filePath: String
    private var _importStr: String = ""
    private var _analyzedData: [ImportData] = []
    
    var analyzedData: [ImportData] { get {return _analyzedData} }
    
    init() {
        _filePath = NSHomeDirectory() + "/untitle.pb"
    }
    
    func importData() throws {
        _importStr = try String(contentsOf: URL(fileURLWithPath: _filePath))
        
        //let processedStr = importStr.replacingOccurrences(of: " ", with: "")
        let strArray = _importStr.components(separatedBy: .newlines)
        
        var isContents: Bool = false
        var className: String = ""
        var variables: [[String]] = []
        
        for tempStr in strArray {
            if !isContents {
                if tempStr.contains("##") {
                    // Detect ## tag
                    let tagRange = tempStr.range(of: "##")!
                    
                    // Remove Space
                    let ptempStr = tempStr.replacingOccurrences(of: " ", with: "")
                    
                    className = String(
                        ptempStr[tempStr.index(tagRange.lowerBound, offsetBy: 2) ..< ptempStr.endIndex]
                    )
                    isContents = true
                }
            } else {
                let varName: String
                let val: String
                if tempStr.contains(":") {
                    // Detect ":"
                    let separatorRange = tempStr.range(of: ":")!
                    
                    // Name of variables without spaces
                    varName = String(
                        tempStr[tempStr.startIndex ..< separatorRange.lowerBound]
                    ).replacingOccurrences(of: " ", with: "")
                    
                    // Add values with spaces
                    val = String(
                        tempStr[separatorRange.upperBound ..< tempStr.endIndex]
                    )
                    
                    // Add pairs of variables name and values
                    variables.append([varName, val])
                    
                } else if tempStr.contains("==") {
                    isContents = false
                    
                    _analyzedData.append(
                        ImportData(name: className, variables: variables)
                    )
                    
                    // Clear temporary variables
                    className = ""
                    variables = []
                }
            }
        }
    }
}
