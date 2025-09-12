//
//  MetroCity.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 20/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

// sourcery: transformer
struct CityWithMetro {
    // sourcery: transformer = IdTransformer<Any>()
    let id: String
    let title: String

    let latitude: Double
    let longitude: Double
    let radius: Double

    var coordinate: Coordinate {
        Coordinate(latitude: latitude, longitude: longitude)
    }
}
