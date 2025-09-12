// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct EndpointsTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Endpoints

    let medicalCardFileServerDomainStringName = "medicalfilestorage"
    let cascanaChatServiceDomainStringName = "cascana"
    let mainPagePathBDUIName = "bdui-mainpage"
    let productsPathBDUIName = "bdui-products"
    let profilePathBDUIName = "bdui-profile"
    let loyaltyPathBDUIName = "bdui-bonuses"
    let eventReportOsagoPathBDUIName = "bdui-eventreport-osago"

    let medicalCardFileServerDomainStringTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let cascanaChatServiceDomainStringTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let mainPagePathBDUITransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let productsPathBDUITransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let profilePathBDUITransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let loyaltyPathBDUITransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let eventReportOsagoPathBDUITransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let medicalCardFileServerDomainStringResult = medicalCardFileServerDomainStringTransformer.transform(source: dictionary[medicalCardFileServerDomainStringName])
        let cascanaChatServiceDomainStringResult = cascanaChatServiceDomainStringTransformer.transform(source: dictionary[cascanaChatServiceDomainStringName])
        let mainPagePathBDUIResult = mainPagePathBDUITransformer.transform(source: dictionary[mainPagePathBDUIName])
        let productsPathBDUIResult = productsPathBDUITransformer.transform(source: dictionary[productsPathBDUIName])
        let profilePathBDUIResult = profilePathBDUITransformer.transform(source: dictionary[profilePathBDUIName])
        let loyaltyPathBDUIResult = loyaltyPathBDUITransformer.transform(source: dictionary[loyaltyPathBDUIName])
        let eventReportOsagoPathBDUIResult = eventReportOsagoPathBDUITransformer.transform(source: dictionary[eventReportOsagoPathBDUIName])

        var errors: [(String, TransformerError)] = []
        medicalCardFileServerDomainStringResult.error.map { errors.append((medicalCardFileServerDomainStringName, $0)) }
        cascanaChatServiceDomainStringResult.error.map { errors.append((cascanaChatServiceDomainStringName, $0)) }
        mainPagePathBDUIResult.error.map { errors.append((mainPagePathBDUIName, $0)) }
        productsPathBDUIResult.error.map { errors.append((productsPathBDUIName, $0)) }
        profilePathBDUIResult.error.map { errors.append((profilePathBDUIName, $0)) }
        loyaltyPathBDUIResult.error.map { errors.append((loyaltyPathBDUIName, $0)) }
        eventReportOsagoPathBDUIResult.error.map { errors.append((eventReportOsagoPathBDUIName, $0)) }

        guard
            let medicalCardFileServerDomainString = medicalCardFileServerDomainStringResult.value,
            let cascanaChatServiceDomainString = cascanaChatServiceDomainStringResult.value,
            let mainPagePathBDUI = mainPagePathBDUIResult.value,
            let productsPathBDUI = productsPathBDUIResult.value,
            let profilePathBDUI = profilePathBDUIResult.value,
            let loyaltyPathBDUI = loyaltyPathBDUIResult.value,
            let eventReportOsagoPathBDUI = eventReportOsagoPathBDUIResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                medicalCardFileServerDomainString: medicalCardFileServerDomainString,
                cascanaChatServiceDomainString: cascanaChatServiceDomainString,
                mainPagePathBDUI: mainPagePathBDUI,
                productsPathBDUI: productsPathBDUI,
                profilePathBDUI: profilePathBDUI,
                loyaltyPathBDUI: loyaltyPathBDUI,
                eventReportOsagoPathBDUI: eventReportOsagoPathBDUI
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let medicalCardFileServerDomainStringResult = medicalCardFileServerDomainStringTransformer.transform(destination: value.medicalCardFileServerDomainString)
        let cascanaChatServiceDomainStringResult = cascanaChatServiceDomainStringTransformer.transform(destination: value.cascanaChatServiceDomainString)
        let mainPagePathBDUIResult = mainPagePathBDUITransformer.transform(destination: value.mainPagePathBDUI)
        let productsPathBDUIResult = productsPathBDUITransformer.transform(destination: value.productsPathBDUI)
        let profilePathBDUIResult = profilePathBDUITransformer.transform(destination: value.profilePathBDUI)
        let loyaltyPathBDUIResult = loyaltyPathBDUITransformer.transform(destination: value.loyaltyPathBDUI)
        let eventReportOsagoPathBDUIResult = eventReportOsagoPathBDUITransformer.transform(destination: value.eventReportOsagoPathBDUI)

        var errors: [(String, TransformerError)] = []
        medicalCardFileServerDomainStringResult.error.map { errors.append((medicalCardFileServerDomainStringName, $0)) }
        cascanaChatServiceDomainStringResult.error.map { errors.append((cascanaChatServiceDomainStringName, $0)) }
        mainPagePathBDUIResult.error.map { errors.append((mainPagePathBDUIName, $0)) }
        productsPathBDUIResult.error.map { errors.append((productsPathBDUIName, $0)) }
        profilePathBDUIResult.error.map { errors.append((profilePathBDUIName, $0)) }
        loyaltyPathBDUIResult.error.map { errors.append((loyaltyPathBDUIName, $0)) }
        eventReportOsagoPathBDUIResult.error.map { errors.append((eventReportOsagoPathBDUIName, $0)) }

        guard
            let medicalCardFileServerDomainString = medicalCardFileServerDomainStringResult.value,
            let cascanaChatServiceDomainString = cascanaChatServiceDomainStringResult.value,
            let mainPagePathBDUI = mainPagePathBDUIResult.value,
            let productsPathBDUI = productsPathBDUIResult.value,
            let profilePathBDUI = profilePathBDUIResult.value,
            let loyaltyPathBDUI = loyaltyPathBDUIResult.value,
            let eventReportOsagoPathBDUI = eventReportOsagoPathBDUIResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[medicalCardFileServerDomainStringName] = medicalCardFileServerDomainString
        dictionary[cascanaChatServiceDomainStringName] = cascanaChatServiceDomainString
        dictionary[mainPagePathBDUIName] = mainPagePathBDUI
        dictionary[productsPathBDUIName] = productsPathBDUI
        dictionary[profilePathBDUIName] = profilePathBDUI
        dictionary[loyaltyPathBDUIName] = loyaltyPathBDUI
        dictionary[eventReportOsagoPathBDUIName] = eventReportOsagoPathBDUI
        return .success(dictionary)
    }
}
