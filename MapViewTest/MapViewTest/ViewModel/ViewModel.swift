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
    
    // Создать массив для хранения путей
    private var path = [MapVertix]()
    
    var vertixCount: Int {
        return graph.vertexCount
    }
    
    func title(of vertixNumber: Int) -> String? {
        guard let vertix = graph.vertices.first(where: { $0.number == vertixNumber }) else {
            return "UNKNOWN VERTIX with number: \(vertixNumber)"
        }
        return "\(vertix.number)"
    }
    
    func vertix(by number: Int) -> MapVertix? {
        return graph.vertices.first(where: { $0.number == number })
    }
    
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
    
    func bellmanFord(src: MapVertix, destination: MapVertix) {
        let pathDict = graph.bellmanFord(source: src, destination: destination)
        let path = graph.pathDictToPath(from: src, to: destination, pathDict: pathDict)
        viewDelegate?.didChangeEdgeColor(.yellow)
        showPath(path)
    }
    
    private func showPath(_ path: [WeightedEdge<Double>]) {
        path.forEach { edge in
            let start = graph.vertexAtIndex(edge.u)
            let end = graph.vertexAtIndex(edge.v)
            let mapEdge = createEdge(from: start, to: end)
            
            self.viewDelegate?.didGetNewVertix(start)
            self.viewDelegate?.didGetNewVertix(end)
            self.viewDelegate?.didGetNewEdge(mapEdge)
        }
    }
}
