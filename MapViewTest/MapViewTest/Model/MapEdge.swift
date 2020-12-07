//
//  MapEdge.swift
//  MapViewTest
//
//  Created by Кирилл Клименков on 12/5/20.
//  Copyright © 2020 Kirill Klimenkov. All rights reserved.
//

import Foundation
import CoreLocation

struct MapEdge {
    let startCoordinate: CLLocationCoordinate2D
    let endCoordinate: CLLocationCoordinate2D
    let weight: Double
    //    let color
    
    var coordinates: [CLLocationCoordinate2D] {
        return [startCoordinate, endCoordinate]
    }
}
