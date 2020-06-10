//
//  FIleExporter.swift
//  BenefitManager2
//
//  Created by Kohei Konishi on 2020/03/28.
//  Copyright © 2020 Kohei Konishi. All rights reserved.
//

import Foundation

struct ExportingDataSet {
    let className: String
    let variableNames: [String]
    let values: [String]
}

class FileExporter {
    public var filename: String = "untitle"
    public var directory: String = ""
    private var dataStr: String = ""
    
    init() {
        directory = NSHomeDirectory()
    }
    init(fileNmae name: String, exportingDirectory directory: String) {
        self.filename = name
        self.directory = directory
    }
    
    func export(from source: IFileExportalbe) throws {
        let fileManager = FileManager()
        let filePath = directory + filename
        
        // Make Data
        let data = makeFileString(from: source.makeExportingDataSet()).data(using: .utf8)
        
        // Export to File
        if fileManager.fileExists(atPath: filePath) {
            try fileManager.removeItem(atPath: filePath)
        }
        fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
    }
    
    func export(from source: [IFileExportalbe]) throws {
        let fileManager = FileManager()
        let filePath = directory + "/" + filename
        
        // Make Data
        var strData: String = ""
        for strd in source {
            strData += makeFileString(from: strd.makeExportingDataSet())
        }
        let data = strData.data(using: .utf8)
    
        // Export to File
        if fileManager.fileExists(atPath: filePath) {
            try fileManager.removeItem(atPath: filePath)
        }
        fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
    }
    
    private func makeFileString(from dataset: ExportingDataSet) -> String {
        var fileStr: String = ""
        let numberOfData = dataset.values.count

        fileStr += "##" + dataset.className + "\r\n"
        for i in 0..<numberOfData {
            fileStr += dataset.variableNames[i] + ":" + dataset.values[i] + "\r\n"
        }
        fileStr += "==\r\n"
        
        return fileStr
    }
}
