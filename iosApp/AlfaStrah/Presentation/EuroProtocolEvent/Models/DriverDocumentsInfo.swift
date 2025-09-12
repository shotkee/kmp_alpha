//
//  DriverDocumentsInfo.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 09.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

struct DriverDocumentsInfo {
    var driverLicense: SeriesAndNumberDocument?
    var startDateDriverLicense: Date?
    var endDateDriverLicense: Date?
    var address: String?
    var phone: String?
    var categoryDriverLicense: [EuroProtocolLicenseCategory]?

    var driverLicenseErrorText: String?
    var startDateDriverLicenseErrorText: String?
    var endDateDriverLicenseErrorText: String?
    var addressErrorText: String?
    var phoneErrorText: String?
    var categoryDriverLicenseErrorText: String?

    static let emptyData: Self = .init()
    static let mockData: Self = .init(
        driverLicense: .init(series: "Test", number: "Test"),
        startDateDriverLicense: Date(),
        endDateDriverLicense: Date(),
        address: "Test",
        phone: "Test",
        categoryDriverLicense: EuroProtocolLicenseCategory.allCases
    )

    init(
        driverLicense: SeriesAndNumberDocument? = nil,
        startDateDriverLicense: Date? = nil,
        endDateDriverLicense: Date? = nil,
        address: String? = nil,
        phone: String? = nil,
        categoryDriverLicense: [EuroProtocolLicenseCategory]? = nil
    ) {
        self.driverLicense = driverLicense
        self.startDateDriverLicense = startDateDriverLicense
        self.endDateDriverLicense = endDateDriverLicense
        self.address = address
        self.phone = phone
        self.categoryDriverLicense = categoryDriverLicense
    }

    init(esiaUser: EsiaUser?) {
        driverLicense = .init(
            series: esiaUser?.drivingLicense?.series ?? "",
            number: esiaUser?.drivingLicense?.number ?? ""
        )
        startDateDriverLicense = esiaUser?.drivingLicense?.issueDate
        endDateDriverLicense = esiaUser?.drivingLicense?.expiryDate
        address = esiaUser?.address
        phone = esiaUser?.mobile
    }

    init(participantInfo: EuroProtocolParticipantInfo) {
        driverLicense = {
            guard
                let series = participantInfo.license?.series,
                let number = participantInfo.license?.number
            else {
                return nil
            }
            return .init(series: series, number: number)
        }()

        startDateDriverLicense = participantInfo.license?.issueDate
        endDateDriverLicense = participantInfo.license?.expiryDate
        address = participantInfo.driver?.address
        phone = participantInfo.driver?.phone
        categoryDriverLicense = participantInfo.license?.category
    }

    var allPropertiesAreNotNull: Bool {
        guard
            driverLicense != nil,
            startDateDriverLicense != nil,
            endDateDriverLicense != nil,
            address != nil,
            phone != nil,
            categoryDriverLicense != nil
        else { return false }

        return true
    }

    var driverDocuments: DriverDocuments? {
        guard let driverLicense = driverLicense,
              let startDateDriverLicense = startDateDriverLicense,
              let endDateDriverLicense = endDateDriverLicense,
              let address = address,
              let phone = phone,
              let categoryDriverLicense = categoryDriverLicense
            else { return nil }

        return DriverDocuments(
            driverLicense: driverLicense,
            startDateDriverLicense: startDateDriverLicense,
            endDateDriverLicense: endDateDriverLicense,
            address: address,
            phone: phone,
            categoryDriverLicense: categoryDriverLicense
        )
    }
}

struct DriverDocuments {
    var driverLicense: SeriesAndNumberDocument
    var startDateDriverLicense: Date
    var endDateDriverLicense: Date
    var address: String
    var phone: String
    var categoryDriverLicense: [EuroProtocolLicenseCategory]
}
