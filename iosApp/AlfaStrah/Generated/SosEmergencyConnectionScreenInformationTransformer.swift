// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct SosEmergencyConnectionScreenInformationTransformer: Transformer {
    typealias Source = Any
    typealias Destination = SosEmergencyConnectionScreenInformation

    let titleName = "title"
    let iconName = "icon"
    let iconThemedName = "icon_themed"

    let titleTransformer = CastTransformer<Any, String>()
    let iconTransformer = CastTransformer<Any, String>()
    let iconThemedTransformer = OptionalTransformer(transformer: ThemedValueTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let iconResult = dictionary[iconName].map(iconTransformer.transform(source:)) ?? .failure(.requirement)
        let iconThemedResult = iconThemedTransformer.transform(source: dictionary[iconThemedName])

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        iconResult.error.map { errors.append((iconName, $0)) }
        iconThemedResult.error.map { errors.append((iconThemedName, $0)) }

        guard
            let title = titleResult.value,
            let icon = iconResult.value,
            let iconThemed = iconThemedResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                icon: icon,
                iconThemed: iconThemed
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let iconResult = iconTransformer.transform(destination: value.icon)
        let iconThemedResult = iconThemedTransformer.transform(destination: value.iconThemed)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        iconResult.error.map { errors.append((iconName, $0)) }
        iconThemedResult.error.map { errors.append((iconThemedName, $0)) }

        guard
            let title = titleResult.value,
            let icon = iconResult.value,
            let iconThemed = iconThemedResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[iconName] = icon
        dictionary[iconThemedName] = iconThemed
        return .success(dictionary)
    }
}
