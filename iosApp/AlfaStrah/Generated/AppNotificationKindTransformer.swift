// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct AppNotificationKindTransformer: Transformer {
    typealias Source = Any
    typealias Destination = AppNotification.Kind

    private let transformer = NumberTransformer<Source, Int>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case 0:
                return .success(.unsupported)
            case 1:
                return .success(.message)
            case 2:
                return .success(.fieldList)
            case 3:
                return .success(.offlineAppointment)
            case 4:
                return .success(.stoa)
            case 5:
                return .success(.kaskoLoadMorePhoto)
            case 6:
                return .success(.osagoRenew)
            case 7:
                return .success(.realtyRenew)
            case 8:
                return .success(.onlineAppointment)
            case 9:
                return .success(.telemedicineСonclusion)
            case 10:
                return .success(.telemedicineSoon)
            case 11:
                return .success(.telemedicineNewMessage)
            case 12:
                return .success(.telemedicineCall)
            case 13:
                return .success(.newsNotification)
            default:
                return .success(.unsupported)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .unsupported:
                return transformer.transform(destination: 0)
            case .message:
                return transformer.transform(destination: 1)
            case .fieldList:
                return transformer.transform(destination: 2)
            case .offlineAppointment:
                return transformer.transform(destination: 3)
            case .stoa:
                return transformer.transform(destination: 4)
            case .kaskoLoadMorePhoto:
                return transformer.transform(destination: 5)
            case .osagoRenew:
                return transformer.transform(destination: 6)
            case .realtyRenew:
                return transformer.transform(destination: 7)
            case .onlineAppointment:
                return transformer.transform(destination: 8)
            case .telemedicineСonclusion:
                return transformer.transform(destination: 9)
            case .telemedicineSoon:
                return transformer.transform(destination: 10)
            case .telemedicineNewMessage:
                return transformer.transform(destination: 11)
            case .telemedicineCall:
                return transformer.transform(destination: 12)
            case .newsNotification:
                return transformer.transform(destination: 13)
        }
    }
}
