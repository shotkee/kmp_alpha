//
//  EuroProtocolRoadAccidents.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

struct EuroProtocolRoadAccidents: AlfaFromRsaConvertableType {
    var initialImpact: EuroProtocolInitialImpact?
    var comments: String?
    var other: String?
    var circumstances: [EuroProtocolCircumstance]

    var circumstancesValue: String {
        self.circumstances.map { "\($0.description)" }.joined(separator: ", ")
    }

    var isEmpty: Bool {
        initialImpact == nil || circumstances.isEmpty || comments == nil
    }

    static func convert(from sdkType: RSASDK.CurrentDraftContentModel.ParticipantInfo.RoadAccidents) -> EuroProtocolRoadAccidents {
        EuroProtocolRoadAccidents(
            initialImpact: sdkType.initialImpact.map { EuroProtocolInitialImpact.convert(from: $0) },
            comments: sdkType.comments,
            other: sdkType.other,
            circumstances: sdkType.circumstances.map { EuroProtocolCircumstance.convert(from: $0) }
        )
    }
}
