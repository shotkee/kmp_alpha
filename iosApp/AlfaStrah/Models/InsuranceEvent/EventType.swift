//
//  EventType
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 15/12/2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct EventType {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    var title: String

    // sourcery: transformer.name = "full_description"
    var fullDescription: String

    var info: [EventTypeInfo]?

    // sourcery: transformer.name = "documents_list"
    var documents: DocumentsList?

    // sourcery: transformer.name = "documents_list_optional"
    var optionalDocuments: DocumentsList?
}
