// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct DeviceInfoRequestOperatingSystemTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DeviceInfoRequest.OperatingSystem

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 1:
                return .success(.iOS)
            case 2:
                return .success(.android)
            default:
                return .success(.iOS)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .iOS:
                return transformer.transform(destination: 1)
            case .android:
                return transformer.transform(destination: 2)
        }
    }
}
