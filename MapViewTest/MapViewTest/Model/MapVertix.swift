//
//  MapVertix.swift
//  MapViewTest
//
//  Created by Klimenkov, Kirill on 18.11.2020.
//  Copyright © 2020 Kirill Klimenkov. All rights reserved.
//

import Foundation
import CoreLocation

struct MapVertix: Codable, Equatable, CustomStringConvertible {
    // id: Int
    let number: Int
    var coordinate: CLLocationCoordinate2D
    // color: UIColor
    
    var description: String {
        return "\(number)"
    }
    
    static func == (lhs: MapVertix, rhs: MapVertix) -> Bool {
        return lhs.number == rhs.number
    }
}

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }
     
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let longitude = try container.decode(CLLocationDegrees.self)
        let latitude = try container.decode(CLLocationDegrees.self)
        self.init(latitude: latitude, longitude: longitude)
    }
} 
