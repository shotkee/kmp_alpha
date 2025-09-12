// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct SosEmergencyCommunicationTransformer: Transformer {
    typealias Source = Any
    typealias Destination = SosEmergencyCommunication

    let titleName = "title"
    let informationName = "information"
    let communicationBlockName = "emergency_connection_block"
    let confidantName = "confidant"
    let confidantBannerName = "confidant_banner"

    let titleTransformer = CastTransformer<Any, String>()
    let informationTransformer = OptionalTransformer(transformer: SosEmergencyConnectionScreenInformationTransformer())
    let communicationBlockTransformer = OptionalTransformer(transformer: SosEmergencyCommunicationBlockTransformer())
    let confidantTransformer = OptionalTransformer(transformer: ConfidantTransformer())
    let confidantBannerTransformer = OptionalTransformer(transformer: ConfidantBannerTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let informationResult = informationTransformer.transform(source: dictionary[informationName])
        let communicationBlockResult = communicationBlockTransformer.transform(source: dictionary[communicationBlockName])
        let confidantResult = confidantTransformer.transform(source: dictionary[confidantName])
        let confidantBannerResult = confidantBannerTransformer.transform(source: dictionary[confidantBannerName])

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        informationResult.error.map { errors.append((informationName, $0)) }
        communicationBlockResult.error.map { errors.append((communicationBlockName, $0)) }
        confidantResult.error.map { errors.append((confidantName, $0)) }
        confidantBannerResult.error.map { errors.append((confidantBannerName, $0)) }

        guard
            let title = titleResult.value,
            let information = informationResult.value,
            let communicationBlock = communicationBlockResult.value,
            let confidant = confidantResult.value,
            let confidantBanner = confidantBannerResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                information: information,
                communicationBlock: communicationBlock,
                confidant: confidant,
                confidantBanner: confidantBanner
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let informationResult = informationTransformer.transform(destination: value.information)
        let communicationBlockResult = communicationBlockTransformer.transform(destination: value.communicationBlock)
        let confidantResult = confidantTransformer.transform(destination: value.confidant)
        let confidantBannerResult = confidantBannerTransformer.transform(destination: value.confidantBanner)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        informationResult.error.map { errors.append((informationName, $0)) }
        communicationBlockResult.error.map { errors.append((communicationBlockName, $0)) }
        confidantResult.error.map { errors.append((confidantName, $0)) }
        confidantBannerResult.error.map { errors.append((confidantBannerName, $0)) }

        guard
            let title = titleResult.value,
            let information = informationResult.value,
            let communicationBlock = communicationBlockResult.value,
            let confidant = confidantResult.value,
            let confidantBanner = confidantBannerResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[informationName] = information
        dictionary[communicationBlockName] = communicationBlock
        dictionary[confidantName] = confidant
        dictionary[confidantBannerName] = confidantBanner
        return .success(dictionary)
    }
}
