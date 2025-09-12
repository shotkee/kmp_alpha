// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct MetroStationTransformer: Transformer {
    typealias Source = Any
    typealias Destination = MetroStation

    let idName = "id"
    let titleName = "title"
    let pointColorName = "point_color"
    let clinicCountName = "clinic_count"
    let longitudeName = "longitude"
    let latitudeName = "latitude"

    let idTransformer = NumberTransformer<Any, Int>()
    let titleTransformer = CastTransformer<Any, String>()
    let pointColorTransformer = ThemedValueTransformer()
    let clinicCountTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Int>())
    let longitudeTransformer = CastTransformer<Any, String>()
    let latitudeTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let pointColorResult = dictionary[pointColorName].map(pointColorTransformer.transform(source:)) ?? .failure(.requirement)
        let clinicCountResult = clinicCountTransformer.transform(source: dictionary[clinicCountName])
        let longitudeResult = dictionary[longitudeName].map(longitudeTransformer.transform(source:)) ?? .failure(.requirement)
        let latitudeResult = dictionary[latitudeName].map(latitudeTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        pointColorResult.error.map { errors.append((pointColorName, $0)) }
        clinicCountResult.error.map { errors.append((clinicCountName, $0)) }
        longitudeResult.error.map { errors.append((longitudeName, $0)) }
        latitudeResult.error.map { errors.append((latitudeName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let pointColor = pointColorResult.value,
            let clinicCount = clinicCountResult.value,
            let longitude = longitudeResult.value,
            let latitude = latitudeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                pointColor: pointColor,
                clinicCount: clinicCount,
                longitude: longitude,
                latitude: latitude
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let pointColorResult = pointColorTransformer.transform(destination: value.pointColor)
        let clinicCountResult = clinicCountTransformer.transform(destination: value.clinicCount)
        let longitudeResult = longitudeTransformer.transform(destination: value.longitude)
        let latitudeResult = latitudeTransformer.transform(destination: value.latitude)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        pointColorResult.error.map { errors.append((pointColorName, $0)) }
        clinicCountResult.error.map { errors.append((clinicCountName, $0)) }
        longitudeResult.error.map { errors.append((longitudeName, $0)) }
        latitudeResult.error.map { errors.append((latitudeName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let pointColor = pointColorResult.value,
            let clinicCount = clinicCountResult.value,
            let longitude = longitudeResult.value,
            let latitude = latitudeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[pointColorName] = pointColor
        dictionary[clinicCountName] = clinicCount
        dictionary[longitudeName] = longitude
        dictionary[latitudeName] = latitude
        return .success(dictionary)
    }
}
