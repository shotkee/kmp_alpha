//
//  GuaranteeLetter.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 07.04.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct GuaranteeLetter: Entity {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    // sourcery: transformer.name = "clinic_title"
    var clinicName: String

    // sourcery: transformer.name = "download_url", transformer = "UrlTransformer<Any>()"
    var downloadUrl: URL?

    // sourcery: transformer.name = "expiration_description"
    var expirationDateText: String?
    
    // sourcery: transformer.name = "issued_datetime"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)"
    var issueDateTimeUtc: Date

    var status: Status

    // sourcery: transformer.name = "status_text"
    var statusText: String?

    // sourcery: enumTransformer
    enum Status: Int, CaseIterable {
        // sourcery: defaultCase
        case inactive = 0
        case active = 1
    }

    var isActive: Bool {
        switch status {
            case .inactive:
                return false
            case .active:
                return true
        }
    }
}
