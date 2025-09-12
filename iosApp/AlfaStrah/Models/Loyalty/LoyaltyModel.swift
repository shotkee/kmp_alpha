//
//  LoyaltyModel.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 28/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct LoyaltyModel: Entity {
    // sourcery: transformer.name = "points_amount"
    var amount: Double
    // sourcery: transformer.name = points_added
    var added: Double
    // sourcery: transformer.name = "points_spent"
    var spent: Double
    var status: String
    // sourcery: transformer.name = "status_description"
    var statusDescription: String
    // sourcery: transformer.name = "next_status"
    var nextStatus: String?
    // sourcery: transformer.name = "next_status_money"
    var nextStatusMoney: Double
    // sourcery: transformer.name = "next_status_description"
    var nextStatusDescription: String
    // sourcery: transformer.name = "hotline_description"
    var hotlineDescription: String?
    // sourcery: transformer.name = "hotline_phone"
    var hotlinePhone: Phone?
    // sourcery: transformer.name = "last_operations"
    var lastOperations: [LoyaltyOperation]
    // sourcery: transformer.name = "insurance_deeplink_types"
    var insuranceDeeplinkTypes: [InsuranceDeeplinkType]
    // sourcery: transformer.name = operations_cnt
    var operationsCnt: Int

    static func loyaltyStatusInfo(_ loyaltyStatus: LoyaltyStatus) -> String? {
        switch loyaltyStatus {
            case .bronze:
                return NSLocalizedString("alfa_points_bronze_status_info", comment: "")
            case .silver:
                return NSLocalizedString(
                    "alfa_points_silver_status_info", comment: "")
            case .gold:
                return NSLocalizedString("alfa_points_gold_status_info", comment: "")
            case .undefined:
                return nil
        }
    }

    static func bonusAmountPercentage(_ loyaltyStatus: LoyaltyStatus) -> CGFloat? {
        switch loyaltyStatus {
            case .bronze:
                return 0
            case .silver:
                return 2
            case .gold:
                return 10
            case .undefined:
                return nil
        }
    }

    enum LoyaltyStatus: String {
        var text: String {
            switch self {
                case .bronze:
                    return NSLocalizedString("alfa_points_bronze_status", comment: "")
                case .silver:
                    return NSLocalizedString(
                        "alfa_points_silver_status", comment: "")
                case .gold:
                    return NSLocalizedString("alfa_points_gold_status", comment: "")
                case .undefined:
                    return ""
            }
        }

        case bronze = "bronze"
        case silver = "silver"
        case gold = "gold"
        case undefined = "undefined"
    }

    var timelineStatus: LoyaltyStatus {
        LoyaltyStatus(rawValue: status.lowercased()) ?? .undefined
    }

    var nextStatusAvailable: Bool {
        nextStatus != nil && nextStatus != ""
    }
}
