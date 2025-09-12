//
//  CreatePassengersEventReport
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 04/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct CreatePassengersEventReport {
    // sourcery: transformer.name = "insurance_id"
    var insuranceId: String

    // sourcery: transformer.name = "risks"
    var riskValues: [RiskValue]
}
