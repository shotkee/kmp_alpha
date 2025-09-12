// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryAdditionalInfoTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryAdditionalInfo

    let citizenshipName = "citizen_type"
    let snilsName = "snils_number"
    let innName = "inn_number"
    let migrationCardNumberName = "migration_card_number"
    let residentialAddressName = "residential_address"

    let citizenshipTransformer = DmsCostRecoveryAdditionalInfoСitizenshipTypeTransformer()
    let snilsTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let innTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let migrationCardNumberTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let residentialAddressTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let citizenshipResult = dictionary[citizenshipName].map(citizenshipTransformer.transform(source:)) ?? .failure(.requirement)
        let snilsResult = snilsTransformer.transform(source: dictionary[snilsName])
        let innResult = innTransformer.transform(source: dictionary[innName])
        let migrationCardNumberResult = migrationCardNumberTransformer.transform(source: dictionary[migrationCardNumberName])
        let residentialAddressResult = residentialAddressTransformer.transform(source: dictionary[residentialAddressName])

        var errors: [(String, TransformerError)] = []
        citizenshipResult.error.map { errors.append((citizenshipName, $0)) }
        snilsResult.error.map { errors.append((snilsName, $0)) }
        innResult.error.map { errors.append((innName, $0)) }
        migrationCardNumberResult.error.map { errors.append((migrationCardNumberName, $0)) }
        residentialAddressResult.error.map { errors.append((residentialAddressName, $0)) }

        guard
            let citizenship = citizenshipResult.value,
            let snils = snilsResult.value,
            let inn = innResult.value,
            let migrationCardNumber = migrationCardNumberResult.value,
            let residentialAddress = residentialAddressResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                citizenship: citizenship,
                snils: snils,
                inn: inn,
                migrationCardNumber: migrationCardNumber,
                residentialAddress: residentialAddress
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let citizenshipResult = citizenshipTransformer.transform(destination: value.citizenship)
        let snilsResult = snilsTransformer.transform(destination: value.snils)
        let innResult = innTransformer.transform(destination: value.inn)
        let migrationCardNumberResult = migrationCardNumberTransformer.transform(destination: value.migrationCardNumber)
        let residentialAddressResult = residentialAddressTransformer.transform(destination: value.residentialAddress)

        var errors: [(String, TransformerError)] = []
        citizenshipResult.error.map { errors.append((citizenshipName, $0)) }
        snilsResult.error.map { errors.append((snilsName, $0)) }
        innResult.error.map { errors.append((innName, $0)) }
        migrationCardNumberResult.error.map { errors.append((migrationCardNumberName, $0)) }
        residentialAddressResult.error.map { errors.append((residentialAddressName, $0)) }

        guard
            let citizenship = citizenshipResult.value,
            let snils = snilsResult.value,
            let inn = innResult.value,
            let migrationCardNumber = migrationCardNumberResult.value,
            let residentialAddress = residentialAddressResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[citizenshipName] = citizenship
        dictionary[snilsName] = snils
        dictionary[innName] = inn
        dictionary[migrationCardNumberName] = migrationCardNumber
        dictionary[residentialAddressName] = residentialAddress
        return .success(dictionary)
    }
}
