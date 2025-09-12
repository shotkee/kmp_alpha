//
//  Coordinate
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 03/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import CoreLocation

// sourcery: transformer
struct Coordinate: Entity, Equatable, Codable {
    var latitude: Double
    var longitude: Double

    static func == (left: Coordinate, right: Coordinate) -> Bool {
        Coordinate.areEqual(left, right)
    }

    static func areEqual(_ left: Coordinate, _ right: Coordinate, epsilon: Double = 0.000001) -> Bool {
        abs(left.latitude - right.latitude) < epsilon && abs(left.longitude - right.longitude) < epsilon
    }

    var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Returns geographical distance (measured in meters) between two coordinates (that follows the curvature of the Earth).
    static func distance(from this: Coordinate, to that: Coordinate) -> CLLocationDistance {
        this.clLocation.distance(from: that.clLocation)
    }
}
