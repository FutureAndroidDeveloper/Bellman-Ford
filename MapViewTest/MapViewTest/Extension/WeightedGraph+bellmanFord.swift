//
//  WeightedGraph+bellmanFord.swift
//  MapViewTest
//
//  Created by Klimenkov, Kirill on 09.12.2020.
//  Copyright © 2020 Kirill Klimenkov. All rights reserved.
//

import Foundation
import SwiftGraph

//MARK: `WeightedGraph` extension for doing Bellman-Ford
public extension WeightedGraph {
    typealias GraphPathDict = [Int: WeightedEdge<W>]
    
    func bellmanFord(source: Int, destination: Int) -> GraphPathDict {
        var pathDict: GraphPathDict = GraphPathDict()
        
        // init distances from src to all other vertices as INFINITY
        var distance = vertices.map { _ in Double.infinity }
        distance[source] = 0
        
        // Step 2: relax edges repeatedly
        for _ in 1..<vertices.count {
            for edge in edgeList() {
                let weight = edge.weight as! Double
                if distance[edge.u] + weight < distance[edge.v] {
                    distance[edge.v] = distance[edge.u] + weight
                    pathDict[edge.v] = edge
                }
            }
        }
        
        // Step 3: check for negative-weight cycles
         for edge in edgeList() {
            let weight = edge.weight as! Double
            if distance[edge.u] + weight < distance[edge.v] {
                print("Graph contains a negative-weight cycle")
                return [:]
            }
        }
        return pathDict
    }
    
    /// A convenience version of bellmanFord() that allows the supply of the vertexes instead of the indexes.
    func bellmanFord(source: V, destination: V) -> GraphPathDict {
        if let u = indexOfVertex(source), let v = indexOfVertex(destination) {
            return bellmanFord(source: u, destination: v)
        }
        return [:]
    }
    
    func pathDictToPath(from: V, to: V, pathDict: GraphPathDict) -> [WeightedEdge<W>] {
        if let start = indexOfVertex(from), let end = indexOfVertex(to) {
            return SwiftGraph.pathDictToPath(from: start, to: end, pathDict: pathDict)
        }
        return []
    }
}
