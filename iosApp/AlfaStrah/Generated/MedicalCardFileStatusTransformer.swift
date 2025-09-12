// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import Legacy

// swiftlint:disable all
struct MedicalCardFileStatusTransformer: Transformer {
    typealias Source = Any
    typealias Destination = MedicalCardFile.Status

    private let transformer = CastTransformer<Source, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let rawValue = transformer.transform(source: value).value else { return .failure(.transform) }

        switch rawValue {
            case "processing":
                return .success(.inProgress)
            case "success":
                return .success(.success)
            case "failure_type":
                return .success(.typeNotSupported)
            case "failure_common":
                return .success(.commonError)
            case "failure_antivirus":
                return .success(.antivirusError)
            default:
                return .failure(.transform)
        }
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        switch value {
            case .inProgress:
                return transformer.transform(destination: "processing")
            case .success:
                return transformer.transform(destination: "success")
            case .typeNotSupported:
                return transformer.transform(destination: "failure_type")
            case .commonError:
                return transformer.transform(destination: "failure_common")
            case .antivirusError:
                return transformer.transform(destination: "failure_antivirus")
        }
    }
}
