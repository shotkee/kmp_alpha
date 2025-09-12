// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct EsiaDriverLicenseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EsiaDriverLicense

    let kindName = "type"
    let seriesName = "series"
    let numberName = "number"
    let issueDateName = "issueDate"
    let expiryDateName = "expiryDate"

    let kindTransformer = EsiaDriverLicenseKindTransformer()
    let seriesTransformer = CastTransformer<Any, String>()
    let numberTransformer = CastTransformer<Any, String>()
    let issueDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let expiryDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let kindResult = dictionary[kindName].map(kindTransformer.transform(source:)) ?? .failure(.requirement)
        let seriesResult = dictionary[seriesName].map(seriesTransformer.transform(source:)) ?? .failure(.requirement)
        let numberResult = dictionary[numberName].map(numberTransformer.transform(source:)) ?? .failure(.requirement)
        let issueDateResult = dictionary[issueDateName].map(issueDateTransformer.transform(source:)) ?? .failure(.requirement)
        let expiryDateResult = dictionary[expiryDateName].map(expiryDateTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        kindResult.error.map { errors.append((kindName, $0)) }
        seriesResult.error.map { errors.append((seriesName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }
        issueDateResult.error.map { errors.append((issueDateName, $0)) }
        expiryDateResult.error.map { errors.append((expiryDateName, $0)) }

        guard
            let kind = kindResult.value,
            let series = seriesResult.value,
            let number = numberResult.value,
            let issueDate = issueDateResult.value,
            let expiryDate = expiryDateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                kind: kind,
                series: series,
                number: number,
                issueDate: issueDate,
                expiryDate: expiryDate
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let kindResult = kindTransformer.transform(destination: value.kind)
        let seriesResult = seriesTransformer.transform(destination: value.series)
        let numberResult = numberTransformer.transform(destination: value.number)
        let issueDateResult = issueDateTransformer.transform(destination: value.issueDate)
        let expiryDateResult = expiryDateTransformer.transform(destination: value.expiryDate)

        var errors: [(String, TransformerError)] = []
        kindResult.error.map { errors.append((kindName, $0)) }
        seriesResult.error.map { errors.append((seriesName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }
        issueDateResult.error.map { errors.append((issueDateName, $0)) }
        expiryDateResult.error.map { errors.append((expiryDateName, $0)) }

        guard
            let kind = kindResult.value,
            let series = seriesResult.value,
            let number = numberResult.value,
            let issueDate = issueDateResult.value,
            let expiryDate = expiryDateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[kindName] = kind
        dictionary[seriesName] = series
        dictionary[numberName] = number
        dictionary[issueDateName] = issueDate
        dictionary[expiryDateName] = expiryDate
        return .success(dictionary)
    }
}
