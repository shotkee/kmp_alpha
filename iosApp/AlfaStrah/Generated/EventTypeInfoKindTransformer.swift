// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct EventTypeInfoKindTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EventTypeInfo.Kind

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 1:
                return .success(.string)
            case 2:
                return .success(.list)
            case 3:
                return .success(.date)
            case 4:
                return .success(.header)
            case 5:
                return .success(.stringList)
            default:
                return .success(.string)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .string:
                return transformer.transform(destination: 1)
            case .list:
                return transformer.transform(destination: 2)
            case .date:
                return transformer.transform(destination: 3)
            case .header:
                return transformer.transform(destination: 4)
            case .stringList:
                return transformer.transform(destination: 5)
        }
    }
}
