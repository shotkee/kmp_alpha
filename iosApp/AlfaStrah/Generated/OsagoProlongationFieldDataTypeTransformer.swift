// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct OsagoProlongationFieldDataTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OsagoProlongationField.DataType

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "string":
                return .success(.string)
            case "date":
                return .success(.date)
            case "geo":
                return .success(.geo)
            case "driver_license":
                return .success(.driverLicense)
            default:
                return .success(.string)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .string:
                return transformer.transform(destination: "string")
            case .date:
                return transformer.transform(destination: "date")
            case .geo:
                return transformer.transform(destination: "geo")
            case .driverLicense:
                return transformer.transform(destination: "driver_license")
        }
    }
}
