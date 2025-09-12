// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct StoaTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Stoa

    let idName = "id"
    let titleName = "title"
    let addressName = "address"
    let coordinateName = "coordinate"
    let serviceHoursName = "serviceHours"
    let dealerName = "dealer"
    let phoneListName = "phone_list"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let addressTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let coordinateTransformer = CoordinateTransformer()
    let serviceHoursTransformer = CastTransformer<Any, String>()
    let dealerTransformer = CastTransformer<Any, String>()
    let phoneListTransformer = ArrayTransformer(from: Any.self, transformer: PhoneTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let addressResult = addressTransformer.transform(source: dictionary[addressName])
        let coordinateResult = dictionary[coordinateName].map(coordinateTransformer.transform(source:)) ?? .failure(.requirement)
        let serviceHoursResult = dictionary[serviceHoursName].map(serviceHoursTransformer.transform(source:)) ?? .failure(.requirement)
        let dealerResult = dictionary[dealerName].map(dealerTransformer.transform(source:)) ?? .failure(.requirement)
        let phoneListResult = dictionary[phoneListName].map(phoneListTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        addressResult.error.map { errors.append((addressName, $0)) }
        coordinateResult.error.map { errors.append((coordinateName, $0)) }
        serviceHoursResult.error.map { errors.append((serviceHoursName, $0)) }
        dealerResult.error.map { errors.append((dealerName, $0)) }
        phoneListResult.error.map { errors.append((phoneListName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let address = addressResult.value,
            let coordinate = coordinateResult.value,
            let serviceHours = serviceHoursResult.value,
            let dealer = dealerResult.value,
            let phoneList = phoneListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                address: address,
                coordinate: coordinate,
                serviceHours: serviceHours,
                dealer: dealer,
                phoneList: phoneList
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let addressResult = addressTransformer.transform(destination: value.address)
        let coordinateResult = coordinateTransformer.transform(destination: value.coordinate)
        let serviceHoursResult = serviceHoursTransformer.transform(destination: value.serviceHours)
        let dealerResult = dealerTransformer.transform(destination: value.dealer)
        let phoneListResult = phoneListTransformer.transform(destination: value.phoneList)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        addressResult.error.map { errors.append((addressName, $0)) }
        coordinateResult.error.map { errors.append((coordinateName, $0)) }
        serviceHoursResult.error.map { errors.append((serviceHoursName, $0)) }
        dealerResult.error.map { errors.append((dealerName, $0)) }
        phoneListResult.error.map { errors.append((phoneListName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let address = addressResult.value,
            let coordinate = coordinateResult.value,
            let serviceHours = serviceHoursResult.value,
            let dealer = dealerResult.value,
            let phoneList = phoneListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[addressName] = address
        dictionary[coordinateName] = coordinate
        dictionary[serviceHoursName] = serviceHours
        dictionary[dealerName] = dealer
        dictionary[phoneListName] = phoneList
        return .success(dictionary)
    }
}
