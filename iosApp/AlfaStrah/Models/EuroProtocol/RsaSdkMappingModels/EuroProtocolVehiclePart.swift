//
//  EuroProtocolVehiclePart.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

enum EuroProtocolVehiclePart: RsaSdkConvertableType, Equatable, Comparable {
    case frontBumper
    case leftHeadlight
    case rightHeadlight
    case radiator
    case capote
    case flWing
    case frWing
    case flWheel
    case frWheel
    case rlWheel
    case rrWheel
    case windshield
    case flDoorGlass
    case frDoorGlass
    case flDoor
    case frDoor
    case lRearviewMirror
    case rRearviewMirror
    case roof
    case lThreshold
    case rThreshold
    case rlDoor
    case rrDoor
    case rlDoorGlass
    case rrDoorGlass
    case rlSidewallGlass
    case rrSidewallGlass
    case rearWindow
    case rlWing
    case rrWing
    case trunkLid
    case tailgate
    case rlLamp
    case rrLamp
    case rearBumper
    case driverAirbag
    case frontPassengerAirbag
    case sideLeftAirbag
    case sideRightAirbag
    case other(detailName: String, description: String? = nil)

    var sdkType: RSASDK.DetailType {
        switch self {
            case .frontBumper:
                return .frontBumper
            case .leftHeadlight:
                return .leftHeadlight
            case .rightHeadlight:
                return .rightHeadlight
            case .radiator:
                return .radiator
            case .capote:
                return .capote
            case .flWing:
                return .flWing
            case .frWing:
                return .frWing
            case .flWheel:
                return .flWheel
            case .frWheel:
                return .frWheel
            case .rlWheel:
                return .rlWheel
            case .rrWheel:
                return .rrWheel
            case .windshield:
                return .windshield
            case .flDoorGlass:
                return .flDoorGlass
            case .frDoorGlass:
                return .frDoorGlass
            case .flDoor:
                return .flDoor
            case .frDoor:
                return .frDoor
            case .lRearviewMirror:
                return .lRearviewMirror
            case .rRearviewMirror:
                return .rRearviewMirror
            case .roof:
                return .roof
            case .lThreshold:
                return .lThreshold
            case .rThreshold:
                return .rThreshold
            case .rlDoor:
                return .rlDoor
            case .rrDoor:
                return .rrDoor
            case .rlDoorGlass:
                return .rlDoorGlass
            case .rrDoorGlass:
                return .rrDoorGlass
            case .rlSidewallGlass:
                return .rlSidewallGlass
            case .rrSidewallGlass:
                return .rrSidewallGlass
            case .rearWindow:
                return .rearWindow
            case .rlWing:
                return .rlWing
            case .rrWing:
                return .rrWing
            case .trunkLid:
                return .trunkLid
            case .tailgate:
                return .tailgate
            case .rlLamp:
                return .rlLamp
            case .rrLamp:
                return .rrLamp
            case .rearBumper:
                return .rearBumper
            case .driverAirbag:
                return .driverAirbag
            case .frontPassengerAirbag:
                return .frontPassengerAirbag
            case .sideLeftAirbag:
                return .sideLeftAirbag
            case .sideRightAirbag:
                return .sideRightAirbag
            case .other(let name, let description):
                return .other(detailName: name, description: description)
        }
    }

    static func convert(from sdkType: RSASDK.DetailType) -> EuroProtocolVehiclePart {
        switch sdkType {
            case .frontBumper:
                return .frontBumper
            case .leftHeadlight:
                return .leftHeadlight
            case .rightHeadlight:
                return .rightHeadlight
            case .radiator:
                return .radiator
            case .capote:
                return .capote
            case .flWing:
                return .flWing
            case .frWing:
                return .frWing
            case .flWheel:
                return .flWheel
            case .frWheel:
                return .frWheel
            case .rlWheel:
                return .rlWheel
            case .rrWheel:
                return .rrWheel
            case .windshield:
                return .windshield
            case .flDoorGlass:
                return .flDoorGlass
            case .frDoorGlass:
                return .frDoorGlass
            case .flDoor:
                return .flDoor
            case .frDoor:
                return .frDoor
            case .lRearviewMirror:
                return .lRearviewMirror
            case .rRearviewMirror:
                return .rRearviewMirror
            case .roof:
                return .roof
            case .lThreshold:
                return .lThreshold
            case .rThreshold:
                return .rThreshold
            case .rlDoor:
                return .rlDoor
            case .rrDoor:
                return .rrDoor
            case .rlDoorGlass:
                return .rlDoorGlass
            case .rrDoorGlass:
                return .rrDoorGlass
            case .rlSidewallGlass:
                return .rlSidewallGlass
            case .rrSidewallGlass:
                return .rrSidewallGlass
            case .rearWindow:
                return .rearWindow
            case .rlWing:
                return .rlWing
            case .rrWing:
                return .rrWing
            case .trunkLid:
                return .trunkLid
            case .tailgate:
                return .tailgate
            case .rlLamp:
                return .rlLamp
            case .rrLamp:
                return .rrLamp
            case .rearBumper:
                return .rearBumper
            case .driverAirbag:
                return .driverAirbag
            case .frontPassengerAirbag:
                return .frontPassengerAirbag
            case .sideLeftAirbag:
                return .sideLeftAirbag
            case .sideRightAirbag:
                return .sideRightAirbag
            case .other(let name, let description):
                return .other(detailName: name, description: description)
            @unknown default:
                fatalError("Unknown type")
        }
    }

    static var allCarParts: [EuroProtocolVehiclePart] {
        RSASDK.DetailType.allDetails
            .filter {
                if case .other = $0 { return false }
                return true
            }
            .map { Self.convert(from: $0) }
    }

    var description: String {
        sdkType.description
    }

    static func < (lhs: EuroProtocolVehiclePart, rhs: EuroProtocolVehiclePart) -> Bool {
        guard
            let lhsIndex = allCarParts.firstIndex(of: lhs),
            let rhsIndex = allCarParts.firstIndex(of: rhs)
        else {
            return false
        }

        return lhsIndex < rhsIndex
    }
}
