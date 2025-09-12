//
//  OSAGORenewViewModel.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 10.03.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class OSAGORenewViewModel {
    let originalInfo: OsagoProlongationEditInfo
    var editedInfo: OsagoProlongationEditInfo

    init(info: OsagoProlongationEditInfo) {
        originalInfo = info
        editedInfo = info
    }

    func originalField(for currentField: OsagoProlongationField) -> OsagoProlongationField? {
        let detailedInfo = originalInfo.participants.compactMap { $0.detailed }

        let fields = detailedInfo.flatMap { $0.fieldGroups }.flatMap { $0.fields }
        return fields.first { $0 == currentField }
    }

    func changeRequestModel(insuranceId: String) -> OsagoProlongationChangeRequest {
        let detailedInfo = editedInfo.participants.compactMap { $0.detailed }
        let fields = detailedInfo.flatMap { $0.fieldGroups }.flatMap { $0.fields }.filter { $0.data != nil }
        var editedField: [OsagoProlongationEditedField] = []
        for field in fields {
            if let data = field.data {
                editedField.append(.init(id: field.id, data: data))
            }
        }
        return OsagoProlongationChangeRequest(insuranceId: insuranceId, infoFields: editedField)
    }
}
