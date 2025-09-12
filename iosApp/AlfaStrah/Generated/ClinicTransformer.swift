// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ClinicTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Clinic

    let idName = "id"
    let titleName = "title"
    let addressName = "address"
    let coordinateName = "coordinate"
    let serviceHoursName = "service_hours"
    let labelListName = "label_list"
    let metroListName = "metro_list"
    let serviceListName = "service_list"
    let urlName = "url"
    let phoneListName = "phone_list"
    let buttonTextName = "button_text"
    let buttonActionName = "button_action"
    let filterListName = "filter_list"
    let franchiseName = "franchise"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let addressTransformer = CastTransformer<Any, String>()
    let coordinateTransformer = CoordinateTransformer()
    let serviceHoursTransformer = CastTransformer<Any, String>()
    let labelListTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: ClinicLabelListTransformer(), skipFailures: true))
    let metroListTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: ClinicMetroTransformer(), skipFailures: true))
    let serviceListTransformer = ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true)
    let urlTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())
    let phoneListTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: PhoneTransformer(), skipFailures: true))
    let buttonTextTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let buttonActionTransformer = OptionalTransformer(transformer: ClinicButtonActionTransformer())
    let filterListTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: ClinicClinicFilterTransformer(), skipFailures: true))
    let franchiseTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Bool>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let addressResult = dictionary[addressName].map(addressTransformer.transform(source:)) ?? .failure(.requirement)
        let coordinateResult = dictionary[coordinateName].map(coordinateTransformer.transform(source:)) ?? .failure(.requirement)
        let serviceHoursResult = dictionary[serviceHoursName].map(serviceHoursTransformer.transform(source:)) ?? .failure(.requirement)
        let labelListResult = labelListTransformer.transform(source: dictionary[labelListName])
        let metroListResult = metroListTransformer.transform(source: dictionary[metroListName])
        let serviceListResult = dictionary[serviceListName].map(serviceListTransformer.transform(source:)) ?? .failure(.requirement)
        let urlResult = urlTransformer.transform(source: dictionary[urlName])
        let phoneListResult = phoneListTransformer.transform(source: dictionary[phoneListName])
        let buttonTextResult = buttonTextTransformer.transform(source: dictionary[buttonTextName])
        let buttonActionResult = buttonActionTransformer.transform(source: dictionary[buttonActionName])
        let filterListResult = filterListTransformer.transform(source: dictionary[filterListName])
        let franchiseResult = franchiseTransformer.transform(source: dictionary[franchiseName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        addressResult.error.map { errors.append((addressName, $0)) }
        coordinateResult.error.map { errors.append((coordinateName, $0)) }
        serviceHoursResult.error.map { errors.append((serviceHoursName, $0)) }
        labelListResult.error.map { errors.append((labelListName, $0)) }
        metroListResult.error.map { errors.append((metroListName, $0)) }
        serviceListResult.error.map { errors.append((serviceListName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }
        phoneListResult.error.map { errors.append((phoneListName, $0)) }
        buttonTextResult.error.map { errors.append((buttonTextName, $0)) }
        buttonActionResult.error.map { errors.append((buttonActionName, $0)) }
        filterListResult.error.map { errors.append((filterListName, $0)) }
        franchiseResult.error.map { errors.append((franchiseName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let address = addressResult.value,
            let coordinate = coordinateResult.value,
            let serviceHours = serviceHoursResult.value,
            let labelList = labelListResult.value,
            let metroList = metroListResult.value,
            let serviceList = serviceListResult.value,
            let url = urlResult.value,
            let phoneList = phoneListResult.value,
            let buttonText = buttonTextResult.value,
            let buttonAction = buttonActionResult.value,
            let filterList = filterListResult.value,
            let franchise = franchiseResult.value,
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
                labelList: labelList,
                metroList: metroList,
                serviceList: serviceList,
                url: url,
                phoneList: phoneList,
                buttonText: buttonText,
                buttonAction: buttonAction,
                filterList: filterList,
                franchise: franchise
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let addressResult = addressTransformer.transform(destination: value.address)
        let coordinateResult = coordinateTransformer.transform(destination: value.coordinate)
        let serviceHoursResult = serviceHoursTransformer.transform(destination: value.serviceHours)
        let labelListResult = labelListTransformer.transform(destination: value.labelList)
        let metroListResult = metroListTransformer.transform(destination: value.metroList)
        let serviceListResult = serviceListTransformer.transform(destination: value.serviceList)
        let urlResult = urlTransformer.transform(destination: value.url)
        let phoneListResult = phoneListTransformer.transform(destination: value.phoneList)
        let buttonTextResult = buttonTextTransformer.transform(destination: value.buttonText)
        let buttonActionResult = buttonActionTransformer.transform(destination: value.buttonAction)
        let filterListResult = filterListTransformer.transform(destination: value.filterList)
        let franchiseResult = franchiseTransformer.transform(destination: value.franchise)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        addressResult.error.map { errors.append((addressName, $0)) }
        coordinateResult.error.map { errors.append((coordinateName, $0)) }
        serviceHoursResult.error.map { errors.append((serviceHoursName, $0)) }
        labelListResult.error.map { errors.append((labelListName, $0)) }
        metroListResult.error.map { errors.append((metroListName, $0)) }
        serviceListResult.error.map { errors.append((serviceListName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }
        phoneListResult.error.map { errors.append((phoneListName, $0)) }
        buttonTextResult.error.map { errors.append((buttonTextName, $0)) }
        buttonActionResult.error.map { errors.append((buttonActionName, $0)) }
        filterListResult.error.map { errors.append((filterListName, $0)) }
        franchiseResult.error.map { errors.append((franchiseName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let address = addressResult.value,
            let coordinate = coordinateResult.value,
            let serviceHours = serviceHoursResult.value,
            let labelList = labelListResult.value,
            let metroList = metroListResult.value,
            let serviceList = serviceListResult.value,
            let url = urlResult.value,
            let phoneList = phoneListResult.value,
            let buttonText = buttonTextResult.value,
            let buttonAction = buttonActionResult.value,
            let filterList = filterListResult.value,
            let franchise = franchiseResult.value,
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
        dictionary[labelListName] = labelList
        dictionary[metroListName] = metroList
        dictionary[serviceListName] = serviceList
        dictionary[urlName] = url
        dictionary[phoneListName] = phoneList
        dictionary[buttonTextName] = buttonText
        dictionary[buttonActionName] = buttonAction
        dictionary[filterListName] = filterList
        dictionary[franchiseName] = franchise
        return .success(dictionary)
    }
}
