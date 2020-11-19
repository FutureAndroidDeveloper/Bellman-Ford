//
//  ViewController.swift
//  MapViewTest
//
//  Created by Кирилл Клименков on 11/9/20.
//  Copyright © 2020 Kirill Klimenkov. All rights reserved.
//

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension CLLocation {
    
    /// Get distance between two points
    ///
    /// - Parameters:
    ///   - from: first point
    ///   - to: second point
    /// - Returns: the distance in meters
    class func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
}

import UIKit
import MapKit
import SwiftGraph

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    private var index: Int = 0
    
    private var lpgr: UILongPressGestureRecognizer!
    
    private var activeVertix: MapVertix?
    
    private var graph = WeightedGraph<MapVertix, Double>()
    
    var vertices: [String] = []
    
    var existingVertix: MapVertix?
    var isExistingVertixTapped: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapview()
    }
    
    private func setMapview() {
        lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureReconizer:)))
        lpgr.cancelsTouchesInView = true
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        mapView.delegate = self
        mapView.addGestureRecognizer(lpgr)
    }
    
    private func addAnnotation(on coordinate: CLLocationCoordinate2D) {
        // если нажатие произошло на активную вершину
        if let activeCoordinate = activeVertix?.coordinate, activeCoordinate == coordinate {
            return
        }
        
        // если дбавление происходит на уже существующую вершину
        if let existingCoordinate = existingVertix?.coordinate, existingCoordinate == coordinate {
            if let from = activeVertix, let to = existingVertix {
                createEdge(from: from, to: to)
                addLine(from: from.coordinate, to: to.coordinate)
            }
            return
        }
        
        let vertix = createVertix(on: coordinate)
        let annotation = VertixAnnotation(vertix: vertix)
        mapView.addAnnotation(annotation)
        index += 1
        
        if let activeVertix = activeVertix {
            createEdge(from: activeVertix, to: vertix)
            addLine(from: activeVertix.coordinate, to: vertix.coordinate)
        } else {
            activeVertix = vertix
        }
    }
    
    private func addLine(from begin: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
        let line = MKPolyline(coordinates: [begin, end], count: 2)
        mapView.addOverlay(line)
    }
    
    private func saveGraph() {
        
    }
    
    private func createVertix(on coordinate: CLLocationCoordinate2D) -> MapVertix {
        let newVertix = MapVertix(number: index, coordinate: coordinate)
        let vertixIndex = graph.addVertex(newVertix)
        return graph.vertexAtIndex(vertixIndex)
    }
    
    private func createEdge(from begin: MapVertix, to end: MapVertix) {
        let a = begin.coordinate
        let b = end.coordinate
        let w = CLLocation.distance(from: a, to: b)
        graph.addEdge(from: begin, to: end, weight: w)
    }
    
    
    @IBAction func printGraph(_ sender: Any) {
        //        print(graph)
        //        print(graph.dijkstra(root: 0, startDistance: 0))
        //        // it works
        //
        //        let (distances, pathDict) = graph.dijkstra(root: 0, startDistance: 0)
        //        let shortestPath = pathDictToPath(from: 0, to: 4, pathDict: pathDict)
        //
        //        print(shortestPath)
        //        let shortestWeight = shortestPath.reduce(0, { $0 + $1.weight })
        //        print(shortestWeight)
        saveGraphToFile()
    }
    
    private func saveGraphToFile() {
        DiskGraphFileManager().saveGraph()
        print("k: \(graph)")
        print(graph.edgeList())
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        switch gestureReconizer.state {
        case .began:
            var pressCoordinate: CLLocationCoordinate2D
            let touchLocation = gestureReconizer.location(in: mapView)
            let tappedView = mapView.hitTest(touchLocation, with: nil)
            
            // если нажатие попало на уже созданную вершину
            if let markerView = tappedView as? CustomAnnotationView,
                let annotation = markerView.annotation as? VertixAnnotation {
                existingVertix = annotation.vertix
                pressCoordinate = annotation.vertix.coordinate
            } else {
                pressCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            }
            addAnnotation(on: pressCoordinate)
        default:
            break
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            // настройка линии
            let polylineRender = MKPolylineRenderer(overlay: overlay)
            polylineRender.strokeColor = .red
            polylineRender.lineWidth = 5
            return polylineRender
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? VertixAnnotation else { return }
        activeVertix = annotation.vertix
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let vertixAnnotation = annotation as? VertixAnnotation else { return nil }
        let view = customAnnotationView(in: mapView, for: vertixAnnotation)
        view.number = vertixAnnotation.vertix.number
        return view
    }
    
    private func customAnnotationView(in mapView: MKMapView, for annotation: MKAnnotation) -> CustomAnnotationView {
        let identifier = MKMapViewDefaultAnnotationViewReuseIdentifier
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomAnnotationView {
            annotationView.annotation = annotation
            return annotationView
        } else {
            let customAnnotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            customAnnotationView.canShowCallout = true
            return customAnnotationView
        }
    }
}
