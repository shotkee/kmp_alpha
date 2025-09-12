// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct AVISAppointmentTransformer: Transformer {
    typealias Source = Any
    typealias Destination = AVISAppointment

    let idName = "id"
    let localDateName = "full_date"
    let clinicTypeName = "clinic_type"
    let avisClinicName = "clinic"
    let javisClinicName = "clinic_javis"
    let canBeCancelledName = "can_be_cancelled"
    let canBeRecreatedName = "can_be_recreated"
    let doctorFullNameName = "doctor"
    let referralOrDepartmentName = "description"
    let statusName = "status"

    let idTransformer = NumberTransformer<Any, Int>()
    let localDateTransformer = ISODateInRegionTransofrmer<Any>()
    let clinicTypeTransformer = AVISAppointmentClinicTypeTransformer()
    let avisClinicTransformer = OptionalTransformer(transformer: ClinicTransformer())
    let javisClinicTransformer = OptionalTransformer(transformer: JavisClinicTransformer())
    let canBeCancelledTransformer = NumberTransformer<Any, Bool>()
    let canBeRecreatedTransformer = NumberTransformer<Any, Bool>()
    let doctorFullNameTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let referralOrDepartmentTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let statusTransformer = OptionalTransformer(transformer: AppointmentStatusTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let localDateResult = dictionary[localDateName].map(localDateTransformer.transform(source:)) ?? .failure(.requirement)
        let clinicTypeResult = dictionary[clinicTypeName].map(clinicTypeTransformer.transform(source:)) ?? .failure(.requirement)
        let avisClinicResult = avisClinicTransformer.transform(source: dictionary[avisClinicName])
        let javisClinicResult = javisClinicTransformer.transform(source: dictionary[javisClinicName])
        let canBeCancelledResult = dictionary[canBeCancelledName].map(canBeCancelledTransformer.transform(source:)) ?? .failure(.requirement)
        let canBeRecreatedResult = dictionary[canBeRecreatedName].map(canBeRecreatedTransformer.transform(source:)) ?? .failure(.requirement)
        let doctorFullNameResult = doctorFullNameTransformer.transform(source: dictionary[doctorFullNameName])
        let referralOrDepartmentResult = referralOrDepartmentTransformer.transform(source: dictionary[referralOrDepartmentName])
        let statusResult = statusTransformer.transform(source: dictionary[statusName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        localDateResult.error.map { errors.append((localDateName, $0)) }
        clinicTypeResult.error.map { errors.append((clinicTypeName, $0)) }
        avisClinicResult.error.map { errors.append((avisClinicName, $0)) }
        javisClinicResult.error.map { errors.append((javisClinicName, $0)) }
        canBeCancelledResult.error.map { errors.append((canBeCancelledName, $0)) }
        canBeRecreatedResult.error.map { errors.append((canBeRecreatedName, $0)) }
        doctorFullNameResult.error.map { errors.append((doctorFullNameName, $0)) }
        referralOrDepartmentResult.error.map { errors.append((referralOrDepartmentName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }

        guard
            let id = idResult.value,
            let localDate = localDateResult.value,
            let clinicType = clinicTypeResult.value,
            let avisClinic = avisClinicResult.value,
            let javisClinic = javisClinicResult.value,
            let canBeCancelled = canBeCancelledResult.value,
            let canBeRecreated = canBeRecreatedResult.value,
            let doctorFullName = doctorFullNameResult.value,
            let referralOrDepartment = referralOrDepartmentResult.value,
            let status = statusResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                localDate: localDate,
                clinicType: clinicType,
                avisClinic: avisClinic,
                javisClinic: javisClinic,
                canBeCancelled: canBeCancelled,
                canBeRecreated: canBeRecreated,
                doctorFullName: doctorFullName,
                referralOrDepartment: referralOrDepartment,
                status: status
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let localDateResult = localDateTransformer.transform(destination: value.localDate)
        let clinicTypeResult = clinicTypeTransformer.transform(destination: value.clinicType)
        let avisClinicResult = avisClinicTransformer.transform(destination: value.avisClinic)
        let javisClinicResult = javisClinicTransformer.transform(destination: value.javisClinic)
        let canBeCancelledResult = canBeCancelledTransformer.transform(destination: value.canBeCancelled)
        let canBeRecreatedResult = canBeRecreatedTransformer.transform(destination: value.canBeRecreated)
        let doctorFullNameResult = doctorFullNameTransformer.transform(destination: value.doctorFullName)
        let referralOrDepartmentResult = referralOrDepartmentTransformer.transform(destination: value.referralOrDepartment)
        let statusResult = statusTransformer.transform(destination: value.status)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        localDateResult.error.map { errors.append((localDateName, $0)) }
        clinicTypeResult.error.map { errors.append((clinicTypeName, $0)) }
        avisClinicResult.error.map { errors.append((avisClinicName, $0)) }
        javisClinicResult.error.map { errors.append((javisClinicName, $0)) }
        canBeCancelledResult.error.map { errors.append((canBeCancelledName, $0)) }
        canBeRecreatedResult.error.map { errors.append((canBeRecreatedName, $0)) }
        doctorFullNameResult.error.map { errors.append((doctorFullNameName, $0)) }
        referralOrDepartmentResult.error.map { errors.append((referralOrDepartmentName, $0)) }
        statusResult.error.map { errors.append((statusName, $0)) }

        guard
            let id = idResult.value,
            let localDate = localDateResult.value,
            let clinicType = clinicTypeResult.value,
            let avisClinic = avisClinicResult.value,
            let javisClinic = javisClinicResult.value,
            let canBeCancelled = canBeCancelledResult.value,
            let canBeRecreated = canBeRecreatedResult.value,
            let doctorFullName = doctorFullNameResult.value,
            let referralOrDepartment = referralOrDepartmentResult.value,
            let status = statusResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[localDateName] = localDate
        dictionary[clinicTypeName] = clinicType
        dictionary[avisClinicName] = avisClinic
        dictionary[javisClinicName] = javisClinic
        dictionary[canBeCancelledName] = canBeCancelled
        dictionary[canBeRecreatedName] = canBeRecreated
        dictionary[doctorFullNameName] = doctorFullName
        dictionary[referralOrDepartmentName] = referralOrDepartment
        dictionary[statusName] = status
        return .success(dictionary)
    }
}
