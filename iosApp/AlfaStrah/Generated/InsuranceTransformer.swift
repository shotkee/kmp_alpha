// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct InsuranceTransformer: Transformer {
    typealias Source = Any
    typealias Destination = Insurance

    let idName = "id"
    let titleName = "title"
    let contractNumberName = "contract_number"
    let startDateName = "start_date"
    let endDateName = "end_date"
    let descriptionName = "description"
    let insurancePremiumName = "InsurancePremium"
    let ownerParticipantsName = "owner_participants"
    let insurerParticipantsName = "insurer_participants"
    let insuredParticipantsName = "insured_participants"
    let benefitParticipantsName = "benefit_participants"
    let driversName = "drivers"
    let vehicleName = "car"
    let tripSegmentsName = "trip_segments"
    let productIdName = "product_id"
    let renewAvailableName = "renew_available"
    let osagoRenewStatusName = "renew_status"
    let renewUrlName = "renew_url"
    let renewInsuranceIdName = "renew_insurance_id"
    let fieldGroupListName = "field_group_list"
    let insuredObjectTitleName = "insured_object"
    let emergencyPhoneName = "emergency_phone"
    let sosActivitiesName = "sos_activities"
    let clinicIdsName = "clinic_id_list"
    let accessClinicPhoneName = "access_clinic_phone"
    let typeName = "type"
    let archiveDateName = "archive_date"
    let pdfURLName = "file_link"
    let helpURLName = "help_file"
    let helpTypeName = "help_type"
    let passbookAvailableName = "passbook_available"
    let passbookAvailableOnlineName = "passbook_available_online"
    let insuranceIdOuterName = "insurance_id_outer"
    let mobileDeeplinkIDName = "insurance_id_mobile_deeplink"
    let telemedicineName = "access_telemed"
    let isInsurerName = "is_insurer"
    let isChildName = "is_child"
    let companyName = "company"
    let kidsDoctorPhoneName = "child_phone"
    let billsName = "bills"
    let shouldShowBillsName = "show_bills"
    let hasUnpaidBillsName = "has_unpaid_bills"
    let shouldShowGuaranteeLettersName = "show_garantee_letters"
    let isFranchiseTransitionAvailableName = "is_change_franch_program_available"
    let servicesListName = "additions"
    let renderName = "render"

    let idTransformer = IdTransformer<Any>()
    let titleTransformer = CastTransformer<Any, String>()
    let contractNumberTransformer = CastTransformer<Any, String>()
    let startDateTransformer = TimestampTransformer<Any>(scale: 1)
    let endDateTransformer = TimestampTransformer<Any>(scale: 1)
    let descriptionTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let insurancePremiumTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let ownerParticipantsTransformer = ArrayTransformer(from: Any.self, transformer: InsuranceParticipantTransformer(), skipFailures: true)
    let insurerParticipantsTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: InsuranceParticipantTransformer(), skipFailures: true))
    let insuredParticipantsTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: InsuranceParticipantTransformer(), skipFailures: true))
    let benefitParticipantsTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: InsuranceParticipantTransformer(), skipFailures: true))
    let driversTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: InsuranceParticipantTransformer(), skipFailures: true))
    let vehicleTransformer = OptionalTransformer(transformer: VehicleTransformer())
    let tripSegmentsTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: TripSegmentTransformer(), skipFailures: true))
    let productIdTransformer = CastTransformer<Any, String>()
    let renewAvailableTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Bool>())
    let osagoRenewStatusTransformer = OptionalTransformer(transformer: InsuranceOsagoRenewStatusKindTransformer())
    let renewUrlTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())
    let renewInsuranceIdTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let fieldGroupListTransformer = ArrayTransformer(from: Any.self, transformer: InfoFieldGroupTransformer(), skipFailures: true)
    let insuredObjectTitleTransformer = CastTransformer<Any, String>()
    let emergencyPhoneTransformer = PhoneTransformer()
    let sosActivitiesTransformer = ArrayTransformer(from: Any.self, transformer: SOSActivityTransformer(), skipFailures: true)
    let clinicIdsTransformer = OptionalTransformer(transformer: ArrayTransformer(from: Any.self, transformer: CastTransformer<Any, String>(), skipFailures: true))
    let accessClinicPhoneTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Bool>())
    let typeTransformer = InsuranceKindTransformer()
    let archiveDateTransformer = TimestampTransformer<Any>(scale: 1)
    let pdfURLTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())
    let helpURLTransformer = OptionalTransformer(transformer: UrlTransformer<Any>())
    let helpTypeTransformer = OptionalTransformer(transformer: InsuranceHelpTypeTransformer())
    let passbookAvailableTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Bool>())
    let passbookAvailableOnlineTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Bool>())
    let insuranceIdOuterTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let mobileDeeplinkIDTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let telemedicineTransformer = NumberTransformer<Any, Bool>()
    let isInsurerTransformer = NumberTransformer<Any, Bool>()
    let isChildTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Bool>())
    let companyTransformer = OptionalTransformer(transformer: InsuranceCompanyTransformer())
    let kidsDoctorPhoneTransformer = OptionalTransformer(transformer: PhoneTransformer())
    let billsTransformer = ArrayTransformer(from: Any.self, transformer: InsuranceBillTransformer(), skipFailures: true)
    let shouldShowBillsTransformer = NumberTransformer<Any, Bool>()
    let hasUnpaidBillsTransformer = NumberTransformer<Any, Bool>()
    let shouldShowGuaranteeLettersTransformer = NumberTransformer<Any, Bool>()
    let isFranchiseTransitionAvailableTransformer = NumberTransformer<Any, Bool>()
    let servicesListTransformer = ArrayTransformer(from: Any.self, transformer: InsuranceServiceAvailabiltyTransformer(), skipFailures: true)
    let renderTransformer = OptionalTransformer(transformer: InsuranceRenderTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let idResult = dictionary[idName].map(idTransformer.transform(source:)) ?? .failure(.requirement)
        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let contractNumberResult = dictionary[contractNumberName].map(contractNumberTransformer.transform(source:)) ?? .failure(.requirement)
        let startDateResult = dictionary[startDateName].map(startDateTransformer.transform(source:)) ?? .failure(.requirement)
        let endDateResult = dictionary[endDateName].map(endDateTransformer.transform(source:)) ?? .failure(.requirement)
        let descriptionResult = descriptionTransformer.transform(source: dictionary[descriptionName])
        let insurancePremiumResult = insurancePremiumTransformer.transform(source: dictionary[insurancePremiumName])
        let ownerParticipantsResult = dictionary[ownerParticipantsName].map(ownerParticipantsTransformer.transform(source:)) ?? .failure(.requirement)
        let insurerParticipantsResult = insurerParticipantsTransformer.transform(source: dictionary[insurerParticipantsName])
        let insuredParticipantsResult = insuredParticipantsTransformer.transform(source: dictionary[insuredParticipantsName])
        let benefitParticipantsResult = benefitParticipantsTransformer.transform(source: dictionary[benefitParticipantsName])
        let driversResult = driversTransformer.transform(source: dictionary[driversName])
        let vehicleResult = vehicleTransformer.transform(source: dictionary[vehicleName])
        let tripSegmentsResult = tripSegmentsTransformer.transform(source: dictionary[tripSegmentsName])
        let productIdResult = dictionary[productIdName].map(productIdTransformer.transform(source:)) ?? .failure(.requirement)
        let renewAvailableResult = renewAvailableTransformer.transform(source: dictionary[renewAvailableName])
        let osagoRenewStatusResult = osagoRenewStatusTransformer.transform(source: dictionary[osagoRenewStatusName])
        let renewUrlResult = renewUrlTransformer.transform(source: dictionary[renewUrlName])
        let renewInsuranceIdResult = renewInsuranceIdTransformer.transform(source: dictionary[renewInsuranceIdName])
        let fieldGroupListResult = dictionary[fieldGroupListName].map(fieldGroupListTransformer.transform(source:)) ?? .failure(.requirement)
        let insuredObjectTitleResult = dictionary[insuredObjectTitleName].map(insuredObjectTitleTransformer.transform(source:)) ?? .failure(.requirement)
        let emergencyPhoneResult = dictionary[emergencyPhoneName].map(emergencyPhoneTransformer.transform(source:)) ?? .failure(.requirement)
        let sosActivitiesResult = dictionary[sosActivitiesName].map(sosActivitiesTransformer.transform(source:)) ?? .failure(.requirement)
        let clinicIdsResult = clinicIdsTransformer.transform(source: dictionary[clinicIdsName])
        let accessClinicPhoneResult = accessClinicPhoneTransformer.transform(source: dictionary[accessClinicPhoneName])
        let typeResult = dictionary[typeName].map(typeTransformer.transform(source:)) ?? .failure(.requirement)
        let archiveDateResult = dictionary[archiveDateName].map(archiveDateTransformer.transform(source:)) ?? .failure(.requirement)
        let pdfURLResult = pdfURLTransformer.transform(source: dictionary[pdfURLName])
        let helpURLResult = helpURLTransformer.transform(source: dictionary[helpURLName])
        let helpTypeResult = helpTypeTransformer.transform(source: dictionary[helpTypeName])
        let passbookAvailableResult = passbookAvailableTransformer.transform(source: dictionary[passbookAvailableName])
        let passbookAvailableOnlineResult = passbookAvailableOnlineTransformer.transform(source: dictionary[passbookAvailableOnlineName])
        let insuranceIdOuterResult = insuranceIdOuterTransformer.transform(source: dictionary[insuranceIdOuterName])
        let mobileDeeplinkIDResult = mobileDeeplinkIDTransformer.transform(source: dictionary[mobileDeeplinkIDName])
        let telemedicineResult = dictionary[telemedicineName].map(telemedicineTransformer.transform(source:)) ?? .failure(.requirement)
        let isInsurerResult = dictionary[isInsurerName].map(isInsurerTransformer.transform(source:)) ?? .failure(.requirement)
        let isChildResult = isChildTransformer.transform(source: dictionary[isChildName])
        let companyResult = companyTransformer.transform(source: dictionary[companyName])
        let kidsDoctorPhoneResult = kidsDoctorPhoneTransformer.transform(source: dictionary[kidsDoctorPhoneName])
        let billsResult = dictionary[billsName].map(billsTransformer.transform(source:)) ?? .failure(.requirement)
        let shouldShowBillsResult = dictionary[shouldShowBillsName].map(shouldShowBillsTransformer.transform(source:)) ?? .failure(.requirement)
        let hasUnpaidBillsResult = dictionary[hasUnpaidBillsName].map(hasUnpaidBillsTransformer.transform(source:)) ?? .failure(.requirement)
        let shouldShowGuaranteeLettersResult = dictionary[shouldShowGuaranteeLettersName].map(shouldShowGuaranteeLettersTransformer.transform(source:)) ?? .failure(.requirement)
        let isFranchiseTransitionAvailableResult = dictionary[isFranchiseTransitionAvailableName].map(isFranchiseTransitionAvailableTransformer.transform(source:)) ?? .failure(.requirement)
        let servicesListResult = dictionary[servicesListName].map(servicesListTransformer.transform(source:)) ?? .failure(.requirement)
        let renderResult = renderTransformer.transform(source: dictionary[renderName])

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        contractNumberResult.error.map { errors.append((contractNumberName, $0)) }
        startDateResult.error.map { errors.append((startDateName, $0)) }
        endDateResult.error.map { errors.append((endDateName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        insurancePremiumResult.error.map { errors.append((insurancePremiumName, $0)) }
        ownerParticipantsResult.error.map { errors.append((ownerParticipantsName, $0)) }
        insurerParticipantsResult.error.map { errors.append((insurerParticipantsName, $0)) }
        insuredParticipantsResult.error.map { errors.append((insuredParticipantsName, $0)) }
        benefitParticipantsResult.error.map { errors.append((benefitParticipantsName, $0)) }
        driversResult.error.map { errors.append((driversName, $0)) }
        vehicleResult.error.map { errors.append((vehicleName, $0)) }
        tripSegmentsResult.error.map { errors.append((tripSegmentsName, $0)) }
        productIdResult.error.map { errors.append((productIdName, $0)) }
        renewAvailableResult.error.map { errors.append((renewAvailableName, $0)) }
        osagoRenewStatusResult.error.map { errors.append((osagoRenewStatusName, $0)) }
        renewUrlResult.error.map { errors.append((renewUrlName, $0)) }
        renewInsuranceIdResult.error.map { errors.append((renewInsuranceIdName, $0)) }
        fieldGroupListResult.error.map { errors.append((fieldGroupListName, $0)) }
        insuredObjectTitleResult.error.map { errors.append((insuredObjectTitleName, $0)) }
        emergencyPhoneResult.error.map { errors.append((emergencyPhoneName, $0)) }
        sosActivitiesResult.error.map { errors.append((sosActivitiesName, $0)) }
        clinicIdsResult.error.map { errors.append((clinicIdsName, $0)) }
        accessClinicPhoneResult.error.map { errors.append((accessClinicPhoneName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        archiveDateResult.error.map { errors.append((archiveDateName, $0)) }
        pdfURLResult.error.map { errors.append((pdfURLName, $0)) }
        helpURLResult.error.map { errors.append((helpURLName, $0)) }
        helpTypeResult.error.map { errors.append((helpTypeName, $0)) }
        passbookAvailableResult.error.map { errors.append((passbookAvailableName, $0)) }
        passbookAvailableOnlineResult.error.map { errors.append((passbookAvailableOnlineName, $0)) }
        insuranceIdOuterResult.error.map { errors.append((insuranceIdOuterName, $0)) }
        mobileDeeplinkIDResult.error.map { errors.append((mobileDeeplinkIDName, $0)) }
        telemedicineResult.error.map { errors.append((telemedicineName, $0)) }
        isInsurerResult.error.map { errors.append((isInsurerName, $0)) }
        isChildResult.error.map { errors.append((isChildName, $0)) }
        companyResult.error.map { errors.append((companyName, $0)) }
        kidsDoctorPhoneResult.error.map { errors.append((kidsDoctorPhoneName, $0)) }
        billsResult.error.map { errors.append((billsName, $0)) }
        shouldShowBillsResult.error.map { errors.append((shouldShowBillsName, $0)) }
        hasUnpaidBillsResult.error.map { errors.append((hasUnpaidBillsName, $0)) }
        shouldShowGuaranteeLettersResult.error.map { errors.append((shouldShowGuaranteeLettersName, $0)) }
        isFranchiseTransitionAvailableResult.error.map { errors.append((isFranchiseTransitionAvailableName, $0)) }
        servicesListResult.error.map { errors.append((servicesListName, $0)) }
        renderResult.error.map { errors.append((renderName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let contractNumber = contractNumberResult.value,
            let startDate = startDateResult.value,
            let endDate = endDateResult.value,
            let description = descriptionResult.value,
            let insurancePremium = insurancePremiumResult.value,
            let ownerParticipants = ownerParticipantsResult.value,
            let insurerParticipants = insurerParticipantsResult.value,
            let insuredParticipants = insuredParticipantsResult.value,
            let benefitParticipants = benefitParticipantsResult.value,
            let drivers = driversResult.value,
            let vehicle = vehicleResult.value,
            let tripSegments = tripSegmentsResult.value,
            let productId = productIdResult.value,
            let renewAvailable = renewAvailableResult.value,
            let osagoRenewStatus = osagoRenewStatusResult.value,
            let renewUrl = renewUrlResult.value,
            let renewInsuranceId = renewInsuranceIdResult.value,
            let fieldGroupList = fieldGroupListResult.value,
            let insuredObjectTitle = insuredObjectTitleResult.value,
            let emergencyPhone = emergencyPhoneResult.value,
            let sosActivities = sosActivitiesResult.value,
            let clinicIds = clinicIdsResult.value,
            let accessClinicPhone = accessClinicPhoneResult.value,
            let type = typeResult.value,
            let archiveDate = archiveDateResult.value,
            let pdfURL = pdfURLResult.value,
            let helpURL = helpURLResult.value,
            let helpType = helpTypeResult.value,
            let passbookAvailable = passbookAvailableResult.value,
            let passbookAvailableOnline = passbookAvailableOnlineResult.value,
            let insuranceIdOuter = insuranceIdOuterResult.value,
            let mobileDeeplinkID = mobileDeeplinkIDResult.value,
            let telemedicine = telemedicineResult.value,
            let isInsurer = isInsurerResult.value,
            let isChild = isChildResult.value,
            let company = companyResult.value,
            let kidsDoctorPhone = kidsDoctorPhoneResult.value,
            let bills = billsResult.value,
            let shouldShowBills = shouldShowBillsResult.value,
            let hasUnpaidBills = hasUnpaidBillsResult.value,
            let shouldShowGuaranteeLetters = shouldShowGuaranteeLettersResult.value,
            let isFranchiseTransitionAvailable = isFranchiseTransitionAvailableResult.value,
            let servicesList = servicesListResult.value,
            let render = renderResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                id: id,
                title: title,
                contractNumber: contractNumber,
                startDate: startDate,
                endDate: endDate,
                description: description,
                insurancePremium: insurancePremium,
                ownerParticipants: ownerParticipants,
                insurerParticipants: insurerParticipants,
                insuredParticipants: insuredParticipants,
                benefitParticipants: benefitParticipants,
                drivers: drivers,
                vehicle: vehicle,
                tripSegments: tripSegments,
                productId: productId,
                renewAvailable: renewAvailable,
                osagoRenewStatus: osagoRenewStatus,
                renewUrl: renewUrl,
                renewInsuranceId: renewInsuranceId,
                fieldGroupList: fieldGroupList,
                insuredObjectTitle: insuredObjectTitle,
                emergencyPhone: emergencyPhone,
                sosActivities: sosActivities,
                clinicIds: clinicIds,
                accessClinicPhone: accessClinicPhone,
                type: type,
                archiveDate: archiveDate,
                pdfURL: pdfURL,
                helpURL: helpURL,
                helpType: helpType,
                passbookAvailable: passbookAvailable,
                passbookAvailableOnline: passbookAvailableOnline,
                insuranceIdOuter: insuranceIdOuter,
                mobileDeeplinkID: mobileDeeplinkID,
                telemedicine: telemedicine,
                isInsurer: isInsurer,
                isChild: isChild,
                company: company,
                kidsDoctorPhone: kidsDoctorPhone,
                bills: bills,
                shouldShowBills: shouldShowBills,
                hasUnpaidBills: hasUnpaidBills,
                shouldShowGuaranteeLetters: shouldShowGuaranteeLetters,
                isFranchiseTransitionAvailable: isFranchiseTransitionAvailable,
                servicesList: servicesList,
                render: render
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let idResult = idTransformer.transform(destination: value.id)
        let titleResult = titleTransformer.transform(destination: value.title)
        let contractNumberResult = contractNumberTransformer.transform(destination: value.contractNumber)
        let startDateResult = startDateTransformer.transform(destination: value.startDate)
        let endDateResult = endDateTransformer.transform(destination: value.endDate)
        let descriptionResult = descriptionTransformer.transform(destination: value.description)
        let insurancePremiumResult = insurancePremiumTransformer.transform(destination: value.insurancePremium)
        let ownerParticipantsResult = ownerParticipantsTransformer.transform(destination: value.ownerParticipants)
        let insurerParticipantsResult = insurerParticipantsTransformer.transform(destination: value.insurerParticipants)
        let insuredParticipantsResult = insuredParticipantsTransformer.transform(destination: value.insuredParticipants)
        let benefitParticipantsResult = benefitParticipantsTransformer.transform(destination: value.benefitParticipants)
        let driversResult = driversTransformer.transform(destination: value.drivers)
        let vehicleResult = vehicleTransformer.transform(destination: value.vehicle)
        let tripSegmentsResult = tripSegmentsTransformer.transform(destination: value.tripSegments)
        let productIdResult = productIdTransformer.transform(destination: value.productId)
        let renewAvailableResult = renewAvailableTransformer.transform(destination: value.renewAvailable)
        let osagoRenewStatusResult = osagoRenewStatusTransformer.transform(destination: value.osagoRenewStatus)
        let renewUrlResult = renewUrlTransformer.transform(destination: value.renewUrl)
        let renewInsuranceIdResult = renewInsuranceIdTransformer.transform(destination: value.renewInsuranceId)
        let fieldGroupListResult = fieldGroupListTransformer.transform(destination: value.fieldGroupList)
        let insuredObjectTitleResult = insuredObjectTitleTransformer.transform(destination: value.insuredObjectTitle)
        let emergencyPhoneResult = emergencyPhoneTransformer.transform(destination: value.emergencyPhone)
        let sosActivitiesResult = sosActivitiesTransformer.transform(destination: value.sosActivities)
        let clinicIdsResult = clinicIdsTransformer.transform(destination: value.clinicIds)
        let accessClinicPhoneResult = accessClinicPhoneTransformer.transform(destination: value.accessClinicPhone)
        let typeResult = typeTransformer.transform(destination: value.type)
        let archiveDateResult = archiveDateTransformer.transform(destination: value.archiveDate)
        let pdfURLResult = pdfURLTransformer.transform(destination: value.pdfURL)
        let helpURLResult = helpURLTransformer.transform(destination: value.helpURL)
        let helpTypeResult = helpTypeTransformer.transform(destination: value.helpType)
        let passbookAvailableResult = passbookAvailableTransformer.transform(destination: value.passbookAvailable)
        let passbookAvailableOnlineResult = passbookAvailableOnlineTransformer.transform(destination: value.passbookAvailableOnline)
        let insuranceIdOuterResult = insuranceIdOuterTransformer.transform(destination: value.insuranceIdOuter)
        let mobileDeeplinkIDResult = mobileDeeplinkIDTransformer.transform(destination: value.mobileDeeplinkID)
        let telemedicineResult = telemedicineTransformer.transform(destination: value.telemedicine)
        let isInsurerResult = isInsurerTransformer.transform(destination: value.isInsurer)
        let isChildResult = isChildTransformer.transform(destination: value.isChild)
        let companyResult = companyTransformer.transform(destination: value.company)
        let kidsDoctorPhoneResult = kidsDoctorPhoneTransformer.transform(destination: value.kidsDoctorPhone)
        let billsResult = billsTransformer.transform(destination: value.bills)
        let shouldShowBillsResult = shouldShowBillsTransformer.transform(destination: value.shouldShowBills)
        let hasUnpaidBillsResult = hasUnpaidBillsTransformer.transform(destination: value.hasUnpaidBills)
        let shouldShowGuaranteeLettersResult = shouldShowGuaranteeLettersTransformer.transform(destination: value.shouldShowGuaranteeLetters)
        let isFranchiseTransitionAvailableResult = isFranchiseTransitionAvailableTransformer.transform(destination: value.isFranchiseTransitionAvailable)
        let servicesListResult = servicesListTransformer.transform(destination: value.servicesList)
        let renderResult = renderTransformer.transform(destination: value.render)

        var errors: [(String, TransformerError)] = []
        idResult.error.map { errors.append((idName, $0)) }
        titleResult.error.map { errors.append((titleName, $0)) }
        contractNumberResult.error.map { errors.append((contractNumberName, $0)) }
        startDateResult.error.map { errors.append((startDateName, $0)) }
        endDateResult.error.map { errors.append((endDateName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        insurancePremiumResult.error.map { errors.append((insurancePremiumName, $0)) }
        ownerParticipantsResult.error.map { errors.append((ownerParticipantsName, $0)) }
        insurerParticipantsResult.error.map { errors.append((insurerParticipantsName, $0)) }
        insuredParticipantsResult.error.map { errors.append((insuredParticipantsName, $0)) }
        benefitParticipantsResult.error.map { errors.append((benefitParticipantsName, $0)) }
        driversResult.error.map { errors.append((driversName, $0)) }
        vehicleResult.error.map { errors.append((vehicleName, $0)) }
        tripSegmentsResult.error.map { errors.append((tripSegmentsName, $0)) }
        productIdResult.error.map { errors.append((productIdName, $0)) }
        renewAvailableResult.error.map { errors.append((renewAvailableName, $0)) }
        osagoRenewStatusResult.error.map { errors.append((osagoRenewStatusName, $0)) }
        renewUrlResult.error.map { errors.append((renewUrlName, $0)) }
        renewInsuranceIdResult.error.map { errors.append((renewInsuranceIdName, $0)) }
        fieldGroupListResult.error.map { errors.append((fieldGroupListName, $0)) }
        insuredObjectTitleResult.error.map { errors.append((insuredObjectTitleName, $0)) }
        emergencyPhoneResult.error.map { errors.append((emergencyPhoneName, $0)) }
        sosActivitiesResult.error.map { errors.append((sosActivitiesName, $0)) }
        clinicIdsResult.error.map { errors.append((clinicIdsName, $0)) }
        accessClinicPhoneResult.error.map { errors.append((accessClinicPhoneName, $0)) }
        typeResult.error.map { errors.append((typeName, $0)) }
        archiveDateResult.error.map { errors.append((archiveDateName, $0)) }
        pdfURLResult.error.map { errors.append((pdfURLName, $0)) }
        helpURLResult.error.map { errors.append((helpURLName, $0)) }
        helpTypeResult.error.map { errors.append((helpTypeName, $0)) }
        passbookAvailableResult.error.map { errors.append((passbookAvailableName, $0)) }
        passbookAvailableOnlineResult.error.map { errors.append((passbookAvailableOnlineName, $0)) }
        insuranceIdOuterResult.error.map { errors.append((insuranceIdOuterName, $0)) }
        mobileDeeplinkIDResult.error.map { errors.append((mobileDeeplinkIDName, $0)) }
        telemedicineResult.error.map { errors.append((telemedicineName, $0)) }
        isInsurerResult.error.map { errors.append((isInsurerName, $0)) }
        isChildResult.error.map { errors.append((isChildName, $0)) }
        companyResult.error.map { errors.append((companyName, $0)) }
        kidsDoctorPhoneResult.error.map { errors.append((kidsDoctorPhoneName, $0)) }
        billsResult.error.map { errors.append((billsName, $0)) }
        shouldShowBillsResult.error.map { errors.append((shouldShowBillsName, $0)) }
        hasUnpaidBillsResult.error.map { errors.append((hasUnpaidBillsName, $0)) }
        shouldShowGuaranteeLettersResult.error.map { errors.append((shouldShowGuaranteeLettersName, $0)) }
        isFranchiseTransitionAvailableResult.error.map { errors.append((isFranchiseTransitionAvailableName, $0)) }
        servicesListResult.error.map { errors.append((servicesListName, $0)) }
        renderResult.error.map { errors.append((renderName, $0)) }

        guard
            let id = idResult.value,
            let title = titleResult.value,
            let contractNumber = contractNumberResult.value,
            let startDate = startDateResult.value,
            let endDate = endDateResult.value,
            let description = descriptionResult.value,
            let insurancePremium = insurancePremiumResult.value,
            let ownerParticipants = ownerParticipantsResult.value,
            let insurerParticipants = insurerParticipantsResult.value,
            let insuredParticipants = insuredParticipantsResult.value,
            let benefitParticipants = benefitParticipantsResult.value,
            let drivers = driversResult.value,
            let vehicle = vehicleResult.value,
            let tripSegments = tripSegmentsResult.value,
            let productId = productIdResult.value,
            let renewAvailable = renewAvailableResult.value,
            let osagoRenewStatus = osagoRenewStatusResult.value,
            let renewUrl = renewUrlResult.value,
            let renewInsuranceId = renewInsuranceIdResult.value,
            let fieldGroupList = fieldGroupListResult.value,
            let insuredObjectTitle = insuredObjectTitleResult.value,
            let emergencyPhone = emergencyPhoneResult.value,
            let sosActivities = sosActivitiesResult.value,
            let clinicIds = clinicIdsResult.value,
            let accessClinicPhone = accessClinicPhoneResult.value,
            let type = typeResult.value,
            let archiveDate = archiveDateResult.value,
            let pdfURL = pdfURLResult.value,
            let helpURL = helpURLResult.value,
            let helpType = helpTypeResult.value,
            let passbookAvailable = passbookAvailableResult.value,
            let passbookAvailableOnline = passbookAvailableOnlineResult.value,
            let insuranceIdOuter = insuranceIdOuterResult.value,
            let mobileDeeplinkID = mobileDeeplinkIDResult.value,
            let telemedicine = telemedicineResult.value,
            let isInsurer = isInsurerResult.value,
            let isChild = isChildResult.value,
            let company = companyResult.value,
            let kidsDoctorPhone = kidsDoctorPhoneResult.value,
            let bills = billsResult.value,
            let shouldShowBills = shouldShowBillsResult.value,
            let hasUnpaidBills = hasUnpaidBillsResult.value,
            let shouldShowGuaranteeLetters = shouldShowGuaranteeLettersResult.value,
            let isFranchiseTransitionAvailable = isFranchiseTransitionAvailableResult.value,
            let servicesList = servicesListResult.value,
            let render = renderResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[idName] = id
        dictionary[titleName] = title
        dictionary[contractNumberName] = contractNumber
        dictionary[startDateName] = startDate
        dictionary[endDateName] = endDate
        dictionary[descriptionName] = description
        dictionary[insurancePremiumName] = insurancePremium
        dictionary[ownerParticipantsName] = ownerParticipants
        dictionary[insurerParticipantsName] = insurerParticipants
        dictionary[insuredParticipantsName] = insuredParticipants
        dictionary[benefitParticipantsName] = benefitParticipants
        dictionary[driversName] = drivers
        dictionary[vehicleName] = vehicle
        dictionary[tripSegmentsName] = tripSegments
        dictionary[productIdName] = productId
        dictionary[renewAvailableName] = renewAvailable
        dictionary[osagoRenewStatusName] = osagoRenewStatus
        dictionary[renewUrlName] = renewUrl
        dictionary[renewInsuranceIdName] = renewInsuranceId
        dictionary[fieldGroupListName] = fieldGroupList
        dictionary[insuredObjectTitleName] = insuredObjectTitle
        dictionary[emergencyPhoneName] = emergencyPhone
        dictionary[sosActivitiesName] = sosActivities
        dictionary[clinicIdsName] = clinicIds
        dictionary[accessClinicPhoneName] = accessClinicPhone
        dictionary[typeName] = type
        dictionary[archiveDateName] = archiveDate
        dictionary[pdfURLName] = pdfURL
        dictionary[helpURLName] = helpURL
        dictionary[helpTypeName] = helpType
        dictionary[passbookAvailableName] = passbookAvailable
        dictionary[passbookAvailableOnlineName] = passbookAvailableOnline
        dictionary[insuranceIdOuterName] = insuranceIdOuter
        dictionary[mobileDeeplinkIDName] = mobileDeeplinkID
        dictionary[telemedicineName] = telemedicine
        dictionary[isInsurerName] = isInsurer
        dictionary[isChildName] = isChild
        dictionary[companyName] = company
        dictionary[kidsDoctorPhoneName] = kidsDoctorPhone
        dictionary[billsName] = bills
        dictionary[shouldShowBillsName] = shouldShowBills
        dictionary[hasUnpaidBillsName] = hasUnpaidBills
        dictionary[shouldShowGuaranteeLettersName] = shouldShowGuaranteeLetters
        dictionary[isFranchiseTransitionAvailableName] = isFranchiseTransitionAvailable
        dictionary[servicesListName] = servicesList
        dictionary[renderName] = render
        return .success(dictionary)
    }
}
