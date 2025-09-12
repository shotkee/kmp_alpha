//
//  RealmInfoFieldGroup
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 13/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmInfoFieldGroup: RealmEntity {
    @objc dynamic var title: String = ""
    let fields: List<RealmInfoField> = .init()
}
