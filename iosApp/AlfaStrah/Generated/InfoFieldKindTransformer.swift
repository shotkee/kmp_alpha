// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct InfoFieldKindTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InfoField.Kind

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 1:
                return .success(.text)
            case 2:
                return .success(.map)
            case 3:
                return .success(.link)
            case 4:
                return .success(.phone)
            case 5:
                return .success(.clinicsList)
            default:
                return .success(.text)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .text:
                return transformer.transform(destination: 1)
            case .map:
                return transformer.transform(destination: 2)
            case .link:
                return transformer.transform(destination: 3)
            case .phone:
                return transformer.transform(destination: 4)
            case .clinicsList:
                return transformer.transform(destination: 5)
        }
    }
}
