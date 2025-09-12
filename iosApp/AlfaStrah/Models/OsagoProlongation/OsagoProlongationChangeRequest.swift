//
//  OsagoProlongationChangeRequest
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 12.03.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct OsagoProlongationChangeRequest {
    // sourcery: transformer.name = "insurance_id"
    var insuranceId: String

    // sourcery: transformer.name = "info_fields"
    var infoFields: [OsagoProlongationEditedField]
}
