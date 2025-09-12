// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct DeeplinkDestinationTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DeeplinkDestination

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.unsupported)
            case 1:
                return .success(.mainScreen)
            case 2:
                return .success(.alfaPoints)
            case 3:
                return .success(.insurancesList)
            case 5:
                return .success(.telemedecide)
            case 7:
                return .success(.kaskoProlongation)
            case 11:
                return .success(.externalUrl)
            default:
                return .success(.unsupported)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .unsupported:
                return transformer.transform(destination: 0)
            case .mainScreen:
                return transformer.transform(destination: 1)
            case .alfaPoints:
                return transformer.transform(destination: 2)
            case .insurancesList:
                return transformer.transform(destination: 3)
            case .telemedecide:
                return transformer.transform(destination: 5)
            case .kaskoProlongation:
                return transformer.transform(destination: 7)
            case .externalUrl:
                return transformer.transform(destination: 11)
        }
    }
}
