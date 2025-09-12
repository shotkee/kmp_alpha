//
//  EuroProtocolVehicleDamagePosition.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 05.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

enum EuroProtocolVehicleDamagePosition {
    case car(position: EuroProtocolCarScheme)
    case truck(position: EuroProtocolTruckScheme)
    case bike(position: EuroProtocolBikeScheme)

    init?(scheme: EuroProtocolFirstBumpScheme) {
        if let position = scheme as? EuroProtocolCarScheme {
            self = .car(position: position)
        } else if let position = scheme as? EuroProtocolTruckScheme {
            self = .truck(position: position)
        } else if let position = scheme as? EuroProtocolBikeScheme {
            self = .bike(position: position)
        } else {
            return nil
        }
    }

    var bumpScheme: EuroProtocolFirstBumpScheme {
        switch self {
            case .car(let position):
                return position
            case .truck(let position):
                return position
            case .bike(let position):
                return position
        }
    }

    var filledCardText: String {
        let onePlaceText = NSLocalizedString("insurance_euro_protocol_car_damage_one_place_chosen", comment: "")
        let twoPlacesText = NSLocalizedString("insurance_euro_protocol_car_damage_two_places_chosen", comment: "")
        switch self {
            case .car(let position):
                return position.sdkFirstBumpType.value.contains("-")
                ? twoPlacesText : onePlaceText
            case .truck(let position):
                return position.sdkFirstBumpType.value.contains("-")
                ? twoPlacesText : onePlaceText
            case .bike:
                return onePlaceText
        }
    }
}
