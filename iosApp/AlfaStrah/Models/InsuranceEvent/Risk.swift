//
//  Risk
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 24/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct Risk: Equatable {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    var title: String

    // sourcery: transformer.name = "nomatch_id_list"
    // sourcery: transformer = ArrayTransformer(transformer: IdTransformer<Any>())
    var exclusiveIds: [String]

    // sourcery: transformer.name = "risk_category_list"
    var riskCategories: [RiskCategory]
}
