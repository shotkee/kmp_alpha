// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OsagoProlongationFieldTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OsagoProlongationField

    let idName = "id"
    let titleName = "title"
    let valueName = "value"
    let hasErrorName = "has_error"
    let dataTypeName = "data_type"
    let dataStringName = "data"
    let dataDateName = "data"
    let dataGeoName = "data"
    let dataDriverLicenseName = "data"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let valueTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let hasErrorTransformer = NumberTransformer<Any, Bool>()
    let dataTypeTransformer = OptionalTransformer(transformer: OsagoProlongationFieldDataTypeTransformer())
    let dataStringTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let dataDateTransformer = OptionalTransformer(transformer: DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale))
    let dataGeoTransformer = OptionalTransformer(transformer: GeoPlaceTransformer())
    let dataDriverLicenseTransformer = OptionalTransformer(transformer: SeriesAndNumberDocumentTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let valueResult = valueTransformer.transform(source: dictionary[valueName])
        let hasErrorResult = dictionary[hasErrorName].map(hasErrorTransformer.transform(source:)) ?? .failure(.requirement)
        let dataTypeResult = dataTypeTransformer.transform(source: dictionary[dataTypeName])
        let dataStringResult = dataStringTransformer.transform(source: dictionary[dataStringName])
        let dataDateResult = dataDateTransformer.transform(source: dictionary[dataDateName])
        let dataGeoResult = dataGeoTransformer.transform(source: dictionary[dataGeoName])
        let dataDriverLicenseResult = dataDriverLicenseTransformer.transform(source: dictionary[dataDriverLicenseName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        valueResult.error.map { errors.append((valueName, $0)) }
        hasErrorResult.error.map { errors.append((hasErrorName, $0)) }
        dataTypeResult.error.map { errors.append((dataTypeName, $0)) }
        dataStringResult.error.map { errors.append((dataStringName, $0)) }
        dataDateResult.error.map { errors.append((dataDateName, $0)) }
        dataGeoResult.error.map { errors.append((dataGeoName, $0)) }
        dataDriverLicenseResult.error.map { errors.append((dataDriverLicenseName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let value = valueResult.value,
            let hasError = hasErrorResult.value,
            let dataType = dataTypeResult.value,
            let dataString = dataStringResult.value,
            let dataDate = dataDateResult.value,
            let dataGeo = dataGeoResult.value,
            let dataDriverLicense = dataDriverLicenseResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                value: value,
                hasError: hasError,
                dataType: dataType,
                dataString: dataString,
                dataDate: dataDate,
                dataGeo: dataGeo,
                dataDriverLicense: dataDriverLicense
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let valueResult = valueTransformer.transform(destination: value.value)
        let hasErrorResult = hasErrorTransformer.transform(destination: value.hasError)
        let dataTypeResult = dataTypeTransformer.transform(destination: value.dataType)
        let dataStringResult = dataStringTransformer.transform(destination: value.dataString)
        let dataDateResult = dataDateTransformer.transform(destination: value.dataDate)
        let dataGeoResult = dataGeoTransformer.transform(destination: value.dataGeo)
        let dataDriverLicenseResult = dataDriverLicenseTransformer.transform(destination: value.dataDriverLicense)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        valueResult.error.map { errors.append((valueName, $0)) }
        hasErrorResult.error.map { errors.append((hasErrorName, $0)) }
        dataTypeResult.error.map { errors.append((dataTypeName, $0)) }
        dataStringResult.error.map { errors.append((dataStringName, $0)) }
        dataDateResult.error.map { errors.append((dataDateName, $0)) }
        dataGeoResult.error.map { errors.append((dataGeoName, $0)) }
        dataDriverLicenseResult.error.map { errors.append((dataDriverLicenseName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let value = valueResult.value,
            let hasError = hasErrorResult.value,
            let dataType = dataTypeResult.value,
            let dataString = dataStringResult.value,
            let dataDate = dataDateResult.value,
            let dataGeo = dataGeoResult.value,
            let dataDriverLicense = dataDriverLicenseResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[valueName] = value
        dictionary[hasErrorName] = hasError
        dictionary[dataTypeName] = dataType
        dictionary[dataStringName] = dataString
        dictionary[dataDateName] = dataDate
        dictionary[dataGeoName] = dataGeo
        dictionary[dataDriverLicenseName] = dataDriverLicense
        return .success(dictionary)
    }
}
