//
//  AppInfoWorker.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 11/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//
import Legacy

struct AppInfoService {
    static func applicationVersion() -> String {
        let version = DeviceInfo.main.bundleVersion
        let build = DeviceInfo.main.bundleBuild
        return "\(version) (\(build))"
    }

    static var applicationShortVersion: String {
        let bundleInfoDict = Bundle.main.infoDictionary
        let appShortVersion: String = bundleInfoDict?["CFBundleShortVersionString"] as? String ?? ""
        return appShortVersion
    }

    static var buildVersion: String {
        let bundleInfoDict = Bundle.main.infoDictionary
        let build = bundleInfoDict?["CFBundleVersion"] as? String ?? ""
        return build
    }

    static var isPushNotificationsAllowed: Bool {
        UIApplication.shared.isRegisteredForRemoteNotifications
    }

    static func systemVersion() -> String {
        UIDevice.current.systemVersion
    }

    static func systemName() -> String {
        UIDevice.current.systemName
    }

    static func systemFullName() -> String {
        systemName() + " " + systemVersion()
    }

    static func deviceModel() -> String {
        DeviceInfo.main.machineDisplayName
    }

    static func applicationName() -> String? {
        Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
    }
}
