//
//  EuroProtocolLicense.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

// swiftlint:disable identifier_name

struct  EuroProtocolLicense: RsaSdkConvertableType {
    var series: String?
    var number: String?
    var category: [EuroProtocolLicenseCategory]
    var issueDate: Date?
    var expiryDate: Date?

    var isEmpty: Bool {
        series == nil || number == nil || category.isEmpty || issueDate == nil || expiryDate == nil
    }

    var licenseNumber: String {
        [ series, number ].compactMap { $0 }.joined(separator: " ")
    }

    var categoryValue: String {
        category.map { $0.title }.joined(separator: ", ")
    }

    var sdkType: RSASDK.License {
        RSASDK.License(
            series: series ?? "",
            number: number ?? "",
            categories: category.map { $0.sdkType },
            issueDate: issueDate ?? Date(),
            expiryDate: expiryDate ?? Date()
        )
    }

    static func convert(from sdkType: RSASDK.License) -> EuroProtocolLicense {
        EuroProtocolLicense(
            series: sdkType.series,
            number: sdkType.number,
            category: sdkType.category.map { EuroProtocolLicenseCategory.convert(from: $0) },
            issueDate: sdkType.issueDate,
            expiryDate: sdkType.expiryDate
        )
    }
}

enum EuroProtocolLicenseCategory: RsaSdkConvertableType, CaseIterable {
    case a
    case b
    case c
    case d
    case e

    var title: String {
        switch self {
            case .a:
                return "A"
            case .b:
                return "B"
            case .c:
                return "C"
            case .d:
                return "D"
            case .e:
                return "E"
        }
    }

    var longTitle: String {
        switch self {
            case .a:
                return NSLocalizedString("insurance_euro_protocol_driver_license_categoty_type_long_A", comment: "")
            case .b:
                return NSLocalizedString("insurance_euro_protocol_driver_license_categoty_type_long_B", comment: "")
            case .c:
                return NSLocalizedString("insurance_euro_protocol_driver_license_categoty_type_long_C", comment: "")
            case .d:
                return NSLocalizedString("insurance_euro_protocol_driver_license_categoty_type_long_D", comment: "")
            case .e:
                return NSLocalizedString("insurance_euro_protocol_driver_license_categoty_type_long_E", comment: "")
        }
    }

    var sdkType: RSASDK.LicenseCategory {
        switch self {
            case .a:
                return .A
            case .b:
                return .B
            case .c:
                return .C
            case .d:
                return .D
            case .e:
                return .E
        }
    }

    static func convert(from sdkType: RSASDK.LicenseCategory) -> EuroProtocolLicenseCategory {
        switch sdkType {
            case .A:
                return .a
            case .B:
                return .b
            case .C:
                return .c
            case .D:
                return .d
            case .E:
                return .e
            @unknown default:
                fatalError("Unknown type")
        }
    }
}
