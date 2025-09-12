// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct VehicleTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Vehicle

    let registrationNumberName = "reg_number"
    let powerName = "power"
    let vinName = "vin"
    let yearOfIssueName = "issue_year"
    let registrationCertificateSeriesName = "cert_seria"
    let registrationCertificateNumberName = "cert_number"
    let keyCountName = "key_count"
    let passportSeriesName = "passport_seria"
    let passportNumberName = "passport_number"

    let registrationNumberTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let powerTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let vinTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let yearOfIssueTransformer = OptionalTransformer(transformer: DateTransformer<Any>(format: "yyyy", locale: AppLocale.currentLocale))
    let registrationCertificateSeriesTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let registrationCertificateNumberTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let keyCountTransformer = OptionalTransformer(transformer: NumberStringTransformer<Any, Int>())
    let passportSeriesTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let passportNumberTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let registrationNumberResult = registrationNumberTransformer.transform(source: dictionary[registrationNumberName])
        let powerResult = powerTransformer.transform(source: dictionary[powerName])
        let vinResult = vinTransformer.transform(source: dictionary[vinName])
        let yearOfIssueResult = yearOfIssueTransformer.transform(source: dictionary[yearOfIssueName])
        let registrationCertificateSeriesResult = registrationCertificateSeriesTransformer.transform(source: dictionary[registrationCertificateSeriesName])
        let registrationCertificateNumberResult = registrationCertificateNumberTransformer.transform(source: dictionary[registrationCertificateNumberName])
        let keyCountResult = keyCountTransformer.transform(source: dictionary[keyCountName])
        let passportSeriesResult = passportSeriesTransformer.transform(source: dictionary[passportSeriesName])
        let passportNumberResult = passportNumberTransformer.transform(source: dictionary[passportNumberName])

        var errors: [(String, TransformerError)] = []
        registrationNumberResult.error.map { errors.append((registrationNumberName, $0)) }
        powerResult.error.map { errors.append((powerName, $0)) }
        vinResult.error.map { errors.append((vinName, $0)) }
        yearOfIssueResult.error.map { errors.append((yearOfIssueName, $0)) }
        registrationCertificateSeriesResult.error.map { errors.append((registrationCertificateSeriesName, $0)) }
        registrationCertificateNumberResult.error.map { errors.append((registrationCertificateNumberName, $0)) }
        keyCountResult.error.map { errors.append((keyCountName, $0)) }
        passportSeriesResult.error.map { errors.append((passportSeriesName, $0)) }
        passportNumberResult.error.map { errors.append((passportNumberName, $0)) }

        guard
            let registrationNumber = registrationNumberResult.value,
            let power = powerResult.value,
            let vin = vinResult.value,
            let yearOfIssue = yearOfIssueResult.value,
            let registrationCertificateSeries = registrationCertificateSeriesResult.value,
            let registrationCertificateNumber = registrationCertificateNumberResult.value,
            let keyCount = keyCountResult.value,
            let passportSeries = passportSeriesResult.value,
            let passportNumber = passportNumberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                registrationNumber: registrationNumber,
                power: power,
                vin: vin,
                yearOfIssue: yearOfIssue,
                registrationCertificateSeries: registrationCertificateSeries,
                registrationCertificateNumber: registrationCertificateNumber,
                keyCount: keyCount,
                passportSeries: passportSeries,
                passportNumber: passportNumber
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let registrationNumberResult = registrationNumberTransformer.transform(destination: value.registrationNumber)
        let powerResult = powerTransformer.transform(destination: value.power)
        let vinResult = vinTransformer.transform(destination: value.vin)
        let yearOfIssueResult = yearOfIssueTransformer.transform(destination: value.yearOfIssue)
        let registrationCertificateSeriesResult = registrationCertificateSeriesTransformer.transform(destination: value.registrationCertificateSeries)
        let registrationCertificateNumberResult = registrationCertificateNumberTransformer.transform(destination: value.registrationCertificateNumber)
        let keyCountResult = keyCountTransformer.transform(destination: value.keyCount)
        let passportSeriesResult = passportSeriesTransformer.transform(destination: value.passportSeries)
        let passportNumberResult = passportNumberTransformer.transform(destination: value.passportNumber)

        var errors: [(String, TransformerError)] = []
        registrationNumberResult.error.map { errors.append((registrationNumberName, $0)) }
        powerResult.error.map { errors.append((powerName, $0)) }
        vinResult.error.map { errors.append((vinName, $0)) }
        yearOfIssueResult.error.map { errors.append((yearOfIssueName, $0)) }
        registrationCertificateSeriesResult.error.map { errors.append((registrationCertificateSeriesName, $0)) }
        registrationCertificateNumberResult.error.map { errors.append((registrationCertificateNumberName, $0)) }
        keyCountResult.error.map { errors.append((keyCountName, $0)) }
        passportSeriesResult.error.map { errors.append((passportSeriesName, $0)) }
        passportNumberResult.error.map { errors.append((passportNumberName, $0)) }

        guard
            let registrationNumber = registrationNumberResult.value,
            let power = powerResult.value,
            let vin = vinResult.value,
            let yearOfIssue = yearOfIssueResult.value,
            let registrationCertificateSeries = registrationCertificateSeriesResult.value,
            let registrationCertificateNumber = registrationCertificateNumberResult.value,
            let keyCount = keyCountResult.value,
            let passportSeries = passportSeriesResult.value,
            let passportNumber = passportNumberResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[registrationNumberName] = registrationNumber
        dictionary[powerName] = power
        dictionary[vinName] = vin
        dictionary[yearOfIssueName] = yearOfIssue
        dictionary[registrationCertificateSeriesName] = registrationCertificateSeries
        dictionary[registrationCertificateNumberName] = registrationCertificateNumber
        dictionary[keyCountName] = keyCount
        dictionary[passportSeriesName] = passportSeries
        dictionary[passportNumberName] = passportNumber
        return .success(dictionary)
    }
}
