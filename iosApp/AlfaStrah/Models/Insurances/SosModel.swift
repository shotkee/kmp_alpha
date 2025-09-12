//
//  SosModel.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 31/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct SosModel: Entity {
    // sourcery: transformer.name = "type"
    var kind: SosModel.SosModelKind
    // sourcery: transformer.name = "insurance_category"
    var insuranceCategory: InsuranceCategoryMain?
    // sourcery: transformer.name = "sos_phone"
    var sosPhone: SosPhone?
    // sourcery: transformer.name = "is_active"
    var isActive: Bool
    // sourcery: transformer.name = "is_health_flow"
    var isHealthFlow: Bool
    // sourcery: transformer.name = "insurance_count"
    var insuranceCount: Int
    // sourcery: transformer.name = "instruction_list"
    var instructionList: [Instruction]
    // sourcery: transformer.name = "sos_activity_list"
    var sosActivityList: [SosActivityModel]

    // sourcery: enumTransformer
    enum SosModelKind: Int {
        // sourcery: defaultCase
        case unsupported = 0
        case category = 1
        case phone = 2
    }

    var title: String? {
        switch kind {
            case .unsupported:
                return nil
            case .category:
                return insuranceCategory?.title
            case .phone:
                return NSLocalizedString("sos_phone_action_title", comment: "")
        }
    }

    var description: String? {
        switch kind {
            case .unsupported:
                return nil
            case .category:
                return insuranceCategory?.description
            case .phone:
                return sosPhone?.title
        }
    }

    var icon: UIImage? {
        switch kind {
            case .unsupported:
                return nil
            case .category:
                return (insuranceCategory?.type).flatMap(InsuranceHelper.image)
            case .phone:
                return UIImage(named: "icon-insurances-phone")
        }
    }

    var isSupported: Bool {
        kind != .unsupported
    }
}
