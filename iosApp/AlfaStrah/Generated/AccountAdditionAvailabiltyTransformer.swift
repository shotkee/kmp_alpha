// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct AccountAdditionAvailabiltyTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Account.AdditionAvailabilty

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "medicalfilestorage":
                return .success(.medicalFileStorage)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .medicalFileStorage:
                return transformer.transform(destination: "medicalfilestorage")
        }
    }
}
