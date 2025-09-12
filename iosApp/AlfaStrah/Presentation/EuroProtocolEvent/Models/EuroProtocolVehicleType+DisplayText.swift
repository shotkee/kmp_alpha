//
//  EuroProtocolVehicleType+DisplayText.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 06.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

extension EuroProtocolVehicleType {
    var displayText: String {
        switch self {
            case .car:
                return NSLocalizedString("insurance_euro_protocol_vehicle_type_car", comment: "")
            case .truck:
                return NSLocalizedString("insurance_euro_protocol_vehicle_type_truck", comment: "")
            case .bike:
                return NSLocalizedString("insurance_euro_protocol_vehicle_type_bike", comment: "")
        }
    }
}
