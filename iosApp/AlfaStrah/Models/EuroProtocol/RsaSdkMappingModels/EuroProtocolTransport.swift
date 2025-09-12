//
//  EuroProtocolTransport.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

struct EuroProtocolTransport: AlfaFromRsaConvertableType {
    var vechicleType: EuroProtocolVehicleType?
    var brand: String?
    var model: String?
    var vin: String?
    var regmark: String?
    var photo: EuroProtocolPrivateImageType?
    var vehicleCertificate: EuroProtocolVehicleCertificate?

    var isEmpty: Bool {
        vechicleType == nil || brand == nil || model == nil || vin == nil || regmark == nil ||
            photo == nil || (vehicleCertificate?.isEmpty ?? true)
    }

    static func convert(from sdkType: RSASDK.CurrentDraftContentModel.ParticipantInfo.Transport) -> EuroProtocolTransport {
        EuroProtocolTransport(
            vechicleType: sdkType.typeTS.map { EuroProtocolVehicleType.convert(from: $0) },
            brand: sdkType.brand,
            model: sdkType.model,
            vin: sdkType.vin,
            regmark: sdkType.regmark,
            photo: sdkType.photo.map { EuroProtocolPrivateImageType.convert(from: $0) },
            vehicleCertificate: sdkType.vehicleCertificate.map { EuroProtocolVehicleCertificate.convert(from: $0) }
        )
    }
}
