// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct FullDoctorTransformer: Transformer {
    typealias Source = Any
    typealias Destination = FullDoctor

    let idName = "id"
    let titleName = "title"
    let specialityName = "doctor_speciality"
    let photoUrlName = "photo_url"
    let yearsOfExperienceName = "experience_years"
    let experienceName = "experience_description"
    let schedulesName = "interval_dates"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let specialityTransformer = DoctorSpecialityTransformer()
    let photoUrlTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())
    let yearsOfExperienceTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Int>())
    let experienceTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let schedulesTransformer = ArrayTransformer(from: Any.self, transformer: DoctorScheduleTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let specialityResult = dictionary[specialityName].map(specialityTransformer.transform(source:)) ?? .failure(.requirement)
        let photoUrlResult = photoUrlTransformer.transform(source: dictionary[photoUrlName])
        let yearsOfExperienceResult = yearsOfExperienceTransformer.transform(source: dictionary[yearsOfExperienceName])
        let experienceResult = experienceTransformer.transform(source: dictionary[experienceName])
        let schedulesResult = dictionary[schedulesName].map(schedulesTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        specialityResult.error.map { errors.append((specialityName, $0)) }
        photoUrlResult.error.map { errors.append((photoUrlName, $0)) }
        yearsOfExperienceResult.error.map { errors.append((yearsOfExperienceName, $0)) }
        experienceResult.error.map { errors.append((experienceName, $0)) }
        schedulesResult.error.map { errors.append((schedulesName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let speciality = specialityResult.value,
            let photoUrl = photoUrlResult.value,
            let yearsOfExperience = yearsOfExperienceResult.value,
            let experience = experienceResult.value,
            let schedules = schedulesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                speciality: speciality,
                photoUrl: photoUrl,
                yearsOfExperience: yearsOfExperience,
                experience: experience,
                schedules: schedules
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let specialityResult = specialityTransformer.transform(destination: value.speciality)
        let photoUrlResult = photoUrlTransformer.transform(destination: value.photoUrl)
        let yearsOfExperienceResult = yearsOfExperienceTransformer.transform(destination: value.yearsOfExperience)
        let experienceResult = experienceTransformer.transform(destination: value.experience)
        let schedulesResult = schedulesTransformer.transform(destination: value.schedules)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        specialityResult.error.map { errors.append((specialityName, $0)) }
        photoUrlResult.error.map { errors.append((photoUrlName, $0)) }
        yearsOfExperienceResult.error.map { errors.append((yearsOfExperienceName, $0)) }
        experienceResult.error.map { errors.append((experienceName, $0)) }
        schedulesResult.error.map { errors.append((schedulesName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let speciality = specialityResult.value,
            let photoUrl = photoUrlResult.value,
            let yearsOfExperience = yearsOfExperienceResult.value,
            let experience = experienceResult.value,
            let schedules = schedulesResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[specialityName] = speciality
        dictionary[photoUrlName] = photoUrl
        dictionary[yearsOfExperienceName] = yearsOfExperience
        dictionary[experienceName] = experience
        dictionary[schedulesName] = schedules
        return .success(dictionary)
    }
}
