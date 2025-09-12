//
//  Callback
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 20/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct Callback {
    let coordinate: Coordinate?
    let phone: String
    let message: String?
    let address: String?
    // sourcery: transformer.name = "insurance_id"
    // sourcery: transformer = IdTransformer<Any>()
    let insuranceId: String
}
