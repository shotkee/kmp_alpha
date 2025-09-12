//
//  OfflineReverseGeocodeService.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 26.02.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

protocol OfflineReverseGeocodeService {
    func getCountry(latitude: Double, longitude: Double) -> Country
}
