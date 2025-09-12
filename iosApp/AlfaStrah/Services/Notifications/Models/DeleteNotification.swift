//
// DeleteNotification
// AlfaStrah
//
// Created by Eugene Egorov on 22 November 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

// sourcery: transformer
struct DeleteNotification {
    var id: String

    // sourcery: transformer.name = "is_deleted"
    var isDeleted: Bool
}
