// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct StoryTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Story

    let idName = "story_id"
    let titleName = "title"
    let titleColorName = "title_color"
    let previewName = "preview"
    let pageListName = "page_list"
    let statusName = "status"

    let idTransformer = NumberTransformer<Any, Int>()
    let titleTransformer = CastTransformer<Any, String>()
    let titleColorTransformer = CastTransformer<Any, String>()
    let previewTransformer = UrlTransformer<Any>()
    let pageListTransformer = ArrayTransformer(from: Any.self, transformer: StoryPageTransformer(), skipFailures: true)
    let statusTransformer = StoryStatusTransformer()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let titleColorResult = dictionary[titleColorName].map(titleColorTransformer.transform(source:)) ?? .failure(.requirement)
        let previewResult = dictionary[previewName].map(previewTransformer.transform(source:)) ?? .failure(.requirement)
        let pageListResult = dictionary[pageListName].map(pageListTransformer.transform(source:)) ?? .failure(.requirement)
        let statusResult = dictionary[statusName].map(statusTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        titleColorResult.error.map { errors.append((titleColorName, $0)) }
        previewResult.error.map { errors.append((previewName, $0)) }
        pageListResult.error.map { errors.append((pageListName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let titleColor = titleColorResult.value,
            let preview = previewResult.value,
            let pageList = pageListResult.value,
            let status = statusResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                titleColor: titleColor,
                preview: preview,
                pageList: pageList,
                status: status
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let titleColorResult = titleColorTransformer.transform(destination: value.titleColor)
        let previewResult = previewTransformer.transform(destination: value.preview)
        let pageListResult = pageListTransformer.transform(destination: value.pageList)
        let statusResult = statusTransformer.transform(destination: value.status)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        titleColorResult.error.map { errors.append((titleColorName, $0)) }
        previewResult.error.map { errors.append((previewName, $0)) }
        pageListResult.error.map { errors.append((pageListName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let titleColor = titleColorResult.value,
            let preview = previewResult.value,
            let pageList = pageListResult.value,
            let status = statusResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[titleColorName] = titleColor
        dictionary[previewName] = preview
        dictionary[pageListName] = pageList
        dictionary[statusName] = status
        return .success(dictionary)
    }
}
