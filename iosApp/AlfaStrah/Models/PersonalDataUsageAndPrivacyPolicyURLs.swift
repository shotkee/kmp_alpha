//
//  PersonalDataUsageAndPrivacyPolicyURLs.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 10.11.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct PersonalDataUsageAndPrivacyPolicyURLs {
    // sourcery: transformer.name = "pd_agreement", transformer = "UrlTransformer<Any>()"
    var personalDataUsageUrl: URL

    // sourcery: transformer.name = "pd_policy", transformer = "UrlTransformer<Any>()"
    var privacyPolicyUrl: URL
    
    // sourcery: transformer.name = "ymaps_agreement", transformer = "UrlTransformer<Any>()"
    var yandexMapsPolicyUrl: URL
}
