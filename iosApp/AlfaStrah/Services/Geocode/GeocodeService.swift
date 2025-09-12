//
//  DaDataService.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 25.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

protocol GeocodeService {
    func geocode(_ location: GeoPlace, completion: @escaping (Result<Coordinate, AlfastrahError>) -> Void)
    func reverseGeocode(location: Coordinate, completion: @escaping (Result<GeoPlace?, Error>) -> Void)
    func searchLocation(
		_ locationName: String,
		flowType: String?,
		completion: @escaping (Result<[GeoPlace], AlfastrahError>) -> Void
	)
	
	@discardableResult func searchLocation(
		locationName: String,
		flowType: String?,
		completion: @escaping (Result<[GeoPlace], AlfastrahError>) -> Void
	) -> NetworkTask
	
	func searchLocationDictionaries(
		_ locationName: String,
		flowType: String?,
		completion: @escaping (Result<[[String: Any]], AlfastrahError>) -> Void
	) -> NetworkTask
}
