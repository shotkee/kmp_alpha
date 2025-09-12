// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct DoctorAppointmentInfoMessageMessageTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DoctorAppointmentInfoMessage.MessageType

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "screen":
                return .success(.screen)
            case "alert":
                return .success(.alert)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .screen:
                return transformer.transform(destination: "screen")
            case .alert:
                return transformer.transform(destination: "alert")
        }
    }
}
