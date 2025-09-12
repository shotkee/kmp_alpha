// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct EventStatusTransformer: Transformer {
    typealias Source = Any
    typealias Destination = EventStatus

    let idName = "id"
    let sortNumberName = "sort_number"
    let dateName = "date"
    let decisionName = "decision"
    let passedName = "passed"
    let stoaName = "stoa"
    let imageUrlName = "image_url"
    let titleName = "title"
    let shortDescriptionName = "short_description"

    let idTransformer = IdTransformer<Any>()
    let sortNumberTransformer = NumberTransformer<Any, Int>()
    let dateTransformer = OptionalTransformer(transformer: TimestampTransformer<Any>(scale: 1))
    let decisionTransformer = OptionalTransformer(transformer: EventDecisionTransformer())
    let passedTransformer = NumberTransformer<Any, Bool>()
    let stoaTransformer = OptionalTransformer(transformer: StoaTransformer())
    let imageUrlTransformer = UrlTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let shortDescriptionTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let sortNumberResult = dictionary[sortNumberName].map(sortNumberTransformer.transform(source:)) ?? .failure(.requirement)
        let dateResult = dateTransformer.transform(source: dictionary[dateName])
        let decisionResult = decisionTransformer.transform(source: dictionary[decisionName])
        let passedResult = dictionary[passedName].map(passedTransformer.transform(source:)) ?? .failure(.requirement)
        let stoaResult = stoaTransformer.transform(source: dictionary[stoaName])
        let imageUrlResult = dictionary[imageUrlName].map(imageUrlTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let shortDescriptionResult = dictionary[shortDescriptionName].map(shortDescriptionTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        sortNumberResult.error.map { errors.append((sortNumberName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        decisionResult.error.map { errors.append((decisionName, $0)) }
        passedResult.error.map { errors.append((passedName, $0)) }
        stoaResult.error.map { errors.append((stoaName, $0)) }
        imageUrlResult.error.map { errors.append((imageUrlName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        shortDescriptionResult.error.map { errors.append((shortDescriptionName, $0)) }

        guard
            let id = idResult.value,
            let sortNumber = sortNumberResult.value,
            let date = dateResult.value,
            let decision = decisionResult.value,
            let passed = passedResult.value,
            let stoa = stoaResult.value,
            let imageUrl = imageUrlResult.value,
            let title = titleResult.value,
            let shortDescription = shortDescriptionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                sortNumber: sortNumber,
                date: date,
                decision: decision,
                passed: passed,
                stoa: stoa,
                imageUrl: imageUrl,
                title: title,
                shortDescription: shortDescription
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let sortNumberResult = sortNumberTransformer.transform(destination: value.sortNumber)
        let dateResult = dateTransformer.transform(destination: value.date)
        let decisionResult = decisionTransformer.transform(destination: value.decision)
        let passedResult = passedTransformer.transform(destination: value.passed)
        let stoaResult = stoaTransformer.transform(destination: value.stoa)
        let imageUrlResult = imageUrlTransformer.transform(destination: value.imageUrl)
        let titleResult = titleTransformer.transform(destination: value.title)
        let shortDescriptionResult = shortDescriptionTransformer.transform(destination: value.shortDescription)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        sortNumberResult.error.map { errors.append((sortNumberName, $0)) }
        dateResult.error.map { errors.append((dateName, $0)) }
        decisionResult.error.map { errors.append((decisionName, $0)) }
        passedResult.error.map { errors.append((passedName, $0)) }
        stoaResult.error.map { errors.append((stoaName, $0)) }
        imageUrlResult.error.map { errors.append((imageUrlName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        shortDescriptionResult.error.map { errors.append((shortDescriptionName, $0)) }

        guard
            let id = idResult.value,
            let sortNumber = sortNumberResult.value,
            let date = dateResult.value,
            let decision = decisionResult.value,
            let passed = passedResult.value,
            let stoa = stoaResult.value,
            let imageUrl = imageUrlResult.value,
            let title = titleResult.value,
            let shortDescription = shortDescriptionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[sortNumberName] = sortNumber
        dictionary[dateName] = date
        dictionary[decisionName] = decision
        dictionary[passedName] = passed
        dictionary[stoaName] = stoa
        dictionary[imageUrlName] = imageUrl
        dictionary[titleName] = title
        dictionary[shortDescriptionName] = shortDescription
        return .success(dictionary)
    }
}
