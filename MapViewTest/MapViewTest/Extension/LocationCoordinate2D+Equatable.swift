//
//  LocationCoordinate2D+Equatable.swift
//  MapViewTest
//
//  Created by Кирилл Клименков on 12/5/20.
//  Copyright © 2020 Kirill Klimenkov. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
