//
//  OSAGOCheckParticipants.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 13.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class OSAGOCheckParticipants {
    var participantA: OSAGOCheckParticipant?
    var participantB: OSAGOCheckParticipant?

    init(participantA: OSAGOCheckParticipant? = nil, participantB: OSAGOCheckParticipant? = nil) {
        self.participantA = participantA
        self.participantB = participantB
    }

    static let mockData: OSAGOCheckParticipants = .init(participantA: .mockData, participantB: .mockData)
    static let emptyData: OSAGOCheckParticipants = .init(participantA: nil, participantB: nil)

    var allPropertiesAreNotNull: Bool {
        guard
            participantA != nil,
            participantB != nil
        else { return false }

        return true
    }
}

struct OSAGOCheckParticipant {
    let policyInfo: OSAGOPolicyInfo
    let autoInfo: OSAGOAutoInfo

    static let mockData: Self = .init(policyInfo: .mockData, autoInfo: .mockData)
}

struct OSAGOPolicyInfo {
    let companyName: String
    let seriesAndNumber: SeriesAndNumberDocument
    let startDate: String?
    let endDate: String

    static let mockData: Self = .init(
        companyName: "Test",
        seriesAndNumber: .init(series: "test", number: "test"),
        startDate: "Test date",
        endDate: "Test date"
    )
}

struct OSAGOAutoInfo {
    var brand: String?
    var model: String?
    var vin: String?
    var licensePlate: String?

    static let mockData: Self = .init(brand: "Test", model: "Test", vin: "Test", licensePlate: "Test")
}
