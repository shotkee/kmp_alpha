//
//  GeoPlace.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 28.01.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct GeoPlace: Equatable {
    let title: String
    let description: String
    // sourcery: transformer.name = "full_title"
    let fullTitle: String
    let country: String
    let region: String?
    let district: String?
    var city: String?
    var street: String?
    var house: String?
    var apartment: String?
	
	// sourcery: transformer.name = "fias_id"
	let fiasId: String?
	
	// sourcery: transformer.name = "fias_level"
	let fiasLevel: Int?
		
	// sourcery: transformer.name = "coordinate"
	let coordinate: Coordinate?

    var infoDescription: String {
        [city, street, house, apartment].compactMap { $0 }.joined(separator: ", ")
    }
}
