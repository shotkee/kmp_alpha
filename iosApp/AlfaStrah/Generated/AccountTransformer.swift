// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct AccountTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Account

    let idName = "id"
    let firstNameName = "first_name"
    let lastNameName = "last_name"
    let patronymicName = "patronymic"
    let phoneName = "phone"
    let birthDateName = "birth_date"
    let emailName = "email"
    let unconfirmedPhoneName = "unconfirmed_phone"
    let unconfirmedEmailName = "unconfirmed_email"
    let isDemoName = "is_demo"
    let additionsName = "additions"
    let profileBannersName = "profile_banners"

    let idTransformer = IdTransformer<Any>()
    let firstNameTransformer = CastTransformer<Any, String>()
    let lastNameTransformer = CastTransformer<Any, String>()
    let patronymicTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let phoneTransformer = PhoneTransformer()
    let birthDateTransformer = TimestampTransformer<Any>(scale: 1)
    let emailTransformer = CastTransformer<Any, String>()
    let unconfirmedPhoneTransformer = OptionalTransformer(transformer: PhoneTransformer())
    let unconfirmedEmailTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let isDemoTransformer = AccountModeTransformer()
    let additionsTransformer = ArrayTransformer(from: Any.self, transformer: AccountAdditionAvailabiltyTransformer(), skipFailures: true)
    let profileBannersTransformer = ArrayTransformer(from: Any.self, transformer: BonusTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let firstNameResult = dictionary[firstNameName].map(firstNameTransformer.transform(source:)) ?? .failure(.requirement)
        let lastNameResult = dictionary[lastNameName].map(lastNameTransformer.transform(source:)) ?? .failure(.requirement)
        let patronymicResult = patronymicTransformer.transform(source: dictionary[patronymicName])
        let phoneResult = dictionary[phoneName].map(phoneTransformer.transform(source:)) ?? .failure(.requirement)
        let birthDateResult = dictionary[birthDateName].map(birthDateTransformer.transform(source:)) ?? .failure(.requirement)
        let emailResult = dictionary[emailName].map(emailTransformer.transform(source:)) ?? .failure(.requirement)
        let unconfirmedPhoneResult = unconfirmedPhoneTransformer.transform(source: dictionary[unconfirmedPhoneName])
        let unconfirmedEmailResult = unconfirmedEmailTransformer.transform(source: dictionary[unconfirmedEmailName])
        let isDemoResult = dictionary[isDemoName].map(isDemoTransformer.transform(source:)) ?? .failure(.requirement)
        let additionsResult = dictionary[additionsName].map(additionsTransformer.transform(source:)) ?? .failure(.requirement)
        let profileBannersResult = dictionary[profileBannersName].map(profileBannersTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        firstNameResult.error.map { errors.append((firstNameName, $0)) }
        lastNameResult.error.map { errors.append((lastNameName, $0)) }
        patronymicResult.error.map { errors.append((patronymicName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        birthDateResult.error.map { errors.append((birthDateName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }
        unconfirmedPhoneResult.error.map { errors.append((unconfirmedPhoneName, $0)) }
        unconfirmedEmailResult.error.map { errors.append((unconfirmedEmailName, $0)) }
        isDemoResult.error.map { errors.append((isDemoName, $0)) }
        additionsResult.error.map { errors.append((additionsName, $0)) }
        profileBannersResult.error.map { errors.append((profileBannersName, $0)) }

        guard
            let id = idResult.value,
            let firstName = firstNameResult.value,
            let lastName = lastNameResult.value,
            let patronymic = patronymicResult.value,
            let phone = phoneResult.value,
            let birthDate = birthDateResult.value,
            let email = emailResult.value,
            let unconfirmedPhone = unconfirmedPhoneResult.value,
            let unconfirmedEmail = unconfirmedEmailResult.value,
            let isDemo = isDemoResult.value,
            let additions = additionsResult.value,
            let profileBanners = profileBannersResult.value,
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
                phone: phone,
                birthDate: birthDate,
                email: email,
                unconfirmedPhone: unconfirmedPhone,
                unconfirmedEmail: unconfirmedEmail,
                isDemo: isDemo,
                additions: additions,
                profileBanners: profileBanners
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let firstNameResult = firstNameTransformer.transform(destination: value.firstName)
        let lastNameResult = lastNameTransformer.transform(destination: value.lastName)
        let patronymicResult = patronymicTransformer.transform(destination: value.patronymic)
        let phoneResult = phoneTransformer.transform(destination: value.phone)
        let birthDateResult = birthDateTransformer.transform(destination: value.birthDate)
        let emailResult = emailTransformer.transform(destination: value.email)
        let unconfirmedPhoneResult = unconfirmedPhoneTransformer.transform(destination: value.unconfirmedPhone)
        let unconfirmedEmailResult = unconfirmedEmailTransformer.transform(destination: value.unconfirmedEmail)
        let isDemoResult = isDemoTransformer.transform(destination: value.isDemo)
        let additionsResult = additionsTransformer.transform(destination: value.additions)
        let profileBannersResult = profileBannersTransformer.transform(destination: value.profileBanners)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        firstNameResult.error.map { errors.append((firstNameName, $0)) }
        lastNameResult.error.map { errors.append((lastNameName, $0)) }
        patronymicResult.error.map { errors.append((patronymicName, $0)) }
        phoneResult.error.map { errors.append((phoneName, $0)) }
        birthDateResult.error.map { errors.append((birthDateName, $0)) }
        emailResult.error.map { errors.append((emailName, $0)) }
        unconfirmedPhoneResult.error.map { errors.append((unconfirmedPhoneName, $0)) }
        unconfirmedEmailResult.error.map { errors.append((unconfirmedEmailName, $0)) }
        isDemoResult.error.map { errors.append((isDemoName, $0)) }
        additionsResult.error.map { errors.append((additionsName, $0)) }
        profileBannersResult.error.map { errors.append((profileBannersName, $0)) }

        guard
            let id = idResult.value,
            let firstName = firstNameResult.value,
            let lastName = lastNameResult.value,
            let patronymic = patronymicResult.value,
            let phone = phoneResult.value,
            let birthDate = birthDateResult.value,
            let email = emailResult.value,
            let unconfirmedPhone = unconfirmedPhoneResult.value,
            let unconfirmedEmail = unconfirmedEmailResult.value,
            let isDemo = isDemoResult.value,
            let additions = additionsResult.value,
            let profileBanners = profileBannersResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[firstNameName] = firstName
        dictionary[lastNameName] = lastName
        dictionary[patronymicName] = patronymic
        dictionary[phoneName] = phone
        dictionary[birthDateName] = birthDate
        dictionary[emailName] = email
        dictionary[unconfirmedPhoneName] = unconfirmedPhone
        dictionary[unconfirmedEmailName] = unconfirmedEmail
        dictionary[isDemoName] = isDemo
        dictionary[additionsName] = additions
        dictionary[profileBannersName] = profileBanners
        return .success(dictionary)
    }
}
