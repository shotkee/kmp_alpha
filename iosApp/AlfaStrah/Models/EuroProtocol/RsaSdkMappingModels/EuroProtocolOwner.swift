//
//  EuroProtocolOwner.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

enum EuroProtocolOwner: AlfaFromRsaConvertableType {
    case driver
    case individual(firstName: String, lastName: String, middleName: String?, address: String)
    case organization(name: String, address: String)
    case none

    static func convert(from sdkType: RSASDK.Owner) -> EuroProtocolOwner {
        if sdkType.isDriver {
            return .driver
        } else if let firstName = sdkType.firstname, let lastName = sdkType.surname, let address = sdkType.address {
            return .individual(firstName: firstName, lastName: lastName, middleName: sdkType.middleName, address: address)
        } else if let organizationName = sdkType.organizationName, let address = sdkType.address {
            return .organization(name: organizationName, address: address)
        } else {
            return .none
        }
    }

    var sdkType: RSASDK.Owner? {
        switch self {
            case .driver:
                return RSASDK.Owner.driverIsOwner
            case .individual(let firstName, let lastName, let middleName, let address):
                // TODO: Remove this guard statement
                guard let middleName = middleName else { return nil }
                return RSASDK.Owner(
                    surname: lastName,
                    firstname: firstName,
                    middleName: middleName,
                    address: address
                )
            case .organization(let name, let address):
                return RSASDK.Owner(
                    organizationName: name,
                    address: address
                )
            case .none:
                return nil
        }
    }

    var isEmpty: Bool {
        switch self {
            case .none:
                return true
            default:
                return false
        }
    }

    var isDriver: Bool {
        switch self {
            case .driver:
                return true
            default:
                return false
        }
    }
}
