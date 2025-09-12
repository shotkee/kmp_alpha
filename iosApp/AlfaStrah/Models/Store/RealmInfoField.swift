//
//  RealmInfoField
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 13/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class RealmInfoField: RealmEntity {
    @objc dynamic var type: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var coordinate: RealmCoordinate?
}
