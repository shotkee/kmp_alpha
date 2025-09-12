// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct DraftsCalculationsCategoryTransformer: Transformer {
    typealias Source = Any
    typealias Destination = DraftsCalculationsCategory

    let idName = "category_id"
    let iconName = "icon"
    let iconThemedName = "icon_themed"
    let titleInFiltersName = "title_in_filters"
    let titleName = "title"
    let draftsName = "draft_list"
    let shownInFiltersName = "show_in_filters"

    let idTransformer = NumberTransformer<Any, Int>()
    let iconTransformer = UrlTransformer<Any>()
    let iconThemedTransformer = OptionalTransformer(transformer: ThemedValueTransformer())
    let titleInFiltersTransformer = CastTransformer<Any, String>()
    let titleTransformer = CastTransformer<Any, String>()
    let draftsTransformer = ArrayTransformer(from: Any.self, transformer: DraftsCalculationsDataTransformer(), skipFailures: true)
    let shownInFiltersTransformer = NumberTransformer<Any, Bool>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let iconResult = dictionary[iconName].map(iconTransformer.transform(source:)) ?? .failure(.requirement)
        let iconThemedResult = iconThemedTransformer.transform(source: dictionary[iconThemedName])
        let titleInFiltersResult = dictionary[titleInFiltersName].map(titleInFiltersTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let draftsResult = dictionary[draftsName].map(draftsTransformer.transform(source:)) ?? .failure(.requirement)
        let shownInFiltersResult = dictionary[shownInFiltersName].map(shownInFiltersTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        iconResult.error.map { errors.append((iconName, $0)) }
        iconThemedResult.error.map { errors.append((iconThemedName, $0)) }
        titleInFiltersResult.error.map { errors.append((titleInFiltersName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        draftsResult.error.map { errors.append((draftsName, $0)) }
        shownInFiltersResult.error.map { errors.append((shownInFiltersName, $0)) }

        guard
            let id = idResult.value,
            let icon = iconResult.value,
            let iconThemed = iconThemedResult.value,
            let titleInFilters = titleInFiltersResult.value,
            let title = titleResult.value,
            let drafts = draftsResult.value,
            let shownInFilters = shownInFiltersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                icon: icon,
                iconThemed: iconThemed,
                titleInFilters: titleInFilters,
                title: title,
                drafts: drafts,
                shownInFilters: shownInFilters
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let iconResult = iconTransformer.transform(destination: value.icon)
        let iconThemedResult = iconThemedTransformer.transform(destination: value.iconThemed)
        let titleInFiltersResult = titleInFiltersTransformer.transform(destination: value.titleInFilters)
        let titleResult = titleTransformer.transform(destination: value.title)
        let draftsResult = draftsTransformer.transform(destination: value.drafts)
        let shownInFiltersResult = shownInFiltersTransformer.transform(destination: value.shownInFilters)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        iconResult.error.map { errors.append((iconName, $0)) }
        iconThemedResult.error.map { errors.append((iconThemedName, $0)) }
        titleInFiltersResult.error.map { errors.append((titleInFiltersName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        draftsResult.error.map { errors.append((draftsName, $0)) }
        shownInFiltersResult.error.map { errors.append((shownInFiltersName, $0)) }

        guard
            let id = idResult.value,
            let icon = iconResult.value,
            let iconThemed = iconThemedResult.value,
            let titleInFilters = titleInFiltersResult.value,
            let title = titleResult.value,
            let drafts = draftsResult.value,
            let shownInFilters = shownInFiltersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[iconName] = icon
        dictionary[iconThemedName] = iconThemed
        dictionary[titleInFiltersName] = titleInFilters
        dictionary[titleName] = title
        dictionary[draftsName] = drafts
        dictionary[shownInFiltersName] = shownInFilters
        return .success(dictionary)
    }
}
