// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct EsiaPassportTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EsiaPassport

    let isRussianName = "isRussian"
    let isVerifiedName = "isVerified"
    let seriesName = "series"
    let numberName = "number"
    let issueDateName = "issueDate"
    let issuedByName = "issuedBy"

    let isRussianTransformer = NumberTransformer<Any, Bool>()
    let isVerifiedTransformer = NumberTransformer<Any, Bool>()
    let seriesTransformer = CastTransformer<Any, String>()
    let numberTransformer = CastTransformer<Any, String>()
    let issueDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let issuedByTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let isRussianResult = dictionary[isRussianName].map(isRussianTransformer.transform(source:)) ?? .failure(.requirement)
        let isVerifiedResult = dictionary[isVerifiedName].map(isVerifiedTransformer.transform(source:)) ?? .failure(.requirement)
        let seriesResult = dictionary[seriesName].map(seriesTransformer.transform(source:)) ?? .failure(.requirement)
        let numberResult = dictionary[numberName].map(numberTransformer.transform(source:)) ?? .failure(.requirement)
        let issueDateResult = dictionary[issueDateName].map(issueDateTransformer.transform(source:)) ?? .failure(.requirement)
        let issuedByResult = dictionary[issuedByName].map(issuedByTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        isRussianResult.error.map { errors.append((isRussianName, $0)) }
        isVerifiedResult.error.map { errors.append((isVerifiedName, $0)) }
        seriesResult.error.map { errors.append((seriesName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }
        issueDateResult.error.map { errors.append((issueDateName, $0)) }
        issuedByResult.error.map { errors.append((issuedByName, $0)) }

        guard
            let isRussian = isRussianResult.value,
            let isVerified = isVerifiedResult.value,
            let series = seriesResult.value,
            let number = numberResult.value,
            let issueDate = issueDateResult.value,
            let issuedBy = issuedByResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                isRussian: isRussian,
                isVerified: isVerified,
                series: series,
                number: number,
                issueDate: issueDate,
                issuedBy: issuedBy
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let isRussianResult = isRussianTransformer.transform(destination: value.isRussian)
        let isVerifiedResult = isVerifiedTransformer.transform(destination: value.isVerified)
        let seriesResult = seriesTransformer.transform(destination: value.series)
        let numberResult = numberTransformer.transform(destination: value.number)
        let issueDateResult = issueDateTransformer.transform(destination: value.issueDate)
        let issuedByResult = issuedByTransformer.transform(destination: value.issuedBy)

        var errors: [(String, TransformerError)] = []
        isRussianResult.error.map { errors.append((isRussianName, $0)) }
        isVerifiedResult.error.map { errors.append((isVerifiedName, $0)) }
        seriesResult.error.map { errors.append((seriesName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }
        issueDateResult.error.map { errors.append((issueDateName, $0)) }
        issuedByResult.error.map { errors.append((issuedByName, $0)) }

        guard
            let isRussian = isRussianResult.value,
            let isVerified = isVerifiedResult.value,
            let series = seriesResult.value,
            let number = numberResult.value,
            let issueDate = issueDateResult.value,
            let issuedBy = issuedByResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[isRussianName] = isRussian
        dictionary[isVerifiedName] = isVerified
        dictionary[seriesName] = series
        dictionary[numberName] = number
        dictionary[issueDateName] = issueDate
        dictionary[issuedByName] = issuedBy
        return .success(dictionary)
    }
}
