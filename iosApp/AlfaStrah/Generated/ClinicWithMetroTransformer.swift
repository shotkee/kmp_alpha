// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ClinicWithMetroTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ClinicWithMetro

    let idName = "id"
    let titleName = "title"
    let longitudeName = "longitude"
    let latitudeName = "latitude"
    let radiusName = "radius"
    let metroStationListName = "metro_station_list"

    let idTransformer = NumberTransformer<Any, Int>()
    let titleTransformer = CastTransformer<Any, String>()
    let longitudeTransformer = CastTransformer<Any, String>()
    let latitudeTransformer = CastTransformer<Any, String>()
    let radiusTransformer = NumberTransformer<Any, Double>()
    let metroStationListTransformer = ArrayTransformer(from: Any.self, transformer: MetroStationTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let longitudeResult = dictionary[longitudeName].map(longitudeTransformer.transform(source:)) ?? .failure(.requirement)
        let latitudeResult = dictionary[latitudeName].map(latitudeTransformer.transform(source:)) ?? .failure(.requirement)
        let radiusResult = dictionary[radiusName].map(radiusTransformer.transform(source:)) ?? .failure(.requirement)
        let metroStationListResult = dictionary[metroStationListName].map(metroStationListTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        longitudeResult.error.map { errors.append((longitudeName, $0)) }
        latitudeResult.error.map { errors.append((latitudeName, $0)) }
        radiusResult.error.map { errors.append((radiusName, $0)) }
        metroStationListResult.error.map { errors.append((metroStationListName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let longitude = longitudeResult.value,
            let latitude = latitudeResult.value,
            let radius = radiusResult.value,
            let metroStationList = metroStationListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                longitude: longitude,
                latitude: latitude,
                radius: radius,
                metroStationList: metroStationList
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let longitudeResult = longitudeTransformer.transform(destination: value.longitude)
        let latitudeResult = latitudeTransformer.transform(destination: value.latitude)
        let radiusResult = radiusTransformer.transform(destination: value.radius)
        let metroStationListResult = metroStationListTransformer.transform(destination: value.metroStationList)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        longitudeResult.error.map { errors.append((longitudeName, $0)) }
        latitudeResult.error.map { errors.append((latitudeName, $0)) }
        radiusResult.error.map { errors.append((radiusName, $0)) }
        metroStationListResult.error.map { errors.append((metroStationListName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let longitude = longitudeResult.value,
            let latitude = latitudeResult.value,
            let radius = radiusResult.value,
            let metroStationList = metroStationListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[longitudeName] = longitude
        dictionary[latitudeName] = latitude
        dictionary[radiusName] = radius
        dictionary[metroStationListName] = metroStationList
        return .success(dictionary)
    }
}
