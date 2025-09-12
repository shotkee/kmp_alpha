// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceShortTransformer: Transformer {
    typealias Source = Any
    typealias Destination = InsuranceShort

    let idName = "id"
    let titleName = "title"
    let startDateName = "start_date"
    let endDateName = "end_date"
    let renewAvailableName = "renew_available"
    let renewTypeName = "renew_type"
    let descriptionName = "description"
    let eventReportTypeName = "event_report_type"
    let labelName = "label"
    let typeName = "type"
    let warningName = "warning"
    let renderName = "render"
    let analyticsInsuranceProfileName = "dms"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let startDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)
    let endDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd HH:mm:ss", locale: AppLocale.currentLocale)
    let renewAvailableTransformer = NumberTransformer<Any, Bool>()
    let renewTypeTransformer = OptionalTransformer(transformer: InsuranceShortRenewTypeTransformer())
    let descriptionTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let eventReportTypeTransformer = OptionalTransformer(transformer: InsuranceShortEventReportTypeTransformer())
    let labelTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let typeTransformer = InsuranceShortKindTransformer()
    let warningTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let renderTransformer = OptionalTransformer(transformer: InsuranceRenderTransformer())
    let analyticsInsuranceProfileTransformer = OptionalTransformer(transformer: AnalyticsInsuranceProfileTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let startDateResult = dictionary[startDateName].map(startDateTransformer.transform(source:)) ?? .failure(.requirement)
        let endDateResult = dictionary[endDateName].map(endDateTransformer.transform(source:)) ?? .failure(.requirement)
        let renewAvailableResult = dictionary[renewAvailableName].map(renewAvailableTransformer.transform(source:)) ?? .failure(.requirement)
        let renewTypeResult = renewTypeTransformer.transform(source: dictionary[renewTypeName])
        let descriptionResult = descriptionTransformer.transform(source: dictionary[descriptionName])
        let eventReportTypeResult = eventReportTypeTransformer.transform(source: dictionary[eventReportTypeName])
        let labelResult = labelTransformer.transform(source: dictionary[labelName])
        let typeResult = dictionary[typeName].map(typeTransformer.transform(source:)) ?? .failure(.requirement)
        let warningResult = warningTransformer.transform(source: dictionary[warningName])
        let renderResult = renderTransformer.transform(source: dictionary[renderName])
        let analyticsInsuranceProfileResult = analyticsInsuranceProfileTransformer.transform(source: dictionary[analyticsInsuranceProfileName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        startDateResult.error.map { errors.append((startDateName, $0)) }
        endDateResult.error.map { errors.append((endDateName, $0)) }
        renewAvailableResult.error.map { errors.append((renewAvailableName, $0)) }
        renewTypeResult.error.map { errors.append((renewTypeName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        eventReportTypeResult.error.map { errors.append((eventReportTypeName, $0)) }
        labelResult.error.map { errors.append((labelName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        warningResult.error.map { errors.append((warningName, $0)) }
        renderResult.error.map { errors.append((renderName, $0)) }
        analyticsInsuranceProfileResult.error.map { errors.append((analyticsInsuranceProfileName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let startDate = startDateResult.value,
            let endDate = endDateResult.value,
            let renewAvailable = renewAvailableResult.value,
            let renewType = renewTypeResult.value,
            let description = descriptionResult.value,
            let eventReportType = eventReportTypeResult.value,
            let label = labelResult.value,
            let type = typeResult.value,
            let warning = warningResult.value,
            let render = renderResult.value,
            let analyticsInsuranceProfile = analyticsInsuranceProfileResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                startDate: startDate,
                endDate: endDate,
                renewAvailable: renewAvailable,
                renewType: renewType,
                description: description,
                eventReportType: eventReportType,
                label: label,
                type: type,
                warning: warning,
                render: render,
                analyticsInsuranceProfile: analyticsInsuranceProfile
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let startDateResult = startDateTransformer.transform(destination: value.startDate)
        let endDateResult = endDateTransformer.transform(destination: value.endDate)
        let renewAvailableResult = renewAvailableTransformer.transform(destination: value.renewAvailable)
        let renewTypeResult = renewTypeTransformer.transform(destination: value.renewType)
        let descriptionResult = descriptionTransformer.transform(destination: value.description)
        let eventReportTypeResult = eventReportTypeTransformer.transform(destination: value.eventReportType)
        let labelResult = labelTransformer.transform(destination: value.label)
        let typeResult = typeTransformer.transform(destination: value.type)
        let warningResult = warningTransformer.transform(destination: value.warning)
        let renderResult = renderTransformer.transform(destination: value.render)
        let analyticsInsuranceProfileResult = analyticsInsuranceProfileTransformer.transform(destination: value.analyticsInsuranceProfile)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        startDateResult.error.map { errors.append((startDateName, $0)) }
        endDateResult.error.map { errors.append((endDateName, $0)) }
        renewAvailableResult.error.map { errors.append((renewAvailableName, $0)) }
        renewTypeResult.error.map { errors.append((renewTypeName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        eventReportTypeResult.error.map { errors.append((eventReportTypeName, $0)) }
        labelResult.error.map { errors.append((labelName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        warningResult.error.map { errors.append((warningName, $0)) }
        renderResult.error.map { errors.append((renderName, $0)) }
        analyticsInsuranceProfileResult.error.map { errors.append((analyticsInsuranceProfileName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let startDate = startDateResult.value,
            let endDate = endDateResult.value,
            let renewAvailable = renewAvailableResult.value,
            let renewType = renewTypeResult.value,
            let description = descriptionResult.value,
            let eventReportType = eventReportTypeResult.value,
            let label = labelResult.value,
            let type = typeResult.value,
            let warning = warningResult.value,
            let render = renderResult.value,
            let analyticsInsuranceProfile = analyticsInsuranceProfileResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[startDateName] = startDate
        dictionary[endDateName] = endDate
        dictionary[renewAvailableName] = renewAvailable
        dictionary[renewTypeName] = renewType
        dictionary[descriptionName] = description
        dictionary[eventReportTypeName] = eventReportType
        dictionary[labelName] = label
        dictionary[typeName] = type
        dictionary[warningName] = warning
        dictionary[renderName] = render
        dictionary[analyticsInsuranceProfileName] = analyticsInsuranceProfile
        return .success(dictionary)
    }
}
