// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CreateAutoEventReportTransformer: Transformer {
    typealias Source = Any
    typealias Destination = CreateAutoEventReport

    let insuranceIdName = "insurance_id"
    let fullDescriptionName = "full_description"
    let coordinateName = "coordinate"
    let documentCountName = "document_count"
    let claimDateName = "claim_date"
    let timezoneName = "timezone"
    let geoPlaceName = "geo_place"

    let insuranceIdTransformer = CastTransformer<Any, String>()
    let fullDescriptionTransformer = CastTransformer<Any, String>()
    let coordinateTransformer = CoordinateTransformer()
    let documentCountTransformer = NumberTransformer<Any, Int>()
    let claimDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)
    let timezoneTransformer = DateTransformer<Any>(format: "xxx", locale: AppLocale.currentLocale)
    let geoPlaceTransformer = OptionalTransformer(transformer: GeoPlaceTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let insuranceIdResult = dictionary[insuranceIdName].map(insuranceIdTransformer.transform(source:)) ?? .failure(.requirement)
        let fullDescriptionResult = dictionary[fullDescriptionName].map(fullDescriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let coordinateResult = dictionary[coordinateName].map(coordinateTransformer.transform(source:)) ?? .failure(.requirement)
        let documentCountResult = dictionary[documentCountName].map(documentCountTransformer.transform(source:)) ?? .failure(.requirement)
        let claimDateResult = dictionary[claimDateName].map(claimDateTransformer.transform(source:)) ?? .failure(.requirement)
        let timezoneResult = dictionary[timezoneName].map(timezoneTransformer.transform(source:)) ?? .failure(.requirement)
        let geoPlaceResult = geoPlaceTransformer.transform(source: dictionary[geoPlaceName])

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        fullDescriptionResult.error.map { errors.append((fullDescriptionName, $0)) }
        coordinateResult.error.map { errors.append((coordinateName, $0)) }
        documentCountResult.error.map { errors.append((documentCountName, $0)) }
        claimDateResult.error.map { errors.append((claimDateName, $0)) }
        timezoneResult.error.map { errors.append((timezoneName, $0)) }
        geoPlaceResult.error.map { errors.append((geoPlaceName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let fullDescription = fullDescriptionResult.value,
            let coordinate = coordinateResult.value,
            let documentCount = documentCountResult.value,
            let claimDate = claimDateResult.value,
            let timezone = timezoneResult.value,
            let geoPlace = geoPlaceResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                insuranceId: insuranceId,
                fullDescription: fullDescription,
                coordinate: coordinate,
                documentCount: documentCount,
                claimDate: claimDate,
                timezone: timezone,
                geoPlace: geoPlace
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let insuranceIdResult = insuranceIdTransformer.transform(destination: value.insuranceId)
        let fullDescriptionResult = fullDescriptionTransformer.transform(destination: value.fullDescription)
        let coordinateResult = coordinateTransformer.transform(destination: value.coordinate)
        let documentCountResult = documentCountTransformer.transform(destination: value.documentCount)
        let claimDateResult = claimDateTransformer.transform(destination: value.claimDate)
        let timezoneResult = timezoneTransformer.transform(destination: value.timezone)
        let geoPlaceResult = geoPlaceTransformer.transform(destination: value.geoPlace)

        var errors: [(String, TransformerError)] = []
        insuranceIdResult.error.map { errors.append((insuranceIdName, $0)) }
        fullDescriptionResult.error.map { errors.append((fullDescriptionName, $0)) }
        coordinateResult.error.map { errors.append((coordinateName, $0)) }
        documentCountResult.error.map { errors.append((documentCountName, $0)) }
        claimDateResult.error.map { errors.append((claimDateName, $0)) }
        timezoneResult.error.map { errors.append((timezoneName, $0)) }
        geoPlaceResult.error.map { errors.append((geoPlaceName, $0)) }

        guard
            let insuranceId = insuranceIdResult.value,
            let fullDescription = fullDescriptionResult.value,
            let coordinate = coordinateResult.value,
            let documentCount = documentCountResult.value,
            let claimDate = claimDateResult.value,
            let timezone = timezoneResult.value,
            let geoPlace = geoPlaceResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[insuranceIdName] = insuranceId
        dictionary[fullDescriptionName] = fullDescription
        dictionary[coordinateName] = coordinate
        dictionary[documentCountName] = documentCount
        dictionary[claimDateName] = claimDate
        dictionary[timezoneName] = timezone
        dictionary[geoPlaceName] = geoPlace
        return .success(dictionary)
    }
}
