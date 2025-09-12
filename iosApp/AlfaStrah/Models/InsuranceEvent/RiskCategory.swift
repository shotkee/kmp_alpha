//
//  RiskCategory
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 24/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct RiskCategory: Equatable {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    var title: String?

    // sourcery: transformer.name = "type"
    var kind: RiskCategory.RiskCategoryKind

    // sourcery: transformer.name = "dependence"
    var dependency: RiskDataDependency?

    // sourcery: transformer.name = "risk_data_list"
    var riskData: [RiskData]

    // sourcery: enumTransformer
    enum RiskCategoryKind: Int {
        // sourcery: defaultCase
        case normal = 0
        case expandable = 1
    }
}
