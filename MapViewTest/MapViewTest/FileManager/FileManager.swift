//
//  FileManager.swift
//  MapViewTest
//
//  Created by Klimenkov, Kirill on 18.11.2020.
//  Copyright © 2020 Kirill Klimenkov. All rights reserved.
//

import Foundation

protocol GraphFileManager {
    func saveGraph()
    func loadGraph()
}

class DiskGraphFileManager: GraphFileManager {
    func saveGraph() {
        let filename = getDocumentsDirectory().appendingPathComponent("output.txt")
        print(filename)
        let ha = ["17.1, 26.8", "17.1, 26.8", "17.1, 26.8"]
        
        
        let data = stringArrayToNSData(array: ha)
        let a = Data(referencing: data)
        FileManager.default.createFile(atPath: filename.path, contents: a, attributes: nil)
    }

    func stringArrayToNSData(array: [String]) -> NSData {
        let data = NSMutableData()
        let terminator = [0]
        for string in array {
            if let encodedString = string.data(using: .utf8) {
                data.append(encodedString)
                data.append(terminator, length: 1)
            }
            else {
                NSLog("Cannot encode string \"\(string)\"")
            }
        }
        return data
    }

    
    func loadGraph() {
        //
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
