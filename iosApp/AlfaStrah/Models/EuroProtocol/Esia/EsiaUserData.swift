//
//  EsiaUserData
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 21.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct EsiaUserData {
    // sourcery: transformer.name = "esia_refresh_token"
    var tokenScs: String

    // sourcery: transformer.name = "esia_access_token"
    var sdkAccessToken: String

    // sourcery: transformer.name = "person"
    var user: EsiaUser
}
