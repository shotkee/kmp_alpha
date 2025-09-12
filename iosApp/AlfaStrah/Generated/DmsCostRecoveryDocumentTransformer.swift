// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DmsCostRecoveryDocumentTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DmsCostRecoveryDocument

    let titleName = "title"
    let uploadNameName = "value"
    let isRequiredName = "is_required"
    let isMultiselectAllowedName = "is_multiselect_allowed"

    let titleTransformer = CastTransformer<Any, String>()
    let uploadNameTransformer = CastTransformer<Any, String>()
    let isRequiredTransformer = NumberTransformer<Any, Bool>()
    let isMultiselectAllowedTransformer = NumberTransformer<Any, Bool>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let uploadNameResult = dictionary[uploadNameName].map(uploadNameTransformer.transform(source:)) ?? .failure(.requirement)
        let isRequiredResult = dictionary[isRequiredName].map(isRequiredTransformer.transform(source:)) ?? .failure(.requirement)
        let isMultiselectAllowedResult = dictionary[isMultiselectAllowedName].map(isMultiselectAllowedTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        uploadNameResult.error.map { errors.append((uploadNameName, $0)) }
        isRequiredResult.error.map { errors.append((isRequiredName, $0)) }
        isMultiselectAllowedResult.error.map { errors.append((isMultiselectAllowedName, $0)) }

        guard
            let title = titleResult.value,
            let uploadName = uploadNameResult.value,
            let isRequired = isRequiredResult.value,
            let isMultiselectAllowed = isMultiselectAllowedResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                uploadName: uploadName,
                isRequired: isRequired,
                isMultiselectAllowed: isMultiselectAllowed
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let uploadNameResult = uploadNameTransformer.transform(destination: value.uploadName)
        let isRequiredResult = isRequiredTransformer.transform(destination: value.isRequired)
        let isMultiselectAllowedResult = isMultiselectAllowedTransformer.transform(destination: value.isMultiselectAllowed)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        uploadNameResult.error.map { errors.append((uploadNameName, $0)) }
        isRequiredResult.error.map { errors.append((isRequiredName, $0)) }
        isMultiselectAllowedResult.error.map { errors.append((isMultiselectAllowedName, $0)) }

        guard
            let title = titleResult.value,
            let uploadName = uploadNameResult.value,
            let isRequired = isRequiredResult.value,
            let isMultiselectAllowed = isMultiselectAllowedResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[uploadNameName] = uploadName
        dictionary[isRequiredName] = isRequired
        dictionary[isMultiselectAllowedName] = isMultiselectAllowed
        return .success(dictionary)
    }
}
