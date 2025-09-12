// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct WeekdayTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Weekday

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "monday":
                return .success(.monday)
            case "tuesday":
                return .success(.tuesday)
            case "wednesday":
                return .success(.wednesday)
            case "thursday":
                return .success(.thursday)
            case "friday":
                return .success(.friday)
            case "saturday":
                return .success(.saturday)
            case "sunday":
                return .success(.sunday)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .monday:
                return transformer.transform(destination: "monday")
            case .tuesday:
                return transformer.transform(destination: "tuesday")
            case .wednesday:
                return transformer.transform(destination: "wednesday")
            case .thursday:
                return transformer.transform(destination: "thursday")
            case .friday:
                return transformer.transform(destination: "friday")
            case .saturday:
                return transformer.transform(destination: "saturday")
            case .sunday:
                return transformer.transform(destination: "sunday")
        }
    }
}
