//
//  CLLocation+distance.swift
//  MapViewTest
//
//  Created by Кирилл Клименков on 12/5/20.
//  Copyright © 2020 Kirill Klimenkov. All rights reserved.
//

import CoreLocation

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
