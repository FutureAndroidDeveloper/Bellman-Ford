//
//  ViewModel.swift
//  MapViewTest
//
//  Created by Кирилл Клименков on 12/5/20.
//  Copyright © 2020 Kirill Klimenkov. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftGraph

class ViewModel {
    weak var viewDelegate: ViewDelegate?
    private var index: Int = 0
    private var graph = WeightedGraph<MapVertix, Double>()
    
    func createVertix(on coordinate: CLLocationCoordinate2D) -> MapVertix {
        let newVertix = MapVertix(number: index, coordinate: coordinate)
        let vertixIndex = graph.addVertex(newVertix)
        // посмотреть совпадают ли индексы ( если да, то моыжно просто return newVerix без AtInde)
        print(vertixIndex)
        print(index)
        
        index += 1
        return graph.vertexAtIndex(vertixIndex)
    }
    
    func createEdge(from begin: MapVertix, to end: MapVertix) -> MapEdge {
        guard let beginIndex = graph.indexOfVertex(begin), let endIndex = graph.indexOfVertex(end) else {
//            return nil
            fatalError("Check creation of MapVertix")
        }
        let distance = CLLocation.distance(from: begin.coordinate, to: end.coordinate)
        let mapEdge = MapEdge(startCoordinate: begin.coordinate, endCoordinate: end.coordinate, weight: distance)
        let edge = WeightedEdge<Double>.init(u: beginIndex, v: endIndex, directed: false, weight: distance)
        graph.addEdge(edge, directed: false)
        return mapEdge
    }
    
    func loadGraphFromFile() {
        let fileManager = DiskGraphFileManager<WeightedGraph<MapVertix, Double>>()
        guard let loadedGraph = fileManager.loadGraph() else {
            print("Cant load graph from file")
            return
        }
        graph = loadedGraph
        index = graph.endIndex
        dispayGraph()
    }
    
    func dispayGraph() {
        // отрисовать вершины графа
        graph.vertices.forEach { [weak self] vertix in
            self?.viewDelegate?.didGetNewVertix(vertix)
        }
        
        // отрисовать ребра графа
        graph.edgeList().forEach { [weak self] edge in
            let start = graph.vertexAtIndex(edge.u).coordinate
            let end = graph.vertexAtIndex(edge.v).coordinate
            let mapEdge = MapEdge(startCoordinate: start, endCoordinate: end, weight: edge.weight)
            self?.viewDelegate?.didGetNewEdge(mapEdge)
        }
    }
    
    func saveGraphToFile() {
        DiskGraphFileManager().save(graph: graph)
        print()
        print("k: \(graph)")
        print(graph.edgeList())
    }
    
    func bellmanFord(src: MapVertix) {
            guard let srcIndex = graph.indexOfVertex(src) else {
                return
            }
            // init distances from src to all other vertices  as INFINITY
            var dist = graph.vertices.map { _ in Double.infinity }
            dist[srcIndex] = 0
            
            // Relax all edges
            for _ in (0..<graph.vertices.count - 1) {
                // Update dist value and parent index of the adjacent vertices of
                // the picked vertex. Consider only those vertices which are still in
                // queue
                for edge in graph.edgeList() {
                    if dist[edge.u] != Double.infinity && dist[edge.u] + edge.weight < dist[edge.v] {
                        dist[edge.v] = dist[edge.u] + edge.weight
                    }
                }
            }
            
            // Step 3: check for negative-weight cycles. The above step
            // guarantees shortest distances if graph doesn't contain
            // negative weight cycle. If we get a shorter path, then there
            // is a cycle.
            for edge in graph.edgeList() {
                if dist[edge.u] != Double.infinity && dist[edge.u] + edge.weight < dist[edge.v] {
                    print("Graph contains negative weight cycle")
                    return
                }
            }
            
    //        print(dist)
            
            print("Vertex Distance from Source")
            for i in (0..<graph.vertices.count) {
                print("\(i)        \(dist[i])")
            }
            
            print()
            
            print(graph.dijkstra(root: src, startDistance: 0))
            
            let dijkstra = graph.dijkstra(root: src, startDistance: 0)
            let path = pathDictToPath(from: 0, to: 3, pathDict: dijkstra.1)
            
            let pathColor = UIColor.blue
            let pathAplpha = 0.8
            
            // draw shotest path
            path.forEach { edge in
                let start = graph.vertexAtIndex(edge.u)
                let end = graph.vertexAtIndex(edge.v)
                // TODO: call viewdelegate

                let mapEdge = MapEdge(startCoordinate: start.coordinate,
                                      endCoordinate: end.coordinate,
                                      weight: edge.weight)
                self.viewDelegate?.didGetNewEdge(mapEdge)
            }
            
        }
}
