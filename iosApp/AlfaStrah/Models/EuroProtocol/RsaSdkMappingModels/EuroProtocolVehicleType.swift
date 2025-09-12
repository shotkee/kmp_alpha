//
//  EuroProtocolVechicleType.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

enum EuroProtocolVehicleType: AlfaFromRsaConvertableType, CaseIterable {
    case car
    case truck
    case bike

    var title: String {
        switch self {
            case .car:
                return NSLocalizedString("insurance_euro_protocol_vehicle_type_car", comment: "")
            case .truck:
                return NSLocalizedString("insurance_euro_protocol_vehicle_type_truck", comment: "")
            case .bike:
                return NSLocalizedString("insurance_euro_protocol_vehicle_type_bike", comment: "")
        }
    }

    static func convert(from sdkType: RSASDK.VechicleType) -> EuroProtocolVehicleType {
        switch sdkType {
            case .car:
                return .car
            case .truck:
                return .truck
            case .bike:
                return .bike
            @unknown default:
                fatalError("Unknown type")
        }
    }

    var bumpSchemeType: EuroProtocolFirstBumpScheme.Type {
        switch self {
            case .car:
                return EuroProtocolCarScheme.self
            case .truck:
                return EuroProtocolTruckScheme.self
            case .bike:
                return EuroProtocolBikeScheme.self
        }
    }
}
