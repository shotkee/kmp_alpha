// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct InsuranceShortKindTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceShort.Kind

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.unsupported)
            case 1:
                return .success(.kasko)
            case 2:
                return .success(.osago)
            case 3:
                return .success(.dms)
            case 4:
                return .success(.vzr)
            case 5:
                return .success(.property)
            case 6:
                return .success(.passengers)
            case 7:
                return .success(.life)
            case 8:
                return .success(.accident)
            case 9:
                return .success(.kaskoOnOff)
            case 10:
                return .success(.vzrOnOff)
            case 11:
                return .success(.flatOnOff)
            default:
                return .success(.unsupported)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .unsupported:
                return transformer.transform(destination: 0)
            case .kasko:
                return transformer.transform(destination: 1)
            case .osago:
                return transformer.transform(destination: 2)
            case .dms:
                return transformer.transform(destination: 3)
            case .vzr:
                return transformer.transform(destination: 4)
            case .property:
                return transformer.transform(destination: 5)
            case .passengers:
                return transformer.transform(destination: 6)
            case .life:
                return transformer.transform(destination: 7)
            case .accident:
                return transformer.transform(destination: 8)
            case .kaskoOnOff:
                return transformer.transform(destination: 9)
            case .vzrOnOff:
                return transformer.transform(destination: 10)
            case .flatOnOff:
                return transformer.transform(destination: 11)
        }
    }
}
