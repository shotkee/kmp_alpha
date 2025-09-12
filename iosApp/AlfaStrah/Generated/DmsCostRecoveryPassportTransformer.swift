// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryPassportTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryPassport

    let seriesName = "series"
    let numberName = "number"
    let issuerName = "issue_place"
    let issueDateName = "issue_date"
    let birthPlaceName = "birth_place"
    let citizenshipName = "citizenship"

    let seriesTransformer = CastTransformer<Any, String>()
    let numberTransformer = CastTransformer<Any, String>()
    let issuerTransformer = CastTransformer<Any, String>()
    let issueDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd")
    let birthPlaceTransformer = CastTransformer<Any, String>()
    let citizenshipTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let seriesResult = dictionary[seriesName].map(seriesTransformer.transform(source:)) ?? .failure(.requirement)
        let numberResult = dictionary[numberName].map(numberTransformer.transform(source:)) ?? .failure(.requirement)
        let issuerResult = dictionary[issuerName].map(issuerTransformer.transform(source:)) ?? .failure(.requirement)
        let issueDateResult = dictionary[issueDateName].map(issueDateTransformer.transform(source:)) ?? .failure(.requirement)
        let birthPlaceResult = dictionary[birthPlaceName].map(birthPlaceTransformer.transform(source:)) ?? .failure(.requirement)
        let citizenshipResult = dictionary[citizenshipName].map(citizenshipTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        seriesResult.error.map { errors.append((seriesName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }
        issuerResult.error.map { errors.append((issuerName, $0)) }
        issueDateResult.error.map { errors.append((issueDateName, $0)) }
        birthPlaceResult.error.map { errors.append((birthPlaceName, $0)) }
        citizenshipResult.error.map { errors.append((citizenshipName, $0)) }

        guard
            let series = seriesResult.value,
            let number = numberResult.value,
            let issuer = issuerResult.value,
            let issueDate = issueDateResult.value,
            let birthPlace = birthPlaceResult.value,
            let citizenship = citizenshipResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                series: series,
                number: number,
                issuer: issuer,
                issueDate: issueDate,
                birthPlace: birthPlace,
                citizenship: citizenship
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let seriesResult = seriesTransformer.transform(destination: value.series)
        let numberResult = numberTransformer.transform(destination: value.number)
        let issuerResult = issuerTransformer.transform(destination: value.issuer)
        let issueDateResult = issueDateTransformer.transform(destination: value.issueDate)
        let birthPlaceResult = birthPlaceTransformer.transform(destination: value.birthPlace)
        let citizenshipResult = citizenshipTransformer.transform(destination: value.citizenship)

        var errors: [(String, TransformerError)] = []
        seriesResult.error.map { errors.append((seriesName, $0)) }
        numberResult.error.map { errors.append((numberName, $0)) }
        issuerResult.error.map { errors.append((issuerName, $0)) }
        issueDateResult.error.map { errors.append((issueDateName, $0)) }
        birthPlaceResult.error.map { errors.append((birthPlaceName, $0)) }
        citizenshipResult.error.map { errors.append((citizenshipName, $0)) }

        guard
            let series = seriesResult.value,
            let number = numberResult.value,
            let issuer = issuerResult.value,
            let issueDate = issueDateResult.value,
            let birthPlace = birthPlaceResult.value,
            let citizenship = citizenshipResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[seriesName] = series
        dictionary[numberName] = number
        dictionary[issuerName] = issuer
        dictionary[issueDateName] = issueDate
        dictionary[birthPlaceName] = birthPlace
        dictionary[citizenshipName] = citizenship
        return .success(dictionary)
    }
}
