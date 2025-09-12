// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct OfflineAppointmentSettingsTransformer: Transformer {
    typealias Source = Any
    typealias Destination = OfflineAppointmentSettings

    let clinicSpecialitiesName = "clinic_specialities"
    let minDateDaysName = "min_date_days"
    let maxDateDaysName = "max_date_days"
    let minIntervalName = "min_interval"
    let intervalStartTimeName = "interval_start_time"
    let intervalEndTimeName = "interval_end_time"
    let disclaimerName = "disclaimer"

    let clinicSpecialitiesTransformer = ArrayTransformer(from: Any.self, transformer: ClinicSpecialityTransformer(), skipFailures: true)
    let minDateDaysTransformer = NumberTransformer<Any, Int>()
    let maxDateDaysTransformer = NumberTransformer<Any, Int>()
    let minIntervalTransformer = NumberTransformer<Any, Int>()
    let intervalStartTimeTransformer = CastTransformer<Any, String>()
    let intervalEndTimeTransformer = CastTransformer<Any, String>()
    let disclaimerTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let clinicSpecialitiesResult = dictionary[clinicSpecialitiesName].map(clinicSpecialitiesTransformer.transform(source:)) ?? .failure(.requirement)
        let minDateDaysResult = dictionary[minDateDaysName].map(minDateDaysTransformer.transform(source:)) ?? .failure(.requirement)
        let maxDateDaysResult = dictionary[maxDateDaysName].map(maxDateDaysTransformer.transform(source:)) ?? .failure(.requirement)
        let minIntervalResult = dictionary[minIntervalName].map(minIntervalTransformer.transform(source:)) ?? .failure(.requirement)
        let intervalStartTimeResult = dictionary[intervalStartTimeName].map(intervalStartTimeTransformer.transform(source:)) ?? .failure(.requirement)
        let intervalEndTimeResult = dictionary[intervalEndTimeName].map(intervalEndTimeTransformer.transform(source:)) ?? .failure(.requirement)
        let disclaimerResult = disclaimerTransformer.transform(source: dictionary[disclaimerName])

        var errors: [(String, TransformerError)] = []
        clinicSpecialitiesResult.error.map { errors.append((clinicSpecialitiesName, $0)) }
        minDateDaysResult.error.map { errors.append((minDateDaysName, $0)) }
        maxDateDaysResult.error.map { errors.append((maxDateDaysName, $0)) }
        minIntervalResult.error.map { errors.append((minIntervalName, $0)) }
        intervalStartTimeResult.error.map { errors.append((intervalStartTimeName, $0)) }
        intervalEndTimeResult.error.map { errors.append((intervalEndTimeName, $0)) }
        disclaimerResult.error.map { errors.append((disclaimerName, $0)) }

        guard
            let clinicSpecialities = clinicSpecialitiesResult.value,
            let minDateDays = minDateDaysResult.value,
            let maxDateDays = maxDateDaysResult.value,
            let minInterval = minIntervalResult.value,
            let intervalStartTime = intervalStartTimeResult.value,
            let intervalEndTime = intervalEndTimeResult.value,
            let disclaimer = disclaimerResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                clinicSpecialities: clinicSpecialities,
                minDateDays: minDateDays,
                maxDateDays: maxDateDays,
                minInterval: minInterval,
                intervalStartTime: intervalStartTime,
                intervalEndTime: intervalEndTime,
                disclaimer: disclaimer
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let clinicSpecialitiesResult = clinicSpecialitiesTransformer.transform(destination: value.clinicSpecialities)
        let minDateDaysResult = minDateDaysTransformer.transform(destination: value.minDateDays)
        let maxDateDaysResult = maxDateDaysTransformer.transform(destination: value.maxDateDays)
        let minIntervalResult = minIntervalTransformer.transform(destination: value.minInterval)
        let intervalStartTimeResult = intervalStartTimeTransformer.transform(destination: value.intervalStartTime)
        let intervalEndTimeResult = intervalEndTimeTransformer.transform(destination: value.intervalEndTime)
        let disclaimerResult = disclaimerTransformer.transform(destination: value.disclaimer)

        var errors: [(String, TransformerError)] = []
        clinicSpecialitiesResult.error.map { errors.append((clinicSpecialitiesName, $0)) }
        minDateDaysResult.error.map { errors.append((minDateDaysName, $0)) }
        maxDateDaysResult.error.map { errors.append((maxDateDaysName, $0)) }
        minIntervalResult.error.map { errors.append((minIntervalName, $0)) }
        intervalStartTimeResult.error.map { errors.append((intervalStartTimeName, $0)) }
        intervalEndTimeResult.error.map { errors.append((intervalEndTimeName, $0)) }
        disclaimerResult.error.map { errors.append((disclaimerName, $0)) }

        guard
            let clinicSpecialities = clinicSpecialitiesResult.value,
            let minDateDays = minDateDaysResult.value,
            let maxDateDays = maxDateDaysResult.value,
            let minInterval = minIntervalResult.value,
            let intervalStartTime = intervalStartTimeResult.value,
            let intervalEndTime = intervalEndTimeResult.value,
            let disclaimer = disclaimerResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[clinicSpecialitiesName] = clinicSpecialities
        dictionary[minDateDaysName] = minDateDays
        dictionary[maxDateDaysName] = maxDateDays
        dictionary[minIntervalName] = minInterval
        dictionary[intervalStartTimeName] = intervalStartTime
        dictionary[intervalEndTimeName] = intervalEndTime
        dictionary[disclaimerName] = disclaimer
        return .success(dictionary)
    }
}
