//
//  EuroProtocolCircumstance.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

enum EuroProtocolCircumstance: RsaSdkConvertableType {
    case wasParked
    case movingOnParking
    case leavingParking
    case enteringParking
    case drivingWithoutManeuvering
    case passingCrossroad
    case enteringRoundabout
    case drivingOnRoundabout
    case hitVehicleInSameLane
    case hitVehicleInDifferentLane
    case changingLane
    case overtakingVehicle
    case turningRight
    case turningLeft
    case makingTurnaround
    case reversing
    case wheeledOncomingLane
    case otherVehicleWasOnMyLeft
    case ignoredPrioritySign
    case hitStandingVehicle
    case stoppedAtRedLight
    case other

    var sdkType: RSASDK.CircumstanceType {
        switch self {
            case .wasParked:
                return .wasParked
            case .movingOnParking:
                return .movingOnParking
            case .leavingParking:
                return .leavingParking
            case .enteringParking:
                return .enteringParking
            case .drivingWithoutManeuvering:
                return .drivingWithoutManeuvering
            case .passingCrossroad:
                return .passingCrossroad
            case .enteringRoundabout:
                return .enteringRoundabout
            case .drivingOnRoundabout:
                return .drivingOnRoundabout
            case .hitVehicleInSameLane:
                return .hitVehicleInSameLane
            case .hitVehicleInDifferentLane:
                return .hitVehicleInDifferentLane
            case .changingLane:
                return .changingLane
            case .overtakingVehicle:
                return .overtakingVehicle
            case .turningRight:
                return .turningRight
            case .turningLeft:
                return .turningLeft
            case .makingTurnaround:
                return .makingTurnaround
            case .reversing:
                return .reversing
            case .wheeledOncomingLane:
                return .wheeledOncomingLane
            case .otherVehicleWasOnMyLeft:
                return .otherVehicleWasOnMyLeft
            case .ignoredPrioritySign:
                return .ignoredPrioritySign
            case .hitStandingVehicle:
                return .hitStandingVehicle
            case .stoppedAtRedLight:
                return .stoppedAtRedLight
            case .other:
                return .other
        }
    }

    static func convert(from sdkType: RSASDK.CircumstanceType) -> EuroProtocolCircumstance {
        switch sdkType {
            case .wasParked:
                return .wasParked
            case .movingOnParking:
                return .movingOnParking
            case .leavingParking:
                return .leavingParking
            case .enteringParking:
                return .enteringParking
            case .drivingWithoutManeuvering:
                return .drivingWithoutManeuvering
            case .passingCrossroad:
                return .passingCrossroad
            case .enteringRoundabout:
                return .enteringRoundabout
            case .drivingOnRoundabout:
                return .drivingOnRoundabout
            case .hitVehicleInSameLane:
                return .hitVehicleInSameLane
            case .hitVehicleInDifferentLane:
                return .hitVehicleInDifferentLane
            case .changingLane:
                return .changingLane
            case .overtakingVehicle:
                return .overtakingVehicle
            case .turningRight:
                return .turningRight
            case .turningLeft:
                return .turningLeft
            case .makingTurnaround:
                return .makingTurnaround
            case .reversing:
                return .reversing
            case .wheeledOncomingLane:
                return .wheeledOncomingLane
            case .otherVehicleWasOnMyLeft:
                return .otherVehicleWasOnMyLeft
            case .ignoredPrioritySign:
                return .ignoredPrioritySign
            case .hitStandingVehicle:
                return .hitStandingVehicle
            case .stoppedAtRedLight:
                return .stoppedAtRedLight
            case .other:
                return .other
            @unknown default:
                fatalError("Unknown type")
        }
    }

    var description: String { sdkType.description }

    static var allCases: [EuroProtocolCircumstance] {
        RSASDK.CircumstanceType.allCases.map {
            EuroProtocolCircumstance.convert(from: $0)
        }
    }
}
