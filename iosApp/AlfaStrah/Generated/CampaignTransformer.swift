// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct CampaignTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Campaign

    let idName = "id"
    let titleName = "title"
    let annotationName = "annotation"
    let fullDescriptionName = "full_description"
    let imageUrlName = "image_url"
    let urlName = "url"
    let phoneName = "phone"
    let beginDateName = "begin_date"
    let endDateName = "end_date"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let annotationTransformer = CastTransformer<Any, String>()
    let fullDescriptionTransformer = CastTransformer<Any, String>()
    let imageUrlTransformer = CastTransformer<Any, String>()
    let urlTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())
    let phoneTransformer = PhoneTransformer()
    let beginDateTransformer = TimestampTransformer<Any>(scale: 1)
    let endDateTransformer = TimestampTransformer<Any>(scale: 1)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let annotationResult = dictionary[annotationName].map(annotationTransformer.transform(source:)) ?? .failure(.requirement)
        let fullDescriptionResult = dictionary[fullDescriptionName].map(fullDescriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let imageUrlResult = dictionary[imageUrlName].map(imageUrlTransformer.transform(source:)) ?? .failure(.requirement)
        let urlResult = urlTransformer.transform(source: dictionary[urlName])
        let phoneResult = dictionary[phoneName].map(phoneTransformer.transform(source:)) ?? .failure(.requirement)
        let beginDateResult = dictionary[beginDateName].map(beginDateTransformer.transform(source:)) ?? .failure(.requirement)
        let endDateResult = dictionary[endDateName].map(endDateTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        annotationResult.error.map { errors.append((annotationName, $0)) }
        fullDescriptionResult.error.map { errors.append((fullDescriptionName, $0)) }
        imageUrlResult.error.map { errors.append((imageUrlName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        beginDateResult.error.map { errors.append((beginDateName, $0)) }
        endDateResult.error.map { errors.append((endDateName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let annotation = annotationResult.value,
            let fullDescription = fullDescriptionResult.value,
            let imageUrl = imageUrlResult.value,
            let url = urlResult.value,
            let phone = phoneResult.value,
            let beginDate = beginDateResult.value,
            let endDate = endDateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                annotation: annotation,
                fullDescription: fullDescription,
                imageUrl: imageUrl,
                url: url,
                phone: phone,
                beginDate: beginDate,
                endDate: endDate
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let annotationResult = annotationTransformer.transform(destination: value.annotation)
        let fullDescriptionResult = fullDescriptionTransformer.transform(destination: value.fullDescription)
        let imageUrlResult = imageUrlTransformer.transform(destination: value.imageUrl)
        let urlResult = urlTransformer.transform(destination: value.url)
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let beginDateResult = beginDateTransformer.transform(destination: value.beginDate)
        let endDateResult = endDateTransformer.transform(destination: value.endDate)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        annotationResult.error.map { errors.append((annotationName, $0)) }
        fullDescriptionResult.error.map { errors.append((fullDescriptionName, $0)) }
        imageUrlResult.error.map { errors.append((imageUrlName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        beginDateResult.error.map { errors.append((beginDateName, $0)) }
        endDateResult.error.map { errors.append((endDateName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let annotation = annotationResult.value,
            let fullDescription = fullDescriptionResult.value,
            let imageUrl = imageUrlResult.value,
            let url = urlResult.value,
            let phone = phoneResult.value,
            let beginDate = beginDateResult.value,
            let endDate = endDateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[annotationName] = annotation
        dictionary[fullDescriptionName] = fullDescription
        dictionary[imageUrlName] = imageUrl
        dictionary[urlName] = url
        dictionary[phoneName] = phone
        dictionary[beginDateName] = beginDate
        dictionary[endDateName] = endDate
        return .success(dictionary)
    }
}
