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

import UIKit
import MapKit
import SwiftGraph

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    private var index: Int = 0
    private var lastCoordinate: CLLocationCoordinate2D?
    
    private var lpgr: UILongPressGestureRecognizer!
    
    private var activeVertix: MKAnnotation?
    
    private var graph = WeightedGraph<String, Int>()
    
    var vertices: [String] = []
    
    var existingVertix: MKAnnotation?
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
        if let newCoordinate = existingVertix?.coordinate, newCoordinate == coordinate {
            if let from = activeVertix?.title, let to = existingVertix?.title {
                createEdge(from: from ?? String(), to: to ?? String())
            }
            let myLastCoordinate = activeVertix?.coordinate
            addLine(from: myLastCoordinate!, to: newCoordinate)
            return
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(index)"
        annotation.subtitle = "subtitle \(index)"
        mapView.addAnnotation(annotation)
        createVertix()
        
        if let myLastCoordinate = activeVertix?.coordinate {
            guard let title = activeVertix?.title else { return }
            if let number = title {
                createEdge(from: number, to: annotation.title ?? String())
            }
            addLine(from: myLastCoordinate, to: coordinate)
        } else {
            activeVertix = annotation
        }
        lastCoordinate = coordinate
        
    }
    
    private func addLine(from begin: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
        let line = MKPolyline(coordinates: [begin, end], count: 2)
        mapView.addOverlay(line)
    }
    
    private func saveGraph() {
        
    }
    
    private func createVertix() {
        let newVertix = "\(index)"
        let _ = graph.addVertex(newVertix)
    }
    
    private func createEdge(from begin: String, to end: String) {
        graph.addEdge(from: begin, to: end, weight: 1)
    }
    
    
    @IBAction func printGraph(_ sender: Any) {
        print(graph)
        print(graph.dijkstra(root: 0, startDistance: 0))
        // it works

        let (distances, pathDict) = graph.dijkstra(root: 0, startDistance: 0)
        let shortestPath = pathDictToPath(from: 0, to: 4, pathDict: pathDict)

        print(shortestPath)
        let shortestWeight = shortestPath.reduce(0, { $0 + $1.weight })
        print(shortestWeight)
    }
    
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        isExistingVertixTapped = false
        if gestureReconizer.state != .ended {
            var touchLocation = gestureReconizer.location(in: mapView)
            
            let loc = gestureReconizer.location(in: mapView)
            let ccc = mapView.hitTest(loc, with: nil)
        
            if let cac = ccc as? MKAnnotationView {
                existingVertix = cac.annotation
                touchLocation = mapView.convert(cac.annotation!.coordinate, toPointTo: mapView)
            }
            
            let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            addAnnotation(on: locationCoordinate)
            return
        }
        if gestureReconizer.state != .began {
            
            return
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRender = MKPolylineRenderer(overlay: overlay)
            polylineRender.strokeColor = .red
            polylineRender.lineWidth = 5
            return polylineRender
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        activeVertix = view.annotation
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        let customAnnotationView = self.customAnnotationView(in: mapView, for: annotation)
        customAnnotationView.number = index
        index += 1
        return customAnnotationView
    }
    
    private func customAnnotationView(in mapView: MKMapView, for annotation: MKAnnotation) -> CustomAnnotationView {
        let identifier = "CustomAnnotationViewID"

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
