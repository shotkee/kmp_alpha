//
//  DeeplinkDestination.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 8/26/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: enumTransformer
enum DeeplinkDestination: Int, RawRepresentable {
    // sourcery: defaultCase
    case unsupported = 0
    case mainScreen = 1
    case alfaPoints = 2
    case insurancesList = 3
    case telemedecide = 5
    case kaskoProlongation = 7
    case externalUrl = 11
}

struct PushNotificationDeeplinkInfo {
    let destination: DeeplinkDestination
    let insuranceId: String?
    let url: URL?
    let isMassMailing: Bool?
}
