// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CityWithMetroTransformer: Transformer {
    typealias Source = Any
    typealias Destination = CityWithMetro

    let idName = "id"
    let titleName = "title"
    let latitudeName = "latitude"
    let longitudeName = "longitude"
    let radiusName = "radius"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let latitudeTransformer = NumberTransformer<Any, Double>()
    let longitudeTransformer = NumberTransformer<Any, Double>()
    let radiusTransformer = NumberTransformer<Any, Double>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let latitudeResult = dictionary[latitudeName].map(latitudeTransformer.transform(source:)) ?? .failure(.requirement)
        let longitudeResult = dictionary[longitudeName].map(longitudeTransformer.transform(source:)) ?? .failure(.requirement)
        let radiusResult = dictionary[radiusName].map(radiusTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        latitudeResult.error.map { errors.append((latitudeName, $0)) }
        longitudeResult.error.map { errors.append((longitudeName, $0)) }
        radiusResult.error.map { errors.append((radiusName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let latitude = latitudeResult.value,
            let longitude = longitudeResult.value,
            let radius = radiusResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                latitude: latitude,
                longitude: longitude,
                radius: radius
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let latitudeResult = latitudeTransformer.transform(destination: value.latitude)
        let longitudeResult = longitudeTransformer.transform(destination: value.longitude)
        let radiusResult = radiusTransformer.transform(destination: value.radius)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        latitudeResult.error.map { errors.append((latitudeName, $0)) }
        longitudeResult.error.map { errors.append((longitudeName, $0)) }
        radiusResult.error.map { errors.append((radiusName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let latitude = latitudeResult.value,
            let longitude = longitudeResult.value,
            let radius = radiusResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[latitudeName] = latitude
        dictionary[longitudeName] = longitude
        dictionary[radiusName] = radius
        return .success(dictionary)
    }
}
