//
//  MobileDeviceTokenRequest.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 12.11.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct MobileDeviceTokenRequest {
    var device: String

    // sourcery: transformer.name = "device_model"
    var deviceModel: String

    // sourcery: transformer.name = "os"
    var operatingSystem: MobileDeviceTokenRequest.OperatingSystem

    // sourcery: transformer.name = "os_version"
    var osVersion: String

    // sourcery: transformer.name = "app_version"
    var appVersion: String

    // sourcery: enumTransformer
    enum OperatingSystem: Int {
        // sourcery: defaultCase
        case iOS = 1
        case android = 2
    }
}
