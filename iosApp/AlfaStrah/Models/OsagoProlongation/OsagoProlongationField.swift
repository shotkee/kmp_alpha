//
//  OsagoProlongationField.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 18.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Legacy

// sourcery: transformer
struct OsagoProlongationField: Equatable {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String
    var title: String
    var value: String?

    // sourcery: transformer.name = "has_error"
    var hasError: Bool

    // sourcery: transformer.name = "data_type"
    var dataType: OsagoProlongationField.DataType?

    // sourcery: transformer.name = "data"
    var dataString: String?

    // sourcery: transformer.name = "data"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    var dataDate: Date?

    // sourcery: transformer.name = "data"
    var dataGeo: GeoPlace?

    // sourcery: transformer.name = "data"
    var dataDriverLicense: SeriesAndNumberDocument?

    // sourcery: enumTransformer
    enum DataType: String {
        // sourcery: defaultCase
        case string = "string"
        case date = "date"
        case geo = "geo"
        case driverLicense = "driver_license"
    }

    // MARK: Aditional logic

    var isBirthdayField: Bool {
        title == "Дата рождения"
    }

    var isDriverLicenseIssueDateField: Bool {
        title == "Дата выдачи ВУ"
    }

    var isReady: Bool {
        !hasError
    }

    var data: OsagoProlongationFieldData? {
        switch dataType {
            case .string?:
                return dataString.map { OsagoProlongationFieldData.string($0) }
            case .date?:
                return dataDate.map { OsagoProlongationFieldData.date($0) }
            case .geo?:
                return dataGeo.map { OsagoProlongationFieldData.geo($0) }
            case .driverLicense?:
                return dataDriverLicense.map { OsagoProlongationFieldData.driverLicense($0) }
            default:
                return nil
        }
    }

    mutating func setData(_ data: OsagoProlongationFieldData, hasError: Bool) {
        self.hasError = hasError
        switch data {
            case .string(let stringValue):
                value = stringValue
                dataString = stringValue
                dataType = .string
            case .date(let dateValue):
                value = AppLocale.dateString(dateValue)
                dataDate = dateValue
                dataType = .date
            case .geo(let geoValue):
                value = geoValue.description
                dataGeo = geoValue
                dataType = .geo
            case .driverLicense(let driverLicenseValue):
                value = driverLicenseValue.description
                dataDriverLicense = driverLicenseValue
                dataType = .driverLicense
        }
    }

    static func == (lhs: OsagoProlongationField, rhs: OsagoProlongationField) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title
    }
}
