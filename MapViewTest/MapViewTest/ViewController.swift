//
//  ViewController.swift
//  MapViewTest
//
//  Created by Кирилл Клименков on 11/9/20.
//  Copyright © 2020 Kirill Klimenkov. All rights reserved.
//

import UIKit
import MapKit
import SwiftGraph

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    private var index: Int = 0
    private var lastCoordinate: CLLocationCoordinate2D?
    
    private var lpgr: UILongPressGestureRecognizer!
    
    private var activeVertix: MKAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapview()
        graph()
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
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(index)"
        annotation.subtitle = "subtitle \(index)"
        mapView.addAnnotation(annotation)
        
        if let lastCoordinate = lastCoordinate {
            let myLastCoordinate = activeVertix?.coordinate
            print(myLastCoordinate)
//            addLine(from: lastCoordinate, to: coordinate)
            addLine(from: myLastCoordinate!, to: coordinate)
        } else {
            activeVertix = annotation
        }
        index += 1
        lastCoordinate = coordinate
        
        
    }
    
    private func addLine(from begin: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
        let line = MKPolyline(coordinates: [begin, end], count: 2)
        mapView.addOverlay(line)
    }
    
    private func graph() {
        let a0 = "0"
        let a1 = "1"
        let a2 = "2"
        let a3 = "3"
        let a4 = "4"
        
        let graph = WeightedGraph<String, Int>(vertices: [a0, a1, a2, a3, a4])
        graph.addEdge(from: a0, to: a1, weight: 3)
        graph.addEdge(from: a0, to: a2, weight: 5)
        
        graph.addEdge(from: a1, to: a2, weight: 1)
        graph.addEdge(from: a1, to: a3, weight: 4)
        graph.addEdge(from: a1, to: a4, weight: 6)
        
        graph.addEdge(from: a2, to: a3, weight: 1)
        graph.addEdge(from: a2, to: a4, weight: 7)
        
        graph.addEdge(from: a3, to: a4, weight: 2)
        
        print(graph.dijkstra(root: 0, startDistance: 0))
        // it works
        
        let (distances, pathDict) = graph.dijkstra(root: 0, startDistance: 0)
        let shortestPath = pathDictToPath(from: 0, to: 4, pathDict: pathDict)
        
        print(shortestPath)
        let shortestWeight = shortestPath.reduce(0, { $0 + $1.weight })
        print(shortestWeight)
        
    }
    
    
    @objc func haha(gestureReconizer: UILongPressGestureRecognizer) {
        print("LOX")
    }
}

extension ViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        
//        return true
//    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        
        
        if gestureReconizer.state != .ended {
            var touchLocation = gestureReconizer.location(in: mapView)
            
            if let vertix = activeVertix, let myView = mapView.view(for: vertix) {
                let loc = gestureReconizer.location(in: mapView)
                let ccc = mapView.hitTest(loc, with: nil)
                
                if let cac = ccc as? MKAnnotationView {
                    touchLocation = cac.center
                    mapView.removeAnnotation(cac.annotation!)
                }
                
            }
            
            let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            addAnnotation(on: locationCoordinate)
            print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
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
        customAnnotationView.number = arc4random_uniform(10)
        customAnnotationView.accessibilityLabel = "\(customAnnotationView.number)"
        
        let abc = UILongPressGestureRecognizer()
        abc.minimumPressDuration = 0.3
        abc.require(toFail: lpgr)
        abc.addTarget(self, action: #selector(haha(gestureReconizer:)))
        customAnnotationView.addGestureRecognizer(abc)
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
