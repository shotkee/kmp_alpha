//
// RealmPhone
// AlfaStrah
//
// Created by Eugene Egorov on 05 February 2019.
// Copyright (c) 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmPhone: RealmEntity, RealmOptionalType {
    @objc dynamic var plain: String = ""
    @objc dynamic var humanReadable: String = ""
    @objc dynamic var voipCall: RealmVoipCall?
}
