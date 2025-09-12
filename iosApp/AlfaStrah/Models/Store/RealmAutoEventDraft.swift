//
//  RealmAutoEventDraft
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 04/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmAutoEventDraft: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var insuranceId: String = ""
    @objc dynamic var fullDescription: String = ""
    @objc dynamic var lastModify: Date = Date()
    @objc dynamic var claimDate: Date?
    @objc dynamic var coordinate: RealmCoordinate?
	@objc dynamic var caseType: Int = -1
    let files: List<RealmAutoPhotoAttachmentDraft> = .init()

    override static func primaryKey() -> String? {
        "id"
    }
}
