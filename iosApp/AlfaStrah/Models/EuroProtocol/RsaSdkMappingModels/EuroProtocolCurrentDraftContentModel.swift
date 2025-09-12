//
//  EuroProtocolCurrentDraftContentModel.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

struct EuroProtocolCurrentDraftContentModel: AlfaFromRsaConvertableType {
    var role: EuroProtocolParticipant?
    var noticeInfo: EuroProtocolNoticeInfo
    var participantA: EuroProtocolParticipantInfo
    var participantB: EuroProtocolParticipantInfo
    var otherPhotos: [EuroProtocolPrivateImageType]

    var isEmpty: Bool {
        role == nil || noticeInfo.isEmpty || participantA.isEmpty || participantB.isEmpty || otherPhotos.isEmpty
    }

    static func convert(from sdkType: RSASDK.CurrentDraftContentModel) -> EuroProtocolCurrentDraftContentModel {
        EuroProtocolCurrentDraftContentModel(
            role: sdkType.role.map { EuroProtocolParticipant.convert(from: $0) },
            noticeInfo: EuroProtocolNoticeInfo.convert(from: sdkType.noticeInfo),
            participantA: EuroProtocolParticipantInfo.convert(from: sdkType.tsA),
            participantB: EuroProtocolParticipantInfo.convert(from: sdkType.tsB),
            otherPhotos: sdkType.otherPhotos.map { EuroProtocolPrivateImageType.convert(from: $0) }
        )
    }

    static let mockDraft = EuroProtocolCurrentDraftContentModel(
        role: .participantA,
        noticeInfo: EuroProtocolNoticeInfo(
            invitationCode: "123",
            orderID: "222",
            placePhotos: [ .freeImage(index: 1) ],
            place: "Пушкин, ул. Пушкина 1",
            latitude: "2343223",
            longitude: "23435243",
            date: Date(),
            scheme: .accidentScheme,
            disagreements: false
        ),
        participantA: EuroProtocolParticipantInfo(
            transport: EuroProtocolTransport(
                vechicleType: .car,
                brand: "VW",
                model: "Golf",
                vin: "hgf43532gfd",
                regmark: "a124aa132",
                photo: .policy(owner: .participantA),
                vehicleCertificate: EuroProtocolVehicleCertificate(series: "6666", number: "1234355")
            ),
            owner: EuroProtocolOwner.individual(
                firstName: "Иванов",
                lastName: "Иван",
                middleName: "Иванович",
                address: "Ленина 1"
            ),
            policy: EuroProtocolInsurancePolicy(
                series: "XXXX",
                number: "4353242",
                insurer: "Bruno",
                toDate: Date(),
                policyId: "232423",
                photo: nil
            ),
            license: EuroProtocolLicense(
                series: "6445",
                number: "7566457",
                category: [ .a, .b ],
                issueDate: Date(),
                expiryDate: Date()
            ),
            driver: EuroProtocolDriver(
                address: "Пушкина 55",
                phone: "+79214445566",
                document: "Passport"
            ),
            roadAccidents: EuroProtocolRoadAccidents(
                initialImpact: EuroProtocolInitialImpact(vechicleType: .car, sector: "3"),
                comments: nil,
                other: nil,
                circumstances: [ .changingLane ]
            ),
            damages: [ .damage(owner: .participantA, detail: .flDoorGlass) ],
            damageInsured: true
        ),
        participantB: EuroProtocolParticipantInfo(
            transport: EuroProtocolTransport(
                vechicleType: .car,
                brand: "VW",
                model: "Golf",
                vin: "hgf43532gfd",
                regmark: "a124aa132",
                photo: .policy(owner: .participantA),
                vehicleCertificate: EuroProtocolVehicleCertificate(series: "6666", number: "1234355")
            ),
            owner: EuroProtocolOwner.individual(
                firstName: "Иван",
                lastName: "Иванов",
                middleName: "Иванович",
                address: "Ленина 1"
            ),
            policy: EuroProtocolInsurancePolicy(
                series: "XXXX",
                number: "4353242",
                insurer: "Bruno",
                toDate: Date(),
                policyId: "232423",
                photo: nil
            ),
            license: EuroProtocolLicense(
                series: "6445",
                number: "7566457",
                category: [ .a, .b ],
                issueDate: Date(),
                expiryDate: Date()
            ),
            driver: EuroProtocolDriver(
                address: "Пушкина 55",
                phone: "+79214445566",
                document: "Passport"
            ),
            roadAccidents: EuroProtocolRoadAccidents(
                initialImpact: EuroProtocolInitialImpact(vechicleType: .bike, sector: "1"),
                comments: nil,
                other: nil,
                circumstances: [ .changingLane ]
            ),
            damages: [ .damage(owner: .participantA, detail: .flDoorGlass) ],
            damageInsured: true
        ),
        otherPhotos: [ .damage(owner: .participantA, detail: .capote) ]
    )
}
