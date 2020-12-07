//
//  VertixAnnotation.swift
//  MapViewTest
//
//  Created by Klimenkov, Kirill on 19.11.2020.
//  Copyright © 2020 Kirill Klimenkov. All rights reserved.
//

import Foundation
import MapKit

class VertixAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    let vertix: MapVertix
    
    init(vertix: MapVertix) {
        self.vertix = vertix
        coordinate = vertix.coordinate
        title = "\(vertix.number)"
    }
}
