//
//  BankInfoPayload
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 25.01.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct BankInfoPayload {
    var bik: String

    // sourcery: transformer.name = "account_number"
    var accountNumber: String
}
