// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct FranchiseTransitionDataTransformer: Transformer {
    typealias Source = Any
    typealias Destination = FranchiseTransitionData

    let personsName = "persons"
    let hasPdfWithProgramTermsName = "has_program_terms_pdf"
    let programTermsButtonTitleName = "terms_message"
    let promptTextName = "invitation_message"
    let confirmationTextName = "approval_message"

    let personsTransformer = ArrayTransformer(from: Any.self, transformer: FranchiseTransitionInsuredPersonTransformer(), skipFailures: true)
    let hasPdfWithProgramTermsTransformer = NumberTransformer<Any, Bool>()
    let programTermsButtonTitleTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let promptTextTransformer = CastTransformer<Any, String>()
    let confirmationTextTransformer = CastTransformer<Any, String>()

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let personsResult = dictionary[personsName].map(personsTransformer.transform(source:)) ?? .failure(.requirement)
        let hasPdfWithProgramTermsResult = dictionary[hasPdfWithProgramTermsName].map(hasPdfWithProgramTermsTransformer.transform(source:)) ?? .failure(.requirement)
        let programTermsButtonTitleResult = programTermsButtonTitleTransformer.transform(source: dictionary[programTermsButtonTitleName])
        let promptTextResult = dictionary[promptTextName].map(promptTextTransformer.transform(source:)) ?? .failure(.requirement)
        let confirmationTextResult = dictionary[confirmationTextName].map(confirmationTextTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        personsResult.error.map { errors.append((personsName, $0)) }
        hasPdfWithProgramTermsResult.error.map { errors.append((hasPdfWithProgramTermsName, $0)) }
        programTermsButtonTitleResult.error.map { errors.append((programTermsButtonTitleName, $0)) }
        promptTextResult.error.map { errors.append((promptTextName, $0)) }
        confirmationTextResult.error.map { errors.append((confirmationTextName, $0)) }

        guard
            let persons = personsResult.value,
            let hasPdfWithProgramTerms = hasPdfWithProgramTermsResult.value,
            let programTermsButtonTitle = programTermsButtonTitleResult.value,
            let promptText = promptTextResult.value,
            let confirmationText = confirmationTextResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                persons: persons,
                hasPdfWithProgramTerms: hasPdfWithProgramTerms,
                programTermsButtonTitle: programTermsButtonTitle,
                promptText: promptText,
                confirmationText: confirmationText
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let personsResult = personsTransformer.transform(destination: value.persons)
        let hasPdfWithProgramTermsResult = hasPdfWithProgramTermsTransformer.transform(destination: value.hasPdfWithProgramTerms)
        let programTermsButtonTitleResult = programTermsButtonTitleTransformer.transform(destination: value.programTermsButtonTitle)
        let promptTextResult = promptTextTransformer.transform(destination: value.promptText)
        let confirmationTextResult = confirmationTextTransformer.transform(destination: value.confirmationText)

        var errors: [(String, TransformerError)] = []
        personsResult.error.map { errors.append((personsName, $0)) }
        hasPdfWithProgramTermsResult.error.map { errors.append((hasPdfWithProgramTermsName, $0)) }
        programTermsButtonTitleResult.error.map { errors.append((programTermsButtonTitleName, $0)) }
        promptTextResult.error.map { errors.append((promptTextName, $0)) }
        confirmationTextResult.error.map { errors.append((confirmationTextName, $0)) }

        guard
            let persons = personsResult.value,
            let hasPdfWithProgramTerms = hasPdfWithProgramTermsResult.value,
            let programTermsButtonTitle = programTermsButtonTitleResult.value,
            let promptText = promptTextResult.value,
            let confirmationText = confirmationTextResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[personsName] = persons
        dictionary[hasPdfWithProgramTermsName] = hasPdfWithProgramTerms
        dictionary[programTermsButtonTitleName] = programTermsButtonTitle
        dictionary[promptTextName] = promptText
        dictionary[confirmationTextName] = confirmationText
        return .success(dictionary)
    }
}
