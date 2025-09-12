// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct SosActivityModelTransformer: Transformer {
    typealias Source = Any
    typealias Destination = SosActivityModel

    let kindName = "id"
    let titleName = "title"
    let descriptionName = "description"
    let sosPhoneListName = "sos_phone_list"
    let insuranceIdListName = "insurance_id_list"

    let kindTransformer = SOSActivityKindTransformer()
    let titleTransformer = CastTransformer<Any, String>()
    let descriptionTransformer = CastTransformer<Any, String>()
    let sosPhoneListTransformer = ArrayTransformer(from: Any.self, transformer: SosPhoneTransformer(), skipFailures: true)
    let insuranceIdListTransformer = ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let kindResult = dictionary[kindName].map(kindTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let descriptionResult = dictionary[descriptionName].map(descriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let sosPhoneListResult = dictionary[sosPhoneListName].map(sosPhoneListTransformer.transform(source:)) ?? .failure(.requirement)
        let insuranceIdListResult = dictionary[insuranceIdListName].map(insuranceIdListTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        kindResult.error.map { errors.append((kindName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        sosPhoneListResult.error.map { errors.append((sosPhoneListName, $0)) }
        insuranceIdListResult.error.map { errors.append((insuranceIdListName, $0)) }

        guard
            let kind = kindResult.value,
            let title = titleResult.value,
            let description = descriptionResult.value,
            let sosPhoneList = sosPhoneListResult.value,
            let insuranceIdList = insuranceIdListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                kind: kind,
                title: title,
                description: description,
                sosPhoneList: sosPhoneList,
                insuranceIdList: insuranceIdList
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let kindResult = kindTransformer.transform(destination: value.kind)
        let titleResult = titleTransformer.transform(destination: value.title)
        let descriptionResult = descriptionTransformer.transform(destination: value.description)
        let sosPhoneListResult = sosPhoneListTransformer.transform(destination: value.sosPhoneList)
        let insuranceIdListResult = insuranceIdListTransformer.transform(destination: value.insuranceIdList)

        var errors: [(String, TransformerError)] = []
        kindResult.error.map { errors.append((kindName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        sosPhoneListResult.error.map { errors.append((sosPhoneListName, $0)) }
        insuranceIdListResult.error.map { errors.append((insuranceIdListName, $0)) }

        guard
            let kind = kindResult.value,
            let title = titleResult.value,
            let description = descriptionResult.value,
            let sosPhoneList = sosPhoneListResult.value,
            let insuranceIdList = insuranceIdListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[kindName] = kind
        dictionary[titleName] = title
        dictionary[descriptionName] = description
        dictionary[sosPhoneListName] = sosPhoneList
        dictionary[insuranceIdListName] = insuranceIdList
        return .success(dictionary)
    }
}
