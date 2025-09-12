//
//  OsagoProlongationParticipant.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 18.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct OsagoProlongationParticipant: Equatable {
    var description: String
    var title: String
    var detailed: OsagoProlongationParticipantDetailed?

    // sourcery: transformer.name = "has_error"
    var hasError: Bool

    // sourcery: transformer.name = "error_text"
    var errorText: String?

    var isReady: Bool {
        guard let detailed = detailed else { return true }

        return detailed.fieldGroups.allSatisfy { $0.isReady }
    }

    var birthdayDate: Date? {
        guard let detailed = detailed else { return nil }

        let birthdayField = detailed.fieldGroups.flatMap { $0.fields }.first { $0.isBirthdayField }
        guard let stringDate = birthdayField?.value else { return nil }

        return AppLocale.date(from: stringDate)
    }

    static func == (lhs: OsagoProlongationParticipant, rhs: OsagoProlongationParticipant) -> Bool {
        lhs.description == rhs.description &&
        lhs.title == rhs.title &&
        lhs.errorText == rhs.errorText
    }
}
