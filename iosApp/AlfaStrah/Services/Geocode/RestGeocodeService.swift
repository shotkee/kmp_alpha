//
//  RestGeocodeService.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 25.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

class RestGeocodeService: GeocodeService {
    private let rest: FullRestClient
    private let geoLocationService: GeoLocationService

    init(rest: FullRestClient, geoLocationService: GeoLocationService) {
        self.rest = rest
        self.geoLocationService = geoLocationService
    }

    func geocode(_ location: GeoPlace, completion: @escaping (Result<Coordinate, AlfastrahError>) -> Void) {
        rest.create(
            path: "api/geo/place/geocode",
            id: nil,
            object: location,
            headers: [:],
            requestTransformer: SingleParameterTransformer(key: "geo_place", transformer: GeoPlaceTransformer()),
            responseTransformer: ResponseTransformer(key: "coordinate", transformer: CoordinateTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func reverseGeocode(location: Coordinate, completion: @escaping (Result<GeoPlace?, Error>) -> Void) {
        rest.create(
            path: "api/geo/place/reversegeocode",
            id: nil,
            object: location,
            headers: [:],
            requestTransformer: SingleParameterTransformer(key: "coordinate", transformer: CoordinateTransformer()),
            responseTransformer: ResponseTransformer(
                key: "geo_place_list",
                transformer: ArrayTransformer(transformer: GeoPlaceTransformer())
            ),
            completion: mapCompletion { result in
                switch result {
                    case .success(let places):
                        completion(.success(places.first))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        )
    }
	
    @discardableResult func searchLocation(
        locationName: String,
        flowType: String?,
        completion: @escaping (Result<[GeoPlace], AlfastrahError>) -> Void
    ) -> NetworkTask {
        let type: String
        if let flowType = flowType {
            type = flowType
        }
        else {
            type = "default"
        }
        
        let task = rest.create(
            path: "api/geo/place/search",
            id: nil,
            object: [
                "query": locationName,
                "flow_type": type
            ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: ResponseTransformer(
                key: "geo_place_list",
                transformer: ArrayTransformer(transformer: GeoPlaceTransformer())
            ),
            completion: mapCompletion(completion)
        )
		
		return task
    }
	
	func searchLocation(
		_ locationName: String,
		flowType: String?,
		completion: @escaping (Result<[GeoPlace], AlfastrahError>) -> Void
	) {
		searchLocation(locationName: locationName, flowType: flowType, completion: completion)
	}
	
	func searchLocationDictionaries(
		_ locationName: String,
		flowType: String?,
		completion: @escaping (Result<[[String: Any]], AlfastrahError>) -> Void
	) -> NetworkTask {
		let type: String
		if let flowType = flowType {
			type = flowType
		}
		else {
			type = "default"
		}
		
		return rest.create(
			path: "api/geo/place/search",
			id: nil,
			object: [
				"query": locationName,
				"flow_type": type
			],
			headers: [:],
			requestTransformer: DictionaryTransformer(
				keyTransformer: CastTransformer<AnyHashable, String>(),
				valueTransformer: CastTransformer<Any, String>()
			),
			responseTransformer: ResponseTransformer(
				key: "geo_place_list",
				transformer: ArrayTransformer(
					from: Any.self,
					transformer: DictionaryTransformer(
						from: Any.self,
						keyTransformer: CastTransformer<AnyHashable, String>(),
						valueTransformer: CastTransformer<Any, Any>()
					)
				)
			),
			completion: mapCompletion(completion)
		)
	}
}
