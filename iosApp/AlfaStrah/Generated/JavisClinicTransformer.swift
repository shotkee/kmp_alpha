// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct JavisClinicTransformer: Transformer {
    typealias Source = Any
    typealias Destination = JavisClinic

    let idName = "id"
    let titleName = "title"
    let addressName = "address"
    let coordinateName = "coordinate"
    let serviceHoursName = "service_hours"
    let phoneName = "phone"
    let webAddressName = "web_address"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let addressTransformer = CastTransformer<Any, String>()
    let coordinateTransformer = CoordinateTransformer()
    let serviceHoursTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let phoneTransformer = OptionalTransformer(transformer: PhoneTransformer())
    let webAddressTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let addressResult = dictionary[addressName].map(addressTransformer.transform(source:)) ?? .failure(.requirement)
        let coordinateResult = dictionary[coordinateName].map(coordinateTransformer.transform(source:)) ?? .failure(.requirement)
        let serviceHoursResult = serviceHoursTransformer.transform(source: dictionary[serviceHoursName])
        let phoneResult = phoneTransformer.transform(source: dictionary[phoneName])
        let webAddressResult = webAddressTransformer.transform(source: dictionary[webAddressName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        addressResult.error.map { errors.append((addressName, $0)) }
        coordinateResult.error.map { errors.append((coordinateName, $0)) }
        serviceHoursResult.error.map { errors.append((serviceHoursName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        webAddressResult.error.map { errors.append((webAddressName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let address = addressResult.value,
            let coordinate = coordinateResult.value,
            let serviceHours = serviceHoursResult.value,
            let phone = phoneResult.value,
            let webAddress = webAddressResult.value,
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
                phone: phone,
                webAddress: webAddress
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let addressResult = addressTransformer.transform(destination: value.address)
        let coordinateResult = coordinateTransformer.transform(destination: value.coordinate)
        let serviceHoursResult = serviceHoursTransformer.transform(destination: value.serviceHours)
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let webAddressResult = webAddressTransformer.transform(destination: value.webAddress)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        addressResult.error.map { errors.append((addressName, $0)) }
        coordinateResult.error.map { errors.append((coordinateName, $0)) }
        serviceHoursResult.error.map { errors.append((serviceHoursName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        webAddressResult.error.map { errors.append((webAddressName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let address = addressResult.value,
            let coordinate = coordinateResult.value,
            let serviceHours = serviceHoursResult.value,
            let phone = phoneResult.value,
            let webAddress = webAddressResult.value,
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
        dictionary[phoneName] = phone
        dictionary[webAddressName] = webAddress
        return .success(dictionary)
    }
}
