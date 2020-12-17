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

    private struct Constants {
        static let doneButton = "Done"
        static let closeButton = "Close"
    }
    
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var fromVertixTextField: UITextField!
    @IBOutlet private weak var toVertixTextField: UITextField!
    
    private var lpgr: UILongPressGestureRecognizer!
    private var selectedTextFiled: UITextField?
    private let picker = UIPickerView()
    private var toolBar = UIToolbar()
    private var viewModel = ViewModel()
    
    private var activeVertix: MapVertix?
    private var existingVertix: MapVertix?
    
    var pathColor: UIColor = .red
    var pathAplpha: CGFloat = 1
    
    var vertixColor = UIColor.blue
    
    var selectedAnnotations: [MapVertix] = []
    
    private var startVertix: MapVertix?
    private var endVertix: MapVertix?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapview()
        setupView()
        fromVertixTextField.tag = 1337
        toVertixTextField.tag = 999
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
    
    private func setupView() {
        fromVertixTextField.delegate = self
        toVertixTextField.delegate = self
        picker.delegate = self
        picker.dataSource = self
        setupToolBar()
        setPickerView(for: fromVertixTextField)
        setPickerView(for: toVertixTextField)
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
    
    private func setPickerView(for textField: UITextField) {
        textField.inputView = picker
        textField.inputAccessoryView = toolBar
    }
    
    private func setupToolBar() {
        toolBar.barStyle = .default
        toolBar.tintColor = .systemBlue
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: Constants.doneButton,
                                         style: .done,
                                         target: self,
                                         action: #selector(self.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let closeButton = UIBarButtonItem(title: Constants.closeButton,
                                         style: .done,
                                         target: self,
                                         action: #selector(self.closePicker))
        toolBar.setItems([closeButton, spaceButton, doneButton], animated: true)
    }
    
    @objc private func donePicker() {
        let selectedIndex = picker.selectedRow(inComponent: 0)
        let title = pickerView(self.picker, titleForRow: selectedIndex, forComponent: 0)

        if selectedTextFiled?.tag == 1337 {
            startVertix = viewModel.vertix(by: selectedIndex)
        } else if selectedTextFiled?.tag == 999 {
            endVertix = viewModel.vertix(by: selectedIndex)
        }
        selectedTextFiled?.text = title
        selectedTextFiled?.resignFirstResponder()
    }
    
    @objc private func closePicker() {
        selectedTextFiled?.resignFirstResponder()
    }
    
    // MARK: - IBAction
    @IBAction func findPathTapped(_ sender: Any) {
        guard let from = startVertix, let to = endVertix else {
            return
        }
//        mapView.selectedAnnotations.forEach { mapView.deselectAnnotation($0, animated: true) }
//        mapView.removeAnnotations(mapView.annotations)
//        mapView.removeOverlays(mapView.overlays)
        
        print("from: \(from)")
        print("to: \(to)")
        
        viewModel.bellmanFord(src: from, destination: to)
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
    func didChangeEdgeColor(_ color: UIColor) {
        pathColor = color
    }
    
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

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.vertixCount
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.title(of: row)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        picker.reloadAllComponents()
        selectedTextFiled = textField
        return true
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
