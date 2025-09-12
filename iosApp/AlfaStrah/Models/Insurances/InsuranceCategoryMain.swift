//
//  InsuranceCategoryMain.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 27/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct InsuranceCategoryMain: Entity {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    var title: String

    var description: String

    // sourcery: transformer.name = "type"
    var type: InsuranceCategoryMain.CategoryType
    
    // sourcery: transformer.name = "icon"
    var icon: String?
	
	// sourcery: transformer.name = "icon_themed"
	var iconThemed: ThemedValue?

    // sourcery: enumTransformer
    enum CategoryType: Int {
        // sourcery: defaultCase
        case unsupported = 0
        case auto = 1
        case health = 2
        case property = 3
        case travel = 4
        case passengers = 5
        case life = 6

        var title: String {
            switch self {
                case .unsupported:
                    return NSLocalizedString("common_unsopported_title", comment: "")
                case .auto:
                    return NSLocalizedString("auto_filter", comment: "")
                case .health:
                    return NSLocalizedString("health_filter", comment: "")
                case .life:
                    return NSLocalizedString("life_filter", comment: "")
                case .passengers:
                    return NSLocalizedString("pass_filter", comment: "")
                case .property:
                    return NSLocalizedString("place_filter", comment: "")
                case .travel:
                    return NSLocalizedString("travel_filter", comment: "")
            }
        }
    }
}
