//
//  JavisClinic.swift
//  AlfaStrah
//
//  Created by Vitaly Shkinev on 29.11.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct JavisClinic {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String
    var title: String
    var address: String
    var coordinate: Coordinate
    
    // sourcery: transformer.name = "service_hours"
    var serviceHours: String?
    
    // sourcery: transformer.name = "phone"
    var phone: Phone?
    
    // sourcery: transformer.name = "web_address", transformer = "UrlTransformer<Any>()"
    var webAddress: URL?
}

extension JavisClinic {
    init(id: String) {
        self.id = id
        title = ""
        address = ""
        coordinate = Coordinate(latitude: 0, longitude: 0)
        serviceHours = nil
        phone = nil
        webAddress = nil
    }
}
