// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CoordinateTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Coordinate

    let latitudeName = "latitude"
    let longitudeName = "longitude"

    let latitudeTransformer = NumberTransformer<Any, Double>()
    let longitudeTransformer = NumberTransformer<Any, Double>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let latitudeResult = dictionary[latitudeName].map(latitudeTransformer.transform(source:)) ?? .failure(.requirement)
        let longitudeResult = dictionary[longitudeName].map(longitudeTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        latitudeResult.error.map { errors.append((latitudeName, $0)) }
        longitudeResult.error.map { errors.append((longitudeName, $0)) }

        guard
            let latitude = latitudeResult.value,
            let longitude = longitudeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                latitude: latitude,
                longitude: longitude
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let latitudeResult = latitudeTransformer.transform(destination: value.latitude)
        let longitudeResult = longitudeTransformer.transform(destination: value.longitude)

        var errors: [(String, TransformerError)] = []
        latitudeResult.error.map { errors.append((latitudeName, $0)) }
        longitudeResult.error.map { errors.append((longitudeName, $0)) }

        guard
            let latitude = latitudeResult.value,
            let longitude = longitudeResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[latitudeName] = latitude
        dictionary[longitudeName] = longitude
        return .success(dictionary)
    }
}
