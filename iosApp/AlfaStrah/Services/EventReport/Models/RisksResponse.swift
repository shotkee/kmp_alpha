//
//  RisksResponse
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 24/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct RisksResponse {
    // sourcery: transformer.name = "risk_list"
    var risks: [Risk]

    // sourcery: transformer.name = "declarer_risk_category_list"
    var riskCategories: [RiskCategory]
}
