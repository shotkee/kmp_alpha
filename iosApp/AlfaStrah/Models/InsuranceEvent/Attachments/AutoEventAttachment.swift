//
//  AutoEventAttachment
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 14/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// Prepared to be send on server auto event attachment
struct AutoEventAttachment: Entity, Hashable {
    var id: String
    var eventReportId: String
    var filename: String
    var fileType: AttachmentPhotoType
    var isOptional: Bool
}
