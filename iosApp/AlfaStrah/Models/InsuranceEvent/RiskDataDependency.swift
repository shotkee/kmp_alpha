//
//  RiskDataDependency
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 24/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct RiskDataDependency: Equatable {
    // sourcery: transformer = IdTransformer<Any>()
    // sourcery: transformer.name = "risk_data_id_checkbox"
    var checkboxId: String?

    // sourcery: transformer = IdTransformer<Any>()
    // sourcery: transformer.name = "risk_data_option_id"
    var optionId: String?
}
