//
//  PassengersEventDraft
//  AlfaStrah
//
//  Created by Eugene Ivanov on 29/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

struct PassengersEventDraft: Entity {
    var id: String
    var insuranceId: String
    var riskId: String
    var date: Date
    var values: [RiskValue]
}

// sourcery: transformer
struct RiskValue: Entity {
    // sourcery: transformer.name = "risk_id"
    var riskId: String
    // sourcery: transformer.name = "risk_category_id"
    var categoryId: String
    // sourcery: transformer.name = "risk_data_id"
    var dataId: String
    // sourcery: transformer.name = "risk_option_id"
    var optionId: String?
    var value: String
}
