//
//  InsuranceCategory
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 10/12/2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

// sourcery: transformer
@objc class InsuranceCategory: NSObject, Entity {
    // sourcery: transformer = IdTransformer<Any>()
    @objc var id: String

    @objc var title: String

    // sourcery: transformer.name = "terms_url", transformer = "UrlTransformer<Any>()"
    var termsURL: URL?

    // sourcery: transformer.name = "sort_priority"
    var sortPriority: Int

    // sourcery: transformer.name = "days_left"
    var daysLeft: Int

    // sourcery: transformer.name = "product_id_list"
    @objc var productIds: [String]

    // sourcery: transformer.name = "type"
    @objc var kind: InsuranceCategory.CategoryKind

    @objc var subtitle: String

    // sourcery: enumTransformer
    @objc enum CategoryKind: Int {
        // sourcery: defaultCase
        case none = 0
        case auto = 1
        case health = 2
        case property = 3
        case travel = 4
        case passengers = 5
        case life = 6
    }

    init(id: String, title: String, termsURL: URL?, sortPriority: Int, daysLeft: Int, productIds: [String],
        kind: CategoryKind, subtitle: String
    ) {
        self.id = id
        self.title = title
        self.termsURL = termsURL
        self.sortPriority = sortPriority
        self.daysLeft = daysLeft
        self.productIds = productIds
        self.kind = kind
        self.subtitle = subtitle

        super.init()
    }
}
