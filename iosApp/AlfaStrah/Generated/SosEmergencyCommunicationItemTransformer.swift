// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct SosEmergencyCommunicationItemTransformer: Transformer {
    typealias Source = Any
    typealias Destination = SosEmergencyCommunicationItem

    let iconName = "icon"
    let iconThemedName = "icon_themed"
    let rightIconName = "icon_call"
    let rightIconThemedName = "icon_call_themed"
    let titleName = "title"
    let titlePopupName = "title_popup"
    let phoneName = "phone"

    let iconTransformer = CastTransformer<Any, String>()
    let iconThemedTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let rightIconTransformer = CastTransformer<Any, String>()
    let rightIconThemedTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let titleTransformer = CastTransformer<Any, String>()
    let titlePopupTransformer = CastTransformer<Any, String>()
    let phoneTransformer = SosUXPhoneTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let iconResult = dictionary[iconName].map(iconTransformer.transform(source:)) ?? .failure(.requirement)
        let iconThemedResult = iconThemedTransformer.transform(source: dictionary[iconThemedName])
        let rightIconResult = dictionary[rightIconName].map(rightIconTransformer.transform(source:)) ?? .failure(.requirement)
        let rightIconThemedResult = rightIconThemedTransformer.transform(source: dictionary[rightIconThemedName])
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let titlePopupResult = dictionary[titlePopupName].map(titlePopupTransformer.transform(source:)) ?? .failure(.requirement)
        let phoneResult = dictionary[phoneName].map(phoneTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        iconResult.error.map { errors.append((iconName, $0)) }
        iconThemedResult.error.map { errors.append((iconThemedName, $0)) }
        rightIconResult.error.map { errors.append((rightIconName, $0)) }
        rightIconThemedResult.error.map { errors.append((rightIconThemedName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        titlePopupResult.error.map { errors.append((titlePopupName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }

        guard
            let icon = iconResult.value,
            let iconThemed = iconThemedResult.value,
            let rightIcon = rightIconResult.value,
            let rightIconThemed = rightIconThemedResult.value,
            let title = titleResult.value,
            let titlePopup = titlePopupResult.value,
            let phone = phoneResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                icon: icon,
                iconThemed: iconThemed,
                rightIcon: rightIcon,
                rightIconThemed: rightIconThemed,
                title: title,
                titlePopup: titlePopup,
                phone: phone
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let iconResult = iconTransformer.transform(destination: value.icon)
        let iconThemedResult = iconThemedTransformer.transform(destination: value.iconThemed)
        let rightIconResult = rightIconTransformer.transform(destination: value.rightIcon)
        let rightIconThemedResult = rightIconThemedTransformer.transform(destination: value.rightIconThemed)
        let titleResult = titleTransformer.transform(destination: value.title)
        let titlePopupResult = titlePopupTransformer.transform(destination: value.titlePopup)
        let phoneResult = phoneTransformer.transform(destination: value.phone)

        var errors: [(String, TransformerError)] = []
        iconResult.error.map { errors.append((iconName, $0)) }
        iconThemedResult.error.map { errors.append((iconThemedName, $0)) }
        rightIconResult.error.map { errors.append((rightIconName, $0)) }
        rightIconThemedResult.error.map { errors.append((rightIconThemedName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        titlePopupResult.error.map { errors.append((titlePopupName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }

        guard
            let icon = iconResult.value,
            let iconThemed = iconThemedResult.value,
            let rightIcon = rightIconResult.value,
            let rightIconThemed = rightIconThemedResult.value,
            let title = titleResult.value,
            let titlePopup = titlePopupResult.value,
            let phone = phoneResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[iconName] = icon
        dictionary[iconThemedName] = iconThemed
        dictionary[rightIconName] = rightIcon
        dictionary[rightIconThemedName] = rightIconThemed
        dictionary[titleName] = title
        dictionary[titlePopupName] = titlePopup
        dictionary[phoneName] = phone
        return .success(dictionary)
    }
}
