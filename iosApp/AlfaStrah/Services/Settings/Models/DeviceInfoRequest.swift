//
//  DeviceInfoRequest.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 6/5/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct DeviceInfoRequest {
    var device: String

    // sourcery: transformer.name = "device_model"
    var deviceModel: String

    // sourcery: transformer.name = "os"
    var operatingSystem: DeviceInfoRequest.OperatingSystem

    // sourcery: transformer.name = "os_version"
    var osVersion: String

    // sourcery: transformer.name = "app_version"
    var appVersion: String

    // sourcery: transformer.name = "device_token"
    var deviceToken: String

    // sourcery: enumTransformer
    enum OperatingSystem: Int {
        // sourcery: defaultCase
        case iOS = 1
        case android = 2
    }
}
