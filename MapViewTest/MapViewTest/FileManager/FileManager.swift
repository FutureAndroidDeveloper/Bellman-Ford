//
//  FileManager.swift
//  MapViewTest
//
//  Created by Klimenkov, Kirill on 18.11.2020.
//  Copyright © 2020 Kirill Klimenkov. All rights reserved.
//

import Foundation
import SwiftGraph

protocol GraphFileManager {
    associatedtype Graph
    func save(graph: Graph)
    func loadGraph() -> Graph?
}

class DiskGraphFileManager<GraphType: Graph>: GraphFileManager {
    typealias Graph = GraphType
    
    func save(graph: GraphType) {
        let filename = getDocumentsDirectory().appendingPathComponent("output.txt")
        print(filename)
        do {
            let graphData = try PropertyListEncoder().encode(graph)
            try graphData.write(to: filename)
        } catch let error {
            print(error)
        }
    }
    
    func loadGraph() -> GraphType? {
        var graph: GraphType?
        let filename = getDocumentsDirectory().appendingPathComponent("output.txt")
        
        do {
            let graphData = try Data(contentsOf: filename)
            graph = try PropertyListDecoder().decode(GraphType.self, from: graphData)
        } catch let error {
            print(error)
        }
        
        return graph
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
