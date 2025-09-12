// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct GuaranteeLetterTransformer: Transformer {
    typealias Source = Any
    typealias Destination = GuaranteeLetter

    let idName = "id"
    let clinicNameName = "clinic_title"
    let downloadUrlName = "download_url"
    let expirationDateTextName = "expiration_description"
    let issueDateTimeUtcName = "issued_datetime"
    let statusName = "status"
    let statusTextName = "status_text"

    let idTransformer = IdTransformer<Any>()
    let clinicNameTransformer = CastTransformer<Any, String>()
    let downloadUrlTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())
    let expirationDateTextTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let issueDateTimeUtcTransformer = DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)
    let statusTransformer = GuaranteeLetterStatusTransformer()
    let statusTextTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let clinicNameResult = dictionary[clinicNameName].map(clinicNameTransformer.transform(source:)) ?? .failure(.requirement)
        let downloadUrlResult = downloadUrlTransformer.transform(source: dictionary[downloadUrlName])
        let expirationDateTextResult = expirationDateTextTransformer.transform(source: dictionary[expirationDateTextName])
        let issueDateTimeUtcResult = dictionary[issueDateTimeUtcName].map(issueDateTimeUtcTransformer.transform(source:)) ?? .failure(.requirement)
        let statusResult = dictionary[statusName].map(statusTransformer.transform(source:)) ?? .failure(.requirement)
        let statusTextResult = statusTextTransformer.transform(source: dictionary[statusTextName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        clinicNameResult.error.map { errors.append((clinicNameName, $0)) }
        downloadUrlResult.error.map { errors.append((downloadUrlName, $0)) }
        expirationDateTextResult.error.map { errors.append((expirationDateTextName, $0)) }
        issueDateTimeUtcResult.error.map { errors.append((issueDateTimeUtcName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }
        statusTextResult.error.map { errors.append((statusTextName, $0)) }

        guard
            let id = idResult.value,
            let clinicName = clinicNameResult.value,
            let downloadUrl = downloadUrlResult.value,
            let expirationDateText = expirationDateTextResult.value,
            let issueDateTimeUtc = issueDateTimeUtcResult.value,
            let status = statusResult.value,
            let statusText = statusTextResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                clinicName: clinicName,
                downloadUrl: downloadUrl,
                expirationDateText: expirationDateText,
                issueDateTimeUtc: issueDateTimeUtc,
                status: status,
                statusText: statusText
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let clinicNameResult = clinicNameTransformer.transform(destination: value.clinicName)
        let downloadUrlResult = downloadUrlTransformer.transform(destination: value.downloadUrl)
        let expirationDateTextResult = expirationDateTextTransformer.transform(destination: value.expirationDateText)
        let issueDateTimeUtcResult = issueDateTimeUtcTransformer.transform(destination: value.issueDateTimeUtc)
        let statusResult = statusTransformer.transform(destination: value.status)
        let statusTextResult = statusTextTransformer.transform(destination: value.statusText)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        clinicNameResult.error.map { errors.append((clinicNameName, $0)) }
        downloadUrlResult.error.map { errors.append((downloadUrlName, $0)) }
        expirationDateTextResult.error.map { errors.append((expirationDateTextName, $0)) }
        issueDateTimeUtcResult.error.map { errors.append((issueDateTimeUtcName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }
        statusTextResult.error.map { errors.append((statusTextName, $0)) }

        guard
            let id = idResult.value,
            let clinicName = clinicNameResult.value,
            let downloadUrl = downloadUrlResult.value,
            let expirationDateText = expirationDateTextResult.value,
            let issueDateTimeUtc = issueDateTimeUtcResult.value,
            let status = statusResult.value,
            let statusText = statusTextResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[clinicNameName] = clinicName
        dictionary[downloadUrlName] = downloadUrl
        dictionary[expirationDateTextName] = expirationDateText
        dictionary[issueDateTimeUtcName] = issueDateTimeUtc
        dictionary[statusName] = status
        dictionary[statusTextName] = statusText
        return .success(dictionary)
    }
}
