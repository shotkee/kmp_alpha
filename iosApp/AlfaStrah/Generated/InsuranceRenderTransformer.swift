// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceRenderTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceRender

    let methodName = "method"
    let postBodyName = "postBody"
    let typeName = "type"
    let urlName = "url"
    let headersName = "headers"

    let methodTransformer = MethodTransformer()
    let postBodyTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let typeTransformer = BackendComponentTypeTransformer()
    let urlTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())
    let headersTransformer = ArrayTransformer(from: Any.self, transformer: InsuranceRenderHeaderTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let methodResult = dictionary[methodName].map(methodTransformer.transform(source:)) ?? .failure(.requirement)
        let postBodyResult = postBodyTransformer.transform(source: dictionary[postBodyName])
        let typeResult = dictionary[typeName].map(typeTransformer.transform(source:)) ?? .failure(.requirement)
        let urlResult = urlTransformer.transform(source: dictionary[urlName])
        let headersResult = dictionary[headersName].map(headersTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        methodResult.error.map { errors.append((methodName, $0)) }
        postBodyResult.error.map { errors.append((postBodyName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }
        headersResult.error.map { errors.append((headersName, $0)) }

        guard
            let method = methodResult.value,
            let postBody = postBodyResult.value,
            let type = typeResult.value,
            let url = urlResult.value,
            let headers = headersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                method: method,
                postBody: postBody,
                type: type,
                url: url,
                headers: headers
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let methodResult = methodTransformer.transform(destination: value.method)
        let postBodyResult = postBodyTransformer.transform(destination: value.postBody)
        let typeResult = typeTransformer.transform(destination: value.type)
        let urlResult = urlTransformer.transform(destination: value.url)
        let headersResult = headersTransformer.transform(destination: value.headers)

        var errors: [(String, TransformerError)] = []
        methodResult.error.map { errors.append((methodName, $0)) }
        postBodyResult.error.map { errors.append((postBodyName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        urlResult.error.map { errors.append((urlName, $0)) }
        headersResult.error.map { errors.append((headersName, $0)) }

        guard
            let method = methodResult.value,
            let postBody = postBodyResult.value,
            let type = typeResult.value,
            let url = urlResult.value,
            let headers = headersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[methodName] = method
        dictionary[postBodyName] = postBody
        dictionary[typeName] = type
        dictionary[urlName] = url
        dictionary[headersName] = headers
        return .success(dictionary)
    }
}
