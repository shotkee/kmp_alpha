//
//  EuroProtocolNoticeInfo.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

struct EuroProtocolNoticeInfo: AlfaFromRsaConvertableType {
    var invitationCode: String?
    var orderID: String?
    var placePhotos: [EuroProtocolFreeImageType]
    var place: String?
    var latitude: String?
    var longitude: String?
    var date: Date?
    var scheme: EuroProtocolPrivateImageType?
    var disagreements: Bool?

    var isEmpty: Bool {
        disagreements == nil || date == nil || scheme == nil || latitude == nil || longitude == nil
    }

    static func convert(from sdkType: RSASDK.CurrentDraftContentModel.NoticeInfo) -> EuroProtocolNoticeInfo {
        EuroProtocolNoticeInfo(
            invitationCode: sdkType.invitationCode,
            orderID: sdkType.orderID,
            placePhotos: sdkType.placePhotos.map { EuroProtocolFreeImageType.convert(from: $0) },
            place: sdkType.place,
            latitude: sdkType.latitude,
            longitude: sdkType.longitude,
            date: AppLocale.dateFromISO8601(sdkType.date),
            scheme: sdkType.scheme.map { EuroProtocolPrivateImageType.convert(from: $0) },
            disagreements: sdkType.disagreements
        )
    }
}
