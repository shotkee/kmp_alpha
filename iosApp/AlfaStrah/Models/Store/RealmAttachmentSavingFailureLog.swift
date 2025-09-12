//
//  RealmAttachmentSavingFailureLog.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 23.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

class RealmAttachmentSavingFailureLog: RealmEntity {
    @objc dynamic var message: String = ""

    override static func primaryKey() -> String? {
        "message"
    }
}
