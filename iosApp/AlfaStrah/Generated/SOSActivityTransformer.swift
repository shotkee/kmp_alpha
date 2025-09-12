// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct SOSActivityTransformer: Transformer {
    typealias Source = Any
    typealias Destination = SOSActivity

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
                return .success(.reportInsuranceEvent)
            case 4:
                return .success(.doctorAppointment)
            case 5:
                return .success(.instruction)
            case 6:
                return .success(.voipCall)
            case 7:
                return .success(.freeCall)
            case 8:
                return .success(.reportOSAGOInsuranceEvent)
            case 9:
                return .success(.buyAgain)
            case 10:
                return .success(.buyNew)
            case 11:
                return .success(.reportPassengersInsuranceEvent)
            case 12:
                return .success(.reportVzrInsuranceEvent)
            case 13:
                return .success(.reportAccidentInsuranceEvent)
            case 14:
                return .success(.reportPassengersInsuranceWebEvent)
            case 15:
                return .success(.life)
            case 16:
                return .success(.interactiveSupport)
            case 17:
                return .success(.reportOnWebsite)
            case 100:
                return .success(.information)
            case 101:
                return .success(.receivePaymentOnline)
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
            case .reportInsuranceEvent:
                return transformer.transform(destination: 3)
            case .doctorAppointment:
                return transformer.transform(destination: 4)
            case .instruction:
                return transformer.transform(destination: 5)
            case .voipCall:
                return transformer.transform(destination: 6)
            case .freeCall:
                return transformer.transform(destination: 7)
            case .reportOSAGOInsuranceEvent:
                return transformer.transform(destination: 8)
            case .buyAgain:
                return transformer.transform(destination: 9)
            case .buyNew:
                return transformer.transform(destination: 10)
            case .reportPassengersInsuranceEvent:
                return transformer.transform(destination: 11)
            case .reportVzrInsuranceEvent:
                return transformer.transform(destination: 12)
            case .reportAccidentInsuranceEvent:
                return transformer.transform(destination: 13)
            case .reportPassengersInsuranceWebEvent:
                return transformer.transform(destination: 14)
            case .life:
                return transformer.transform(destination: 15)
            case .interactiveSupport:
                return transformer.transform(destination: 16)
            case .reportOnWebsite:
                return transformer.transform(destination: 17)
            case .information:
                return transformer.transform(destination: 100)
            case .receivePaymentOnline:
                return transformer.transform(destination: 101)
        }
    }
}
