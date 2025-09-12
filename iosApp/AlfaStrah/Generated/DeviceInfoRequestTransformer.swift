// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DeviceInfoRequestTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DeviceInfoRequest

    let deviceName = "device"
    let deviceModelName = "device_model"
    let operatingSystemName = "os"
    let osVersionName = "os_version"
    let appVersionName = "app_version"
    let deviceTokenName = "device_token"

    let deviceTransformer = CastTransformer<Any, String>()
    let deviceModelTransformer = CastTransformer<Any, String>()
    let operatingSystemTransformer = DeviceInfoRequestOperatingSystemTransformer()
    let osVersionTransformer = CastTransformer<Any, String>()
    let appVersionTransformer = CastTransformer<Any, String>()
    let deviceTokenTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let deviceResult = dictionary[deviceName].map(deviceTransformer.transform(source:)) ?? .failure(.requirement)
        let deviceModelResult = dictionary[deviceModelName].map(deviceModelTransformer.transform(source:)) ?? .failure(.requirement)
        let operatingSystemResult = dictionary[operatingSystemName].map(operatingSystemTransformer.transform(source:)) ?? .failure(.requirement)
        let osVersionResult = dictionary[osVersionName].map(osVersionTransformer.transform(source:)) ?? .failure(.requirement)
        let appVersionResult = dictionary[appVersionName].map(appVersionTransformer.transform(source:)) ?? .failure(.requirement)
        let deviceTokenResult = dictionary[deviceTokenName].map(deviceTokenTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        deviceResult.error.map { errors.append((deviceName, $0)) }
        deviceModelResult.error.map { errors.append((deviceModelName, $0)) }
        operatingSystemResult.error.map { errors.append((operatingSystemName, $0)) }
        osVersionResult.error.map { errors.append((osVersionName, $0)) }
        appVersionResult.error.map { errors.append((appVersionName, $0)) }
        deviceTokenResult.error.map { errors.append((deviceTokenName, $0)) }

        guard
            let device = deviceResult.value,
            let deviceModel = deviceModelResult.value,
            let operatingSystem = operatingSystemResult.value,
            let osVersion = osVersionResult.value,
            let appVersion = appVersionResult.value,
            let deviceToken = deviceTokenResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                device: device,
                deviceModel: deviceModel,
                operatingSystem: operatingSystem,
                osVersion: osVersion,
                appVersion: appVersion,
                deviceToken: deviceToken
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let deviceResult = deviceTransformer.transform(destination: value.device)
        let deviceModelResult = deviceModelTransformer.transform(destination: value.deviceModel)
        let operatingSystemResult = operatingSystemTransformer.transform(destination: value.operatingSystem)
        let osVersionResult = osVersionTransformer.transform(destination: value.osVersion)
        let appVersionResult = appVersionTransformer.transform(destination: value.appVersion)
        let deviceTokenResult = deviceTokenTransformer.transform(destination: value.deviceToken)

        var errors: [(String, TransformerError)] = []
        deviceResult.error.map { errors.append((deviceName, $0)) }
        deviceModelResult.error.map { errors.append((deviceModelName, $0)) }
        operatingSystemResult.error.map { errors.append((operatingSystemName, $0)) }
        osVersionResult.error.map { errors.append((osVersionName, $0)) }
        appVersionResult.error.map { errors.append((appVersionName, $0)) }
        deviceTokenResult.error.map { errors.append((deviceTokenName, $0)) }

        guard
            let device = deviceResult.value,
            let deviceModel = deviceModelResult.value,
            let operatingSystem = operatingSystemResult.value,
            let osVersion = osVersionResult.value,
            let appVersion = appVersionResult.value,
            let deviceToken = deviceTokenResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[deviceName] = device
        dictionary[deviceModelName] = deviceModel
        dictionary[operatingSystemName] = operatingSystem
        dictionary[osVersionName] = osVersion
        dictionary[appVersionName] = appVersion
        dictionary[deviceTokenName] = deviceToken
        return .success(dictionary)
    }
}
