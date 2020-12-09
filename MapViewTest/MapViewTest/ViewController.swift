//
//  ViewController.swift
//  MapViewTest
//
//  Created by Кирилл Клименков on 11/9/20.
//  Copyright © 2020 Kirill Klimenkov. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    @IBOutlet private weak var mapView: MKMapView!
    private var lpgr: UILongPressGestureRecognizer!
        
    private var viewModel = ViewModel()
    
    private var activeVertix: MapVertix?
    private var existingVertix: MapVertix?
    
    var pathColor: UIColor = .red
    var pathAplpha: CGFloat = 1
    
    var isSelectingMode = false
    var vertixColor = UIColor.blue
    
    var mapPath: MapPath?
    var selectedAnnotations: [MapVertix] = []
    
    let startColor: UIColor = .red
    var startVertix: MapVertix?
    
    let endColor: UIColor = .green
    var endVertix: MapVertix?
    
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
        
        pathColor = .red
        
        viewModel.viewDelegate = self
        
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
                let edge = viewModel.createEdge(from: from, to: to)
                drawEdge(edge)
            }
            return
        }
        
        let vertix = viewModel.createVertix(on: coordinate)
        drawVertix(vertix)
        
        if let activeVertix = activeVertix {
            let edge = viewModel.createEdge(from: activeVertix, to: vertix)
            drawEdge(edge)
        } else {
            activeVertix = vertix
        }
    }
    
    private func drawVertix(_ vertix: MapVertix) {
        let annotation = VertixAnnotation(vertix: vertix)
        mapView.addAnnotation(annotation)
    }
    
    private func drawEdge(_ edge: MapEdge) {
        let line = MKPolyline(coordinates: edge.coordinates, count: edge.coordinates.count)
        mapView.addOverlay(line)
    }
    
    // MARK: - IBAction
    @IBAction func findPathTapped(_ sender: Any) {
        guard let from = startVertix, let to = endVertix else {
            if !isSelectingMode {
                mapView.selectedAnnotations.forEach { mapView.deselectAnnotation($0, animated: true) }
            }
            isSelectingMode = true
            return
        }
        mapView.removeAnnotations(mapView.annotations)
                mapView.removeOverlays(mapView.overlays)
        viewModel.bellmanFord(src: from, destination: to)
    
        vertixColor = .green
    }
    
    
    @IBAction func loadGraphTapped(_ sender: Any) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        viewModel.loadGraphFromFile()
    }
    
    @IBAction func saveGraphTapped(_ sender: Any) {
        viewModel.saveGraphToFile()
    }
}

// MARK: - ViewDelegate
extension ViewController: ViewDelegate {
    func didGetNewVertix(_ vertix: MapVertix) {
        drawVertix(vertix)
    }
    
    func didGetNewEdge(_ edge: MapEdge) {
        drawEdge(edge)
    }
}

// MARK: - UIGestureRecognizerDelegate
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

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            // настройка линии
            let polylineRender = MKPolylineRenderer(overlay: overlay)
            polylineRender.strokeColor = pathColor
            polylineRender.lineWidth = 5
            polylineRender.alpha = pathAplpha
            return polylineRender
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard
            let view = view as? CustomAnnotationView,
            let annotation = view.annotation as? VertixAnnotation else {
                return
        }
        activeVertix = annotation.vertix
        
        if isSelectingMode {
            if let _ = startVertix {
                endVertix = annotation.vertix
                view.color = endColor
            } else {
                startVertix = annotation.vertix
                view.color = startColor
            }
        }
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
