//
//  DocumentsList
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 15/12/2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct DocumentsList {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    var documents: [String]

    // sourcery: transformer.name = "full_description"
    var fullDescription: String
}
