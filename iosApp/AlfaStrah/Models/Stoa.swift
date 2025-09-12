//
// Stoa
// AlfaStrah
//
// Created by Eugene Egorov on 21 November 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

// sourcery: transformer
struct Stoa: Entity {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    var title: String

    var address: String?

    var coordinate: Coordinate

    // sourcery: transformer.name = "serviceHours"
    var serviceHours: String

    var dealer: String

    // sourcery: transformer.name = "phone_list"
    var phoneList: [Phone]
}
