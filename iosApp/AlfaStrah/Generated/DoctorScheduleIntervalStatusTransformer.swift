// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct DoctorScheduleIntervalStatusTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DoctorScheduleInterval.Status

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.unavailable)
            case 1:
                return .success(.available)
            default:
                return .success(.unavailable)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .unavailable:
                return transformer.transform(destination: 0)
            case .available:
                return transformer.transform(destination: 1)
        }
    }
}
