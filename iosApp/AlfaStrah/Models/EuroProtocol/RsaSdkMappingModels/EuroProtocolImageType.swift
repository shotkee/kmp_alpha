//
//  EuroProtocolImageType.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

protocol EuroProtocolImageType {
    var sdkDocumentType: RSADocumentType { get }
}

enum EuroProtocolFreeImageType: EuroProtocolImageType, RsaSdkConvertableType {
    case freeImage(index: Int)

    var sdkType: RSASDK.FreeDocumentType {
        switch self {
            case .freeImage(let index):
                return .place(id: index)
        }
    }

    var sdkDocumentType: RSADocumentType {
        sdkType
    }

    static func convert(from sdkType: RSASDK.FreeDocumentType) -> EuroProtocolFreeImageType {
        switch sdkType {
            case .place(let index):
                return .freeImage(index: index)
            @unknown default:
                fatalError("Unknown type")
        }
    }
}

enum EuroProtocolPrivateImageType: EuroProtocolImageType, RsaSdkConvertableType {
    case accidentScheme
    case damage(owner: EuroProtocolParticipant, detail: EuroProtocolVehiclePart)
    case regMark(owner: EuroProtocolParticipant)
    case policy(owner: EuroProtocolParticipant)
    case witnessVehicle(type: EuroProtocolWitnessKind)
    case witnessVehiclePlate(type: EuroProtocolWitnessKind)
    case other(description: String)

    var sdkType: RSASDK.PrivateDocumentType {
        switch self {
            case .accidentScheme:
                return .accidentScheme
            case .damage(let owner, let detail):
                return .damage(owner: owner.sdkType, detail: detail.sdkType)
            case .regMark(let owner):
                return .regMark(owner: owner.sdkType)
            case .policy(let owner):
                return .policy(owner: owner.sdkType)
            case .witnessVehicle(let witness):
                return .witnessVehicle(type: witness.sdkType)
            case .witnessVehiclePlate(let witness):
                return .witnessVehiclePlate(type: witness.sdkType)
            case .other(let description):
                return .other(description: description)
        }
    }

    var sdkDocumentType: RSADocumentType {
        sdkType
    }

    static func convert(from sdkType: RSASDK.PrivateDocumentType) -> EuroProtocolPrivateImageType {
        switch sdkType {
            case .accidentScheme:
                return .accidentScheme
            case .damage(let owner, let detail):
                return .damage(owner: EuroProtocolParticipant.convert(from: owner), detail: EuroProtocolVehiclePart.convert(from: detail))
            case .regMark(let owner):
                return .regMark(owner: EuroProtocolParticipant.convert(from: owner))
            case .policy(let owner):
                return .policy(owner: EuroProtocolParticipant.convert(from: owner))
            case .witnessVehicle(let witness):
                return .witnessVehicle(type: EuroProtocolWitnessKind.convert(from: witness))
            case .witnessVehiclePlate(let witness):
                return .witnessVehiclePlate(type: EuroProtocolWitnessKind.convert(from: witness))
            case .other(let description):
                return .other(description: description)
            @unknown default:
                fatalError("Unknown type")
        }
    }
}

enum EuroProtocolPhotoAction: RsaSdkConvertableType {
    case add
    case remove

    var sdkType: RSASDK.DocumentActionType {
        switch self {
            case .add:
                return .add
            case .remove:
                return .remove
        }
    }

    static func convert(from sdkType: RSASDK.DocumentActionType) -> EuroProtocolPhotoAction {
        switch sdkType {
            case .add:
                return .add
            case .remove:
                return .remove
            @unknown default:
                fatalError("Unknown type")
        }
    }
}
