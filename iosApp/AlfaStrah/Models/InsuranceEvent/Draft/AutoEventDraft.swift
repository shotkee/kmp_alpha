//
//  AutoEventDraft
//  AlfaStrah
//
//  Created by Eugene Ivanov on 29/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

struct AutoEventDraft: Entity {
    var id: String
    var insuranceId: String
    var claimDate: Date?
    var fullDescription: String
    var files: [AutoPhotoAttachmentDraft]
    var coordinate: Coordinate?
    var lastModify: Date
	var caseType: AutoEventCaseType?
}
