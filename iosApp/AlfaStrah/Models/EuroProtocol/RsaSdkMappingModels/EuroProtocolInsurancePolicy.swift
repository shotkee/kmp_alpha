//
//  EuroProtocolInsurancePolicy.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

struct EuroProtocolInsurancePolicy: AlfaFromRsaConvertableType {
    var series: String?
    var number: String?
    var insurer: String?
    var toDate: Date?
    var policyId: String?
    var photo: EuroProtocolPrivateImageType?
    var beginDate: String?

    var policyNumber: String {
        [ series, number ].compactMap { $0 }.joined(separator: " ")
    }

    var seriesAndNumber: SeriesAndNumberDocument? {
        guard let series = series, let number = number else {
            return nil
        }

        return SeriesAndNumberDocument(series: series, number: number)
    }

    var isEmpty: Bool {
        series == nil || number == nil || insurer == nil || toDate == nil || policyId == nil || photo == nil
    }

    static func convert(from sdkType: RSASDK.CurrentDraftContentModel.ParticipantInfo.InsurancePolicy) -> EuroProtocolInsurancePolicy {
        EuroProtocolInsurancePolicy(
            series: sdkType.series,
            number: sdkType.number,
            insurer: sdkType.insurer,
            toDate: sdkType.toDate,
            policyId: sdkType.policyId,
            photo: sdkType.photo.map { EuroProtocolPrivateImageType.convert(from: $0) },
            beginDate: sdkType.beginDate
        )
    }
}
