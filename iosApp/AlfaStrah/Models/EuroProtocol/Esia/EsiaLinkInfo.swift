//
//  EsiaLinkInfo
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 19.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct EsiaLinkInfo {
    // sourcery: transformer.name = "esia_url", transformer = "UrlTransformer<Any>()"
    var esiaUrl: URL

    // sourcery: transformer.name = "redirect_url", transformer = "UrlTransformer<Any>()"
    var redirectUrl: URL
}
