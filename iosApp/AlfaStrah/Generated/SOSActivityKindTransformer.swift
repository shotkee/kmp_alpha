// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct SOSActivityKindTransformer: Transformer {
    typealias Source = Any
    typealias Destination = SOSActivityKind

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.unsupported)
            case 1:
                return .success(.call)
            case 2:
                return .success(.callback)
            case 3:
                return .success(.autoInsuranceEvent)
            case 4:
                return .success(.doctorAppointment)
            case 5:
                return .success(.voipCall)
            case 6:
                return .success(.passengersInsuranceEvent)
            case 8:
                return .success(.onlinePayment)
            case 9:
                return .success(.vzrInsuranceEvent)
            case 10:
                return .success(.accidentInsuranceEvent)
            case 11:
                return .success(.passengersInsuranceWebEvent)
            case 12:
                return .success(.life)
            case 13:
                return .success(.interactiveSupport)
            case 14:
                return .success(.onWebsite)
            default:
                return .success(.unsupported)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .unsupported:
                return transformer.transform(destination: 0)
            case .call:
                return transformer.transform(destination: 1)
            case .callback:
                return transformer.transform(destination: 2)
            case .autoInsuranceEvent:
                return transformer.transform(destination: 3)
            case .doctorAppointment:
                return transformer.transform(destination: 4)
            case .voipCall:
                return transformer.transform(destination: 5)
            case .passengersInsuranceEvent:
                return transformer.transform(destination: 6)
            case .onlinePayment:
                return transformer.transform(destination: 8)
            case .vzrInsuranceEvent:
                return transformer.transform(destination: 9)
            case .accidentInsuranceEvent:
                return transformer.transform(destination: 10)
            case .passengersInsuranceWebEvent:
                return transformer.transform(destination: 11)
            case .life:
                return transformer.transform(destination: 12)
            case .interactiveSupport:
                return transformer.transform(destination: 13)
            case .onWebsite:
                return transformer.transform(destination: 14)
        }
    }
}
