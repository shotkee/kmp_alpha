// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceDeeplinkTypeTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceDeeplinkType

    let idName = "id"
    let titleName = "title"
    let categoryIdName = "category_id"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let categoryIdTransformer = IdTransformer<Any>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let categoryIdResult = dictionary[categoryIdName].map(categoryIdTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        categoryIdResult.error.map { errors.append((categoryIdName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let categoryId = categoryIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                categoryId: categoryId
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let categoryIdResult = categoryIdTransformer.transform(destination: value.categoryId)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        categoryIdResult.error.map { errors.append((categoryIdName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let categoryId = categoryIdResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[categoryIdName] = categoryId
        return .success(dictionary)
    }
}
