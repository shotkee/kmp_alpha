// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct MedicalCardFileTransformer: Transformer {
    typealias Source = Any
    typealias Destination = MedicalCardFile

    let idName = "file_id"
    let creationDateName = "datetime_created"
    let nameName = "title"
    let statusName = "status"
    let sizeInBytesName = "size"
    let fileExtensionName = "title_extension"

    let idTransformer = NumberTransformer<Any, Int64>()
    let creationDateTransformer = DateTransformer<Any>()
    let nameTransformer = CastTransformer<Any, String>()
    let statusTransformer = MedicalCardFileStatusTransformer()
    let sizeInBytesTransformer = NumberTransformer<Any, Int>()
    let fileExtensionTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let creationDateResult = dictionary[creationDateName].map(creationDateTransformer.transform(source:)) ?? .failure(.requirement)
        let nameResult = dictionary[nameName].map(nameTransformer.transform(source:)) ?? .failure(.requirement)
        let statusResult = dictionary[statusName].map(statusTransformer.transform(source:)) ?? .failure(.requirement)
        let sizeInBytesResult = dictionary[sizeInBytesName].map(sizeInBytesTransformer.transform(source:)) ?? .failure(.requirement)
        let fileExtensionResult = fileExtensionTransformer.transform(source: dictionary[fileExtensionName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        creationDateResult.error.map { errors.append((creationDateName, $0)) }
        nameResult.error.map { errors.append((nameName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }
        sizeInBytesResult.error.map { errors.append((sizeInBytesName, $0)) }
        fileExtensionResult.error.map { errors.append((fileExtensionName, $0)) }

        guard
            let id = idResult.value,
            let creationDate = creationDateResult.value,
            let name = nameResult.value,
            let status = statusResult.value,
            let sizeInBytes = sizeInBytesResult.value,
            let fileExtension = fileExtensionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                creationDate: creationDate,
                name: name,
                status: status,
                sizeInBytes: sizeInBytes,
                fileExtension: fileExtension
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let creationDateResult = creationDateTransformer.transform(destination: value.creationDate)
        let nameResult = nameTransformer.transform(destination: value.name)
        let statusResult = statusTransformer.transform(destination: value.status)
        let sizeInBytesResult = sizeInBytesTransformer.transform(destination: value.sizeInBytes)
        let fileExtensionResult = fileExtensionTransformer.transform(destination: value.fileExtension)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        creationDateResult.error.map { errors.append((creationDateName, $0)) }
        nameResult.error.map { errors.append((nameName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }
        sizeInBytesResult.error.map { errors.append((sizeInBytesName, $0)) }
        fileExtensionResult.error.map { errors.append((fileExtensionName, $0)) }

        guard
            let id = idResult.value,
            let creationDate = creationDateResult.value,
            let name = nameResult.value,
            let status = statusResult.value,
            let sizeInBytes = sizeInBytesResult.value,
            let fileExtension = fileExtensionResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[creationDateName] = creationDate
        dictionary[nameName] = name
        dictionary[statusName] = status
        dictionary[sizeInBytesName] = sizeInBytes
        dictionary[fileExtensionName] = fileExtension
        return .success(dictionary)
    }
}
