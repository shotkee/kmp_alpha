//
//  Product.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 5/24/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

enum Product: Int, CaseIterable {
    case kasko = 1
    case travel = 2
    case remont = 3
    case kindNeighbours = 4
    case osago = 5
    case antiOnko = 6
    case kidsAndSport = 7
    case additionalDefence = 8

    var buttonName: String {
        switch self {
            case .kasko:
                return NSLocalizedString("auto_insurance", comment: "")
            case .travel:
                return NSLocalizedString("travel_insurance", comment: "")
            case .remont:
                return NSLocalizedString("remont_insurance", comment: "")
            case .kindNeighbours:
                return NSLocalizedString("kind_neighbours_insurance", comment: "")
            case .osago:
                return NSLocalizedString("auto_osago_insurance", comment: "")
            case .antiOnko:
                return NSLocalizedString("anti_onko_insurance", comment: "")
            case .kidsAndSport:
                return NSLocalizedString("kids_and_sport_insurance", comment: "")
            case .additionalDefence:
                return NSLocalizedString("additional_defence_insurance", comment: "")
        }
    }
}
