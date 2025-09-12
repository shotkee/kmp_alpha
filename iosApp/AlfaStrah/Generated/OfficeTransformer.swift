// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OfficeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Office

    let idName = "id"
    let addressName = "address"
    let coordinateName = "coordinate"
    let phonesName = "phones"
    let serviceHoursName = "service_hours"
    let servicesName = "services"
    let cityIdName = "city_id"
    let campaignsName = "campaigns"
    let cardPaymentAvailableName = "card_pay"
    let purchaseActiveName = "make_selling"
    let damageClaimAvailableName = "make_damage_claim"
    let osagoClaimAvailableName = "make_osago_claim"
    let telematicsInstallAvailableName = "make_telematics_install"
    let damageClaimTextName = "damage_claim_text"
    let osagoClaimTextName = "osago_claim_text"
    let advertTextName = "advert_text"
    let additionalContactsName = "additional_contacts"
    let specialConditionsName = "special_conditions"
    let metroName = "metro"
    let distanceName = "distance"
    let timetableName = "timetable"
    let specialTimetableName = "special_timetable"

    let idTransformer = IdTransformer<Any>()
    let addressTransformer = CastTransformer<Any, String>()
    let coordinateTransformer = CoordinateTransformer()
    let phonesTransformer = ArrayTransformer(from: Any.self, transformer: PhoneTransformer(), skipFailures: true)
    let serviceHoursTransformer = CastTransformer<Any, String>()
    let servicesTransformer = ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true)
    let cityIdTransformer = CastTransformer<Any, String>()
    let campaignsTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let cardPaymentAvailableTransformer = NumberTransformer<Any, Bool>()
    let purchaseActiveTransformer = NumberTransformer<Any, Bool>()
    let damageClaimAvailableTransformer = NumberTransformer<Any, Bool>()
    let osagoClaimAvailableTransformer = NumberTransformer<Any, Bool>()
    let telematicsInstallAvailableTransformer = NumberTransformer<Any, Bool>()
    let damageClaimTextTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let osagoClaimTextTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let advertTextTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let additionalContactsTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let specialConditionsTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let metroTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true))
    let distanceTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Double>())
    let timetableTransformer = ArrayTransformer(from: Any.self, transformer: OfficeTimetableTransformer(), skipFailures: true)
    let specialTimetableTransformer = ArrayTransformer(from: Any.self, transformer: OfficeSpecialTimetableTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let addressResult = dictionary[addressName].map(addressTransformer.transform(source:)) ?? .failure(.requirement)
        let coordinateResult = dictionary[coordinateName].map(coordinateTransformer.transform(source:)) ?? .failure(.requirement)
        let phonesResult = dictionary[phonesName].map(phonesTransformer.transform(source:)) ?? .failure(.requirement)
        let serviceHoursResult = dictionary[serviceHoursName].map(serviceHoursTransformer.transform(source:)) ?? .failure(.requirement)
        let servicesResult = dictionary[servicesName].map(servicesTransformer.transform(source:)) ?? .failure(.requirement)
        let cityIdResult = dictionary[cityIdName].map(cityIdTransformer.transform(source:)) ?? .failure(.requirement)
        let campaignsResult = campaignsTransformer.transform(source: dictionary[campaignsName])
        let cardPaymentAvailableResult = dictionary[cardPaymentAvailableName].map(cardPaymentAvailableTransformer.transform(source:)) ?? .failure(.requirement)
        let purchaseActiveResult = dictionary[purchaseActiveName].map(purchaseActiveTransformer.transform(source:)) ?? .failure(.requirement)
        let damageClaimAvailableResult = dictionary[damageClaimAvailableName].map(damageClaimAvailableTransformer.transform(source:)) ?? .failure(.requirement)
        let osagoClaimAvailableResult = dictionary[osagoClaimAvailableName].map(osagoClaimAvailableTransformer.transform(source:)) ?? .failure(.requirement)
        let telematicsInstallAvailableResult = dictionary[telematicsInstallAvailableName].map(telematicsInstallAvailableTransformer.transform(source:)) ?? .failure(.requirement)
        let damageClaimTextResult = damageClaimTextTransformer.transform(source: dictionary[damageClaimTextName])
        let osagoClaimTextResult = osagoClaimTextTransformer.transform(source: dictionary[osagoClaimTextName])
        let advertTextResult = advertTextTransformer.transform(source: dictionary[advertTextName])
        let additionalContactsResult = additionalContactsTransformer.transform(source: dictionary[additionalContactsName])
        let specialConditionsResult = specialConditionsTransformer.transform(source: dictionary[specialConditionsName])
        let metroResult = metroTransformer.transform(source: dictionary[metroName])
        let distanceResult = distanceTransformer.transform(source: dictionary[distanceName])
        let timetableResult = dictionary[timetableName].map(timetableTransformer.transform(source:)) ?? .failure(.requirement)
        let specialTimetableResult = dictionary[specialTimetableName].map(specialTimetableTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        addressResult.error.map { errors.append((addressName, $0)) }
        coordinateResult.error.map { errors.append((coordinateName, $0)) }
        phonesResult.error.map { errors.append((phonesName, $0)) }
        serviceHoursResult.error.map { errors.append((serviceHoursName, $0)) }
        servicesResult.error.map { errors.append((servicesName, $0)) }
        cityIdResult.error.map { errors.append((cityIdName, $0)) }
        campaignsResult.error.map { errors.append((campaignsName, $0)) }
        cardPaymentAvailableResult.error.map { errors.append((cardPaymentAvailableName, $0)) }
        purchaseActiveResult.error.map { errors.append((purchaseActiveName, $0)) }
        damageClaimAvailableResult.error.map { errors.append((damageClaimAvailableName, $0)) }
        osagoClaimAvailableResult.error.map { errors.append((osagoClaimAvailableName, $0)) }
        telematicsInstallAvailableResult.error.map { errors.append((telematicsInstallAvailableName, $0)) }
        damageClaimTextResult.error.map { errors.append((damageClaimTextName, $0)) }
        osagoClaimTextResult.error.map { errors.append((osagoClaimTextName, $0)) }
        advertTextResult.error.map { errors.append((advertTextName, $0)) }
        additionalContactsResult.error.map { errors.append((additionalContactsName, $0)) }
        specialConditionsResult.error.map { errors.append((specialConditionsName, $0)) }
        metroResult.error.map { errors.append((metroName, $0)) }
        distanceResult.error.map { errors.append((distanceName, $0)) }
        timetableResult.error.map { errors.append((timetableName, $0)) }
        specialTimetableResult.error.map { errors.append((specialTimetableName, $0)) }

        guard
            let id = idResult.value,
            let address = addressResult.value,
            let coordinate = coordinateResult.value,
            let phones = phonesResult.value,
            let serviceHours = serviceHoursResult.value,
            let services = servicesResult.value,
            let cityId = cityIdResult.value,
            let campaigns = campaignsResult.value,
            let cardPaymentAvailable = cardPaymentAvailableResult.value,
            let purchaseActive = purchaseActiveResult.value,
            let damageClaimAvailable = damageClaimAvailableResult.value,
            let osagoClaimAvailable = osagoClaimAvailableResult.value,
            let telematicsInstallAvailable = telematicsInstallAvailableResult.value,
            let damageClaimText = damageClaimTextResult.value,
            let osagoClaimText = osagoClaimTextResult.value,
            let advertText = advertTextResult.value,
            let additionalContacts = additionalContactsResult.value,
            let specialConditions = specialConditionsResult.value,
            let metro = metroResult.value,
            let distance = distanceResult.value,
            let timetable = timetableResult.value,
            let specialTimetable = specialTimetableResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                address: address,
                coordinate: coordinate,
                phones: phones,
                serviceHours: serviceHours,
                services: services,
                cityId: cityId,
                campaigns: campaigns,
                cardPaymentAvailable: cardPaymentAvailable,
                purchaseActive: purchaseActive,
                damageClaimAvailable: damageClaimAvailable,
                osagoClaimAvailable: osagoClaimAvailable,
                telematicsInstallAvailable: telematicsInstallAvailable,
                damageClaimText: damageClaimText,
                osagoClaimText: osagoClaimText,
                advertText: advertText,
                additionalContacts: additionalContacts,
                specialConditions: specialConditions,
                metro: metro,
                distance: distance,
                timetable: timetable,
                specialTimetable: specialTimetable
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let addressResult = addressTransformer.transform(destination: value.address)
        let coordinateResult = coordinateTransformer.transform(destination: value.coordinate)
        let phonesResult = phonesTransformer.transform(destination: value.phones)
        let serviceHoursResult = serviceHoursTransformer.transform(destination: value.serviceHours)
        let servicesResult = servicesTransformer.transform(destination: value.services)
        let cityIdResult = cityIdTransformer.transform(destination: value.cityId)
        let campaignsResult = campaignsTransformer.transform(destination: value.campaigns)
        let cardPaymentAvailableResult = cardPaymentAvailableTransformer.transform(destination: value.cardPaymentAvailable)
        let purchaseActiveResult = purchaseActiveTransformer.transform(destination: value.purchaseActive)
        let damageClaimAvailableResult = damageClaimAvailableTransformer.transform(destination: value.damageClaimAvailable)
        let osagoClaimAvailableResult = osagoClaimAvailableTransformer.transform(destination: value.osagoClaimAvailable)
        let telematicsInstallAvailableResult = telematicsInstallAvailableTransformer.transform(destination: value.telematicsInstallAvailable)
        let damageClaimTextResult = damageClaimTextTransformer.transform(destination: value.damageClaimText)
        let osagoClaimTextResult = osagoClaimTextTransformer.transform(destination: value.osagoClaimText)
        let advertTextResult = advertTextTransformer.transform(destination: value.advertText)
        let additionalContactsResult = additionalContactsTransformer.transform(destination: value.additionalContacts)
        let specialConditionsResult = specialConditionsTransformer.transform(destination: value.specialConditions)
        let metroResult = metroTransformer.transform(destination: value.metro)
        let distanceResult = distanceTransformer.transform(destination: value.distance)
        let timetableResult = timetableTransformer.transform(destination: value.timetable)
        let specialTimetableResult = specialTimetableTransformer.transform(destination: value.specialTimetable)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        addressResult.error.map { errors.append((addressName, $0)) }
        coordinateResult.error.map { errors.append((coordinateName, $0)) }
        phonesResult.error.map { errors.append((phonesName, $0)) }
        serviceHoursResult.error.map { errors.append((serviceHoursName, $0)) }
        servicesResult.error.map { errors.append((servicesName, $0)) }
        cityIdResult.error.map { errors.append((cityIdName, $0)) }
        campaignsResult.error.map { errors.append((campaignsName, $0)) }
        cardPaymentAvailableResult.error.map { errors.append((cardPaymentAvailableName, $0)) }
        purchaseActiveResult.error.map { errors.append((purchaseActiveName, $0)) }
        damageClaimAvailableResult.error.map { errors.append((damageClaimAvailableName, $0)) }
        osagoClaimAvailableResult.error.map { errors.append((osagoClaimAvailableName, $0)) }
        telematicsInstallAvailableResult.error.map { errors.append((telematicsInstallAvailableName, $0)) }
        damageClaimTextResult.error.map { errors.append((damageClaimTextName, $0)) }
        osagoClaimTextResult.error.map { errors.append((osagoClaimTextName, $0)) }
        advertTextResult.error.map { errors.append((advertTextName, $0)) }
        additionalContactsResult.error.map { errors.append((additionalContactsName, $0)) }
        specialConditionsResult.error.map { errors.append((specialConditionsName, $0)) }
        metroResult.error.map { errors.append((metroName, $0)) }
        distanceResult.error.map { errors.append((distanceName, $0)) }
        timetableResult.error.map { errors.append((timetableName, $0)) }
        specialTimetableResult.error.map { errors.append((specialTimetableName, $0)) }

        guard
            let id = idResult.value,
            let address = addressResult.value,
            let coordinate = coordinateResult.value,
            let phones = phonesResult.value,
            let serviceHours = serviceHoursResult.value,
            let services = servicesResult.value,
            let cityId = cityIdResult.value,
            let campaigns = campaignsResult.value,
            let cardPaymentAvailable = cardPaymentAvailableResult.value,
            let purchaseActive = purchaseActiveResult.value,
            let damageClaimAvailable = damageClaimAvailableResult.value,
            let osagoClaimAvailable = osagoClaimAvailableResult.value,
            let telematicsInstallAvailable = telematicsInstallAvailableResult.value,
            let damageClaimText = damageClaimTextResult.value,
            let osagoClaimText = osagoClaimTextResult.value,
            let advertText = advertTextResult.value,
            let additionalContacts = additionalContactsResult.value,
            let specialConditions = specialConditionsResult.value,
            let metro = metroResult.value,
            let distance = distanceResult.value,
            let timetable = timetableResult.value,
            let specialTimetable = specialTimetableResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[addressName] = address
        dictionary[coordinateName] = coordinate
        dictionary[phonesName] = phones
        dictionary[serviceHoursName] = serviceHours
        dictionary[servicesName] = services
        dictionary[cityIdName] = cityId
        dictionary[campaignsName] = campaigns
        dictionary[cardPaymentAvailableName] = cardPaymentAvailable
        dictionary[purchaseActiveName] = purchaseActive
        dictionary[damageClaimAvailableName] = damageClaimAvailable
        dictionary[osagoClaimAvailableName] = osagoClaimAvailable
        dictionary[telematicsInstallAvailableName] = telematicsInstallAvailable
        dictionary[damageClaimTextName] = damageClaimText
        dictionary[osagoClaimTextName] = osagoClaimText
        dictionary[advertTextName] = advertText
        dictionary[additionalContactsName] = additionalContacts
        dictionary[specialConditionsName] = specialConditions
        dictionary[metroName] = metro
        dictionary[distanceName] = distance
        dictionary[timetableName] = timetable
        dictionary[specialTimetableName] = specialTimetable
        return .success(dictionary)
    }
}
