//
//  OfflineReverseGeocodeServiceDefault.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 26.02.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Foundation

enum Country: String {
    case russia = "Russia"
    case other = ""
}

class OfflineReverseGeocodeServiceDefault: OfflineReverseGeocodeService {
    private let reverseGeocoder: ReverseGeocodeCountry = .init()

    func getCountry(latitude: Double, longitude: Double) -> Country {
        let country = reverseGeocoder.getCountry(Float(latitude), Float(longitude)) ?? ""
        return Country(rawValue: country) ?? .other
    }
}
