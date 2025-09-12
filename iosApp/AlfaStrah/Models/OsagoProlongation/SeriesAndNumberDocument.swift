//
//  DriverLicense.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 18.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct SeriesAndNumberDocument: Equatable {
    // sourcery: transformer.name = "seria"
    var series: String
    var number: String

    var description: String {
        if series.isEmpty && number.isEmpty {
            return ""
        } else {
            return [ series, number ].compactMap { $0 }.joined(separator: " ")
        }
    }
}
