//
//  FIleExporter.swift
//  BenefitManager2
//
//  Created by Kohei Konishi on 2020/03/28.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Foundation

class FileExporter {
    public var filename: String = "untitle"
    public var directory: String = ""
    private var dataStr: String = ""
    
    init() {
        directory = NSHomeDirectory()
    }
    
    func export(from source: IFileExportalbe) throws {
        let fileManager = FileManager()
        let filePath = directory + filename + ".pb"
        
        // Make Data
        let data = source.makeFileString().data(using: .utf8)
        
        // Export to File
        if fileManager.fileExists(atPath: filePath) {
            try fileManager.removeItem(atPath: filePath)
        }
        fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
    }
    
    func export(from source: [IFileExportalbe]) throws {
        let fileManager = FileManager()
        let filePath = directory + "/" + filename + ".pb"
        
        // Make Data
        var strData: String = ""
        for strd in source {
            strData += strd.makeFileString()
        }
        let data = strData.data(using: .utf8)
    
        // Export to File
        if fileManager.fileExists(atPath: filePath) {
            try fileManager.removeItem(atPath: filePath)
        }
        fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
    }
}
