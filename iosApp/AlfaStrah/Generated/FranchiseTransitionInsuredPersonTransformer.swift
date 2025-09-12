// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct FranchiseTransitionInsuredPersonTransformer: Transformer {
    typealias Source = Any
    typealias Destination = FranchiseTransitionInsuredPerson

    let idName = "id"
    let firstNameName = "first_name"
    let lastNameName = "last_name"
    let patronymicName = "patronymic"
    let hasProgramPdfName = "has_program_pdf"
    let hasClinicsPdfName = "has_clinics_pdf"
    let isCheckedByDefaultName = "is_checked"
    let isCheckboxReadonlyName = "is_readonly"

    let idTransformer = NumberTransformer<Any, Int>()
    let firstNameTransformer = CastTransformer<Any, String>()
    let lastNameTransformer = CastTransformer<Any, String>()
    let patronymicTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let hasProgramPdfTransformer = NumberTransformer<Any, Bool>()
    let hasClinicsPdfTransformer = NumberTransformer<Any, Bool>()
    let isCheckedByDefaultTransformer = NumberTransformer<Any, Bool>()
    let isCheckboxReadonlyTransformer = NumberTransformer<Any, Bool>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let firstNameResult = dictionary[firstNameName].map(firstNameTransformer.transform(source:)) ?? .failure(.requirement)
        let lastNameResult = dictionary[lastNameName].map(lastNameTransformer.transform(source:)) ?? .failure(.requirement)
        let patronymicResult = patronymicTransformer.transform(source: dictionary[patronymicName])
        let hasProgramPdfResult = dictionary[hasProgramPdfName].map(hasProgramPdfTransformer.transform(source:)) ?? .failure(.requirement)
        let hasClinicsPdfResult = dictionary[hasClinicsPdfName].map(hasClinicsPdfTransformer.transform(source:)) ?? .failure(.requirement)
        let isCheckedByDefaultResult = dictionary[isCheckedByDefaultName].map(isCheckedByDefaultTransformer.transform(source:)) ?? .failure(.requirement)
        let isCheckboxReadonlyResult = dictionary[isCheckboxReadonlyName].map(isCheckboxReadonlyTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        firstNameResult.error.map { errors.append((firstNameName, $0)) }
        lastNameResult.error.map { errors.append((lastNameName, $0)) }
        patronymicResult.error.map { errors.append((patronymicName, $0)) }
        hasProgramPdfResult.error.map { errors.append((hasProgramPdfName, $0)) }
        hasClinicsPdfResult.error.map { errors.append((hasClinicsPdfName, $0)) }
        isCheckedByDefaultResult.error.map { errors.append((isCheckedByDefaultName, $0)) }
        isCheckboxReadonlyResult.error.map { errors.append((isCheckboxReadonlyName, $0)) }

        guard
            let id = idResult.value,
            let firstName = firstNameResult.value,
            let lastName = lastNameResult.value,
            let patronymic = patronymicResult.value,
            let hasProgramPdf = hasProgramPdfResult.value,
            let hasClinicsPdf = hasClinicsPdfResult.value,
            let isCheckedByDefault = isCheckedByDefaultResult.value,
            let isCheckboxReadonly = isCheckboxReadonlyResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                firstName: firstName,
                lastName: lastName,
                patronymic: patronymic,
                hasProgramPdf: hasProgramPdf,
                hasClinicsPdf: hasClinicsPdf,
                isCheckedByDefault: isCheckedByDefault,
                isCheckboxReadonly: isCheckboxReadonly
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let firstNameResult = firstNameTransformer.transform(destination: value.firstName)
        let lastNameResult = lastNameTransformer.transform(destination: value.lastName)
        let patronymicResult = patronymicTransformer.transform(destination: value.patronymic)
        let hasProgramPdfResult = hasProgramPdfTransformer.transform(destination: value.hasProgramPdf)
        let hasClinicsPdfResult = hasClinicsPdfTransformer.transform(destination: value.hasClinicsPdf)
        let isCheckedByDefaultResult = isCheckedByDefaultTransformer.transform(destination: value.isCheckedByDefault)
        let isCheckboxReadonlyResult = isCheckboxReadonlyTransformer.transform(destination: value.isCheckboxReadonly)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        firstNameResult.error.map { errors.append((firstNameName, $0)) }
        lastNameResult.error.map { errors.append((lastNameName, $0)) }
        patronymicResult.error.map { errors.append((patronymicName, $0)) }
        hasProgramPdfResult.error.map { errors.append((hasProgramPdfName, $0)) }
        hasClinicsPdfResult.error.map { errors.append((hasClinicsPdfName, $0)) }
        isCheckedByDefaultResult.error.map { errors.append((isCheckedByDefaultName, $0)) }
        isCheckboxReadonlyResult.error.map { errors.append((isCheckboxReadonlyName, $0)) }

        guard
            let id = idResult.value,
            let firstName = firstNameResult.value,
            let lastName = lastNameResult.value,
            let patronymic = patronymicResult.value,
            let hasProgramPdf = hasProgramPdfResult.value,
            let hasClinicsPdf = hasClinicsPdfResult.value,
            let isCheckedByDefault = isCheckedByDefaultResult.value,
            let isCheckboxReadonly = isCheckboxReadonlyResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[firstNameName] = firstName
        dictionary[lastNameName] = lastName
        dictionary[patronymicName] = patronymic
        dictionary[hasProgramPdfName] = hasProgramPdf
        dictionary[hasClinicsPdfName] = hasClinicsPdf
        dictionary[isCheckedByDefaultName] = isCheckedByDefault
        dictionary[isCheckboxReadonlyName] = isCheckboxReadonly
        return .success(dictionary)
    }
}
