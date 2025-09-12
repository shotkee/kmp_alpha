//
//  RsaSdkError
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 25.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

// swiftlint:disable file_length

enum RsaSdkError: Error {
    case unknownError(code: Int, description: String)

    case invalidPolicy(code: Int, description: String)

    case esiaTokenExpired(code: Int, description: String)

    case participantDataIsEmpty(code: Int, description: String)

    case draftIsNotRegistered(code: Int, description: String)

    case draftIsAlreadyRegistered(code: Int, description: String)

    case draftIsNotSigned(code: Int, description: String)

    case invalidAccidentDate(code: Int, description: String)

    case secureGuidExpired(code: Int, description: String)

    case foundActiveSession(code: Int, description: String)

    case noActiveSession(code: Int, description: String)

    case cantSendPhoto(code: Int, description: String)

    case errorSaveImageToSDK(code: Int, description: String)

    case networkError(code: Int, description: String)

    case requestTimeout(code: Int, description: String)

    case cantSavePhotoToGallery(code: Int, description: String)

    case errorToReadPolicy(code: Int, description: String)

    case esiaErrorNoInvitationLink(code: Int, description: String)

    case invalidGPSCoordinates(code: Int, description: String)

    case draftIsIncomplete(code: Int, description: String)

    case ownerDraftSingingError(code: Int, description: String)

    case draftRejectingError(code: Int, description: String)

    case draftIsNotFound(code: Int, description: String)

    case draftFixingError(code: Int, description: String)

    case invalidQRImage(code: Int, description: String)

    case invalidQRFormat(code: Int, description: String)

    case tooManyDamagePhotosForParticipant(code: Int, description: String)

    case tooManyPhotos(code: Int, description: String)

    case operationAborted(code: Int, description: String)

    case getUserDataError(code: Int, description: String)

    case invalidWitnessName(code: Int, description: String)

    case invalidWitnessAddress(code: Int, description: String)

    case invalidWitnessPhone(code: Int, description: String)

    case noCameraAccess(code: Int, description: String)

    case didCancelCamera(code: Int, description: String)

    case noLocationAccess(code: Int, description: String)

    case invalidInputData(code: Int, description: String)

    case unexpectedType(code: Int, description: String)

    case tooManyPlacePhotos(code: Int, description: String)

    case checkUserDataByESIA(code: Int, description: String)

    case invalidFirstBumpScheme(code: Int, description: String)

    case draftIsConfirmedAndUneditable(code: Int, description: String)

    case serverError(code: Int, description: String)

    case invalidOtherPhotoItemName(code: Int, description: String)

    case invalidOtherPhotoDescription(code: Int, description: String)

    case emptyCircumstancesList(code: Int, description: String)

    case invalidCircumstancesCount(code: Int, description: String)

    case circumstanceDescriptionIsEmpty(code: Int, description: String)

    case invalidCircumstancesDescription(code: Int, description: String)

    case photoNotFound(code: Int, description: String)

    case unavailableForBParticipant(code: Int, description: String)

    case registrationFailed(code: Int, description: String)

    case invalidDriverOwnership(code: Int, description: String)

    case invalidRoadAccidentDescription(code: Int, description: String)

    case noFile(code: Int, description: String)

    case incorrectVehicleCertificate(code: Int, description: String)

    case serviceStatuses(code: Int, description: String)

    case validationErrors(code: Int, description: String, errors: [RsaSdkValidationError])

    case invalidPolicySeries(code: Int, description: String)

    case invalidPolicyNumber(code: Int, description: String)

    case invalidSDKVersion(code: Int, description: String)

    case noticeIsRejectedBySecondParty(code: Int, description: String)

    case tooBigLogFile(code: Int, description: String)

    var info: (code: Int, description: String) {
        switch self {
            case .unknownError(let code, let description):
                return (code, description)
            case .invalidPolicy(let code, let description):
                return (code, description)
            case .esiaTokenExpired(let code, let description):
                return (code, description)
            case .participantDataIsEmpty(let code, let description):
                return (code, description)
            case .draftIsNotRegistered(let code, let description):
                return (code, description)
            case .draftIsAlreadyRegistered(let code, let description):
                return (code, description)
            case .draftIsNotSigned(let code, let description):
                return (code, description)
            case .invalidAccidentDate(let code, let description):
                return (code, description)
            case .secureGuidExpired(let code, let description):
                return (code, description)
            case .foundActiveSession(let code, let description):
                return (code, description)
            case .noActiveSession(let code, let description):
                return (code, description)
            case .cantSendPhoto(let code, let description):
                return (code, description)
            case .errorSaveImageToSDK(let code, let description):
                return (code, description)
            case .networkError(let code, let description):
                return (code, description)
            case .requestTimeout(let code, let description):
                return (code, description)
            case .cantSavePhotoToGallery(let code, let description):
                return (code, description)
            case .errorToReadPolicy(let code, let description):
                return (code, description)
            case .esiaErrorNoInvitationLink(let code, let description):
                return (code, description)
            case .invalidGPSCoordinates(let code, let description):
                return (code, description)
            case .draftIsIncomplete(let code, let description):
                return (code, description)
            case .ownerDraftSingingError(let code, let description):
                return (code, description)
            case .draftRejectingError(let code, let description):
                return (code, description)
            case .draftIsNotFound(let code, let description):
                return (code, description)
            case .draftFixingError(let code, let description):
                return (code, description)
            case .invalidQRImage(let code, let description):
                return (code, description)
            case .invalidQRFormat(let code, let description):
                return (code, description)
            case .tooManyDamagePhotosForParticipant(let code, let description):
                return (code, description)
            case .tooManyPhotos(let code, let description):
                return (code, description)
            case .operationAborted(let code, let description):
                return (code, description)
            case .getUserDataError(let code, let description):
                return (code, description)
            case .invalidWitnessName(let code, let description):
                return (code, description)
            case .invalidWitnessAddress(let code, let description):
                return (code, description)
            case .invalidWitnessPhone(let code, let description):
                return (code, description)
            case .noCameraAccess(let code, let description):
                return (code, description)
            case .didCancelCamera(let code, let description):
                return (code, description)
            case .noLocationAccess(let code, let description):
                return (code, description)
            case .invalidInputData(let code, let description):
                return (code, description)
            case .unexpectedType(let code, let description):
                return (code, description)
            case .tooManyPlacePhotos(let code, let description):
                return (code, description)
            case .checkUserDataByESIA(let code, let description):
                return (code, description)
            case .invalidFirstBumpScheme(let code, let description):
                return (code, description)
            case .draftIsConfirmedAndUneditable(let code, let description):
                return (code, description)
            case .serverError(let code, let description):
                return (code, description)
            case .invalidOtherPhotoItemName(let code, let description):
                return (code, description)
            case .invalidOtherPhotoDescription(let code, let description):
                return (code, description)
            case .emptyCircumstancesList(let code, let description):
                return (code, description)
            case .invalidCircumstancesCount(let code, let description):
                return (code, description)
            case .circumstanceDescriptionIsEmpty(let code, let description):
                return (code, description)
            case .invalidCircumstancesDescription(let code, let description):
                return (code, description)
            case .photoNotFound(let code, let description):
                return (code, description)
            case .unavailableForBParticipant(let code, let description):
                return (code, description)
            case .registrationFailed(let code, let description):
                return (code, description)
            case .invalidDriverOwnership(let code, let description):
                return (code, description)
            case .invalidRoadAccidentDescription(let code, let description):
                return (code, description)
            case .noFile(let code, let description):
                return (code, description)
            case .incorrectVehicleCertificate(let code, let description):
                return (code, description)
            case .serviceStatuses(let code, let description):
                return (code, description)
            case .validationErrors(let code, let description, _):
                return (code, description)
            case .invalidPolicySeries(let code, let description):
                return (code, description)
            case .invalidPolicyNumber(let code, let description):
                return (code, description)
            case .invalidSDKVersion(let code, let description):
                return (code, description)
            case .noticeIsRejectedBySecondParty(code: let code, description: let description):
                return (code, description)
            case .tooBigLogFile(code: let code, description: let description):
                return (code, description)
        }
    }

    var errorMessage: (title: String?, message: String) {
        switch info.code {
            case 1004: // noActiveSession
                return (
                    title: NSLocalizedString("insurance_euro_protocol_sdk_session_time_out_error_title", comment: ""),
                    message: NSLocalizedString("insurance_euro_protocol_sdk_session_time_out_error", comment: "")
                )
            case 1063, 1056:
                return (
                    title: NSLocalizedString("insurance_euro_protocol_sdk_auth_error_title", comment: ""),
                    message: NSLocalizedString("insurance_euro_protocol_sdk_auth_error", comment: "")
                )
            case 1043:
                return (
                    title: nil,
                    message: NSLocalizedString("insurance_euro_protocol_sdk_unknown_error", comment: "")
                )
            case 1055, 1011, 1070, 1046, 1048:
                return (
                    title: NSLocalizedString("insurance_euro_protocol_sdk_unknown_error_title", comment: ""),
                    message: NSLocalizedString("insurance_euro_protocol_sdk_unknown_error_comment", comment: "")
                )
            case 1010:
                return (
                    title: NSLocalizedString("insurance_euro_protocol_sdk_unknown_error_title", comment: ""),
                    message: NSLocalizedString("insurance_euro_protocol_sdk_no_internet_error", comment: "")
                )
            case 1014:
                return (
                    title: nil,
                    message: NSLocalizedString("insurance_euro_protocol_sdk_epgy_error", comment: "")
                )
            case 1057:
                return (
                    title: nil,
                    message: NSLocalizedString("insurance_euro_protocol_sdk_participant_B_info_missing_error", comment: "")
                )
            case 1013:
                return (
                    title: NSLocalizedString("insurance_euro_protocol_sdk_unknown_error_title", comment: ""),
                    message: info.description
                )
            case 1001:
                return (
                    title: NSLocalizedString("insurance_euro_protocol_invalid_sdk_version_title", comment: ""),
                    message: NSLocalizedString("insurance_euro_protocol_invalid_sdk_version_message", comment: "")
                )
            default:
                return (
                    title: nil,
                    message: info.description
                )
        }
    }

    var validationErrors: [RsaSdkValidationError] {
        switch self {
            case .validationErrors(_, _, let errors):
                return errors
            default:
                return []
        }
    }

    // swiftlint:disable:next function_body_length
    static func convert(from sdkError: RSASDK.Error) -> RsaSdkError {
        switch sdkError {
            case .invalidPolicy:
                return .invalidPolicy(code: sdkError.code, description: sdkError.description)
            case .unknownError:
                return .unknownError(code: sdkError.code, description: sdkError.description)
            case .esiaTokenExpired:
                return .esiaTokenExpired(code: sdkError.code, description: sdkError.description)
            case .participantDataIsEmpty:
                return .participantDataIsEmpty(code: sdkError.code, description: sdkError.description)
            case .draftIsNotRegistered:
                return .draftIsNotRegistered(code: sdkError.code, description: sdkError.description)
            case .draftIsAlreadyRegistered:
                return .draftIsAlreadyRegistered(code: sdkError.code, description: sdkError.description)
            case .draftIsNotSigned:
                return .draftIsNotSigned(code: sdkError.code, description: sdkError.description)
            case .invalidAccidentDate:
                return .invalidAccidentDate(code: sdkError.code, description: sdkError.description)
            case .secureGuidExpired:
                return .secureGuidExpired(code: sdkError.code, description: sdkError.description)
            case .foundActiveSession:
                return .foundActiveSession(code: sdkError.code, description: sdkError.description)
            case .noActiveSession:
                return .noActiveSession(code: sdkError.code, description: sdkError.description)
            case .cantSendPhoto:
                return .cantSendPhoto(code: sdkError.code, description: sdkError.description)
            case .errorSaveImageToSDK:
                return .errorSaveImageToSDK(code: sdkError.code, description: sdkError.description)
            case .networkError:
                return .networkError(code: sdkError.code, description: sdkError.description)
            case .requestTimeout:
                return .requestTimeout(code: sdkError.code, description: sdkError.description)
            case .cantSavePhotoToGallery:
                return .cantSavePhotoToGallery(code: sdkError.code, description: sdkError.description)
            case .errorToReadPolicy:
                return .errorToReadPolicy(code: sdkError.code, description: sdkError.description)
            case .esiaErrorNoInvitationLink:
                return .esiaErrorNoInvitationLink(code: sdkError.code, description: sdkError.description)
            case .invalidGPSCoordinates:
                return .invalidGPSCoordinates(code: sdkError.code, description: sdkError.description)
            case .draftIsIncomplete:
                return .draftIsIncomplete(code: sdkError.code, description: sdkError.description)
            case .ownerDraftSingingError:
                return .ownerDraftSingingError(code: sdkError.code, description: sdkError.description)
            case .draftRejectingError:
                return .draftRejectingError(code: sdkError.code, description: sdkError.description)
            case .draftIsNotFound:
                return .draftIsNotFound(code: sdkError.code, description: sdkError.description)
            case .draftFixingError:
                return .draftFixingError(code: sdkError.code, description: sdkError.description)
            case .invalidQRImage:
                return .invalidQRImage(code: sdkError.code, description: sdkError.description)
            case .invalidQRFormat:
                return .invalidQRFormat(code: sdkError.code, description: sdkError.description)
            case .tooManyDamagePhotosForParticipant:
                return .tooManyDamagePhotosForParticipant(code: sdkError.code, description: sdkError.description)
            case .tooManyPhotos:
                return .tooManyPhotos(code: sdkError.code, description: sdkError.description)
            case .operationAborted:
                return .operationAborted(code: sdkError.code, description: sdkError.description)
            case .getUserDataError:
                return .getUserDataError(code: sdkError.code, description: sdkError.description)
            case .invalidWitnessName:
                return .invalidWitnessName(code: sdkError.code, description: sdkError.description)
            case .invalidWitnessAddress:
                return .invalidWitnessAddress(code: sdkError.code, description: sdkError.description)
            case .invalidWitnessPhone:
                return .invalidWitnessPhone(code: sdkError.code, description: sdkError.description)
            case .noCameraAccess:
                return .noCameraAccess(code: sdkError.code, description: sdkError.description)
            case .didCancelCamera:
                return .didCancelCamera(code: sdkError.code, description: sdkError.description)
            case .noLocationAccess:
                return .noLocationAccess(code: sdkError.code, description: sdkError.description)
            case .invalidInputData:
                return .invalidInputData(code: sdkError.code, description: sdkError.description)
            case .unexpectedType:
                return .unexpectedType(code: sdkError.code, description: sdkError.description)
            case .tooManyPlacePhotos:
                return .tooManyPlacePhotos(code: sdkError.code, description: sdkError.description)
            case .checkUserDataByESIA:
                return .checkUserDataByESIA(code: sdkError.code, description: sdkError.description)
            case .invalidFirstBumpScheme:
                return .invalidFirstBumpScheme(code: sdkError.code, description: sdkError.description)
            case .draftIsConfirmedAndUneditable:
                return .draftIsConfirmedAndUneditable(code: sdkError.code, description: sdkError.description)
            case .serverError:
                return .serverError(code: sdkError.code, description: sdkError.description)
            case .invalidOtherPhotoItemName:
                return .invalidOtherPhotoItemName(code: sdkError.code, description: sdkError.description)
            case .invalidOtherPhotoDescription:
                return .invalidOtherPhotoDescription(code: sdkError.code, description: sdkError.description)
            case .emptyCircumstancesList:
                return .emptyCircumstancesList(code: sdkError.code, description: sdkError.description)
            case .invalidCircumstancesCount:
                return .invalidCircumstancesCount(code: sdkError.code, description: sdkError.description)
            case .circumstanceDescriptionIsEmpty:
                return .circumstanceDescriptionIsEmpty(code: sdkError.code, description: sdkError.description)
            case .invalidCircumstancesDescription:
                return .invalidCircumstancesDescription(code: sdkError.code, description: sdkError.description)
            case .photoNotFound:
                return .photoNotFound(code: sdkError.code, description: sdkError.description)
            case .unavailableForBParticipant:
                return .unavailableForBParticipant(code: sdkError.code, description: sdkError.description)
            case .registrationFailed: // TODO: parse errors .registrationFailed(errors: [RSASDK.AccidentRegistrationError])
                return .registrationFailed(code: sdkError.code, description: sdkError.description)
            case .invalidDriverOwnership:
                return .invalidDriverOwnership(code: sdkError.code, description: sdkError.description)
            case .invalidRoadAccidentDescription:
                return .invalidRoadAccidentDescription(code: sdkError.code, description: sdkError.description)
            case .noFile:
                return .noFile(code: sdkError.code, description: sdkError.description)
            case .incorrectVehicleCertificate:
                return .incorrectVehicleCertificate(code: sdkError.code, description: sdkError.description)
            case .serviceStatuses:
                return .serviceStatuses(code: sdkError.code, description: sdkError.description)
            case .invalidPolicySeries:
                return .invalidPolicySeries(code: sdkError.code, description: sdkError.description)
            case .invalidPolicyNumber:
                return .invalidPolicyNumber(code: sdkError.code, description: sdkError.description)
            case .invalidSDKVersion:
                return .invalidSDKVersion(code: sdkError.code, description: sdkError.description)
            case .noticeIsRejectedBySecondParty:
                return .noticeIsRejectedBySecondParty(code: sdkError.code, description: sdkError.description)
            case .tooBigLogFile:
                return .tooBigLogFile(code: sdkError.code, description: sdkError.description)
            @unknown default:
                return .unknownError(code: sdkError.code, description: sdkError.description)
        }
    }
}

enum RsaSdkValidationError: Error {
    case emptyInvitationCode(code: Int, description: String)

    case invalidAccidentCoordinates(code: Int, description: String)

    case emptyAccidentDate(code: Int, description: String)

    case emptyDTPScheme(code: Int, description: String)

    case invalidTransportBrand(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidTransportModel(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidTransportVIN(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidTransportRegmark(code: Int, description: String, participant: EuroProtocolParticipant)

    case emptyCircumstancesList(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidCircumstancesCount(code: Int, description: String, participant: EuroProtocolParticipant)

    case circumstanceDescriptionIsEmpty(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidCircumstancesDescription(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidLicenseSeriesCount(code: Int, description: String)

    case invalidLicenseNumberCount(code: Int, description: String)

    case emptyLicenseCategoryList(code: Int, description: String)

    case invalidLicenseIssueDate(code: Int, description: String)

    case invalidLicenseExpiryDate(code: Int, description: String)

    case invalidDriverAddress(code: Int, description: String)

    case invalidDriverPhone(code: Int, description: String)

    case emptyOwnerAddress(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidOwnerName(code: Int, description: String, participant: EuroProtocolParticipant)

    case emptyInitialImpactSector(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidPolicyID(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidPolicySeries(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidPolicyNumber(code: Int, description: String, participant: EuroProtocolParticipant)

    case emptyPolicyInsurer(code: Int, description: String, participant: EuroProtocolParticipant)

    case emptyDamagedDetailPhoto(code: Int, description: String, vehiclePart: EuroProtocolVehiclePart, participant: EuroProtocolParticipant)

    case emptyRegmarkPhoto(code: Int, description: String, participant: EuroProtocolParticipant)

    case noPolicy(code: Int, description: String, participant: EuroProtocolParticipant)

    case noOwner(code: Int, description: String, participant: EuroProtocolParticipant)

    case noCircumstance(code: Int, description: String, participant: EuroProtocolParticipant)

    case noDamages(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidOwnerNameLength(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidOwnerSurnameLength(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidOwnerMiddleNameLength(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidSymbolsInOwnerName(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidSymbolsInOwnerSurname(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidSymbolsInOwnerMiddleName(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidOwnerAddressLength(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidOwnerOrganizationNameLength(code: Int, description: String, participant: EuroProtocolParticipant)

    case invalidSymbolsInOwnerAddress(code: Int, description: String, participant: EuroProtocolParticipant)

    case unknown(code: Int, description: String)

    var info: (code: Int, description: String) {
        switch self {
            case .emptyInvitationCode(let code, let description):
                return (code, description)
            case .invalidAccidentCoordinates(let code, let description):
                return (code, description)
            case .emptyAccidentDate(let code, let description):
                return (code, description)
            case .emptyDTPScheme(let code, let description):
                return (code, description)
            case .invalidTransportBrand(let code, let description, _):
                return (code, description)
            case .invalidTransportModel(let code, let description, _):
                return (code, description)
            case .invalidTransportVIN(let code, let description, _):
                return (code, description)
            case .invalidTransportRegmark(let code, let description, _):
                return (code, description)
            case .emptyCircumstancesList(let code, let description, _):
                return (code, description)
            case .invalidCircumstancesCount(let code, let description, _):
                return (code, description)
            case .circumstanceDescriptionIsEmpty(let code, let description, _):
                return (code, description)
            case .invalidCircumstancesDescription(let code, let description, _):
                return (code, description)
            case .invalidLicenseSeriesCount(let code, let description):
                return (code, description)
            case .invalidLicenseNumberCount(let code, let description):
                return (code, description)
            case .emptyLicenseCategoryList(let code, let description):
                return (code, description)
            case .invalidLicenseIssueDate(let code, let description):
                return (code, description)
            case .invalidLicenseExpiryDate(let code, let description):
                return (code, description)
            case .invalidDriverAddress(let code, let description):
                return (code, description)
            case .invalidDriverPhone(let code, let description):
                return (code, description)
            case .emptyOwnerAddress(let code, let description, _):
                return (code, description)
            case .invalidOwnerName(let code, let description, _):
                return (code, description)
            case .emptyInitialImpactSector(let code, let description, _):
                return (code, description)
            case .invalidPolicyID(let code, let description, _):
                return (code, description)
            case .invalidPolicySeries(let code, let description, _):
                return (code, description)
            case .invalidPolicyNumber(let code, let description, _):
                return (code, description)
            case .emptyPolicyInsurer(let code, let description, _):
                return (code, description)
            case .emptyDamagedDetailPhoto(let code, let description, _, _):
                return (code, description)
            case .emptyRegmarkPhoto(let code, let description, _):
                return (code, description)
            case .noPolicy(let code, let description, _):
                return (code, description)
            case .noOwner(let code, let description, _):
                return (code, description)
            case .noCircumstance(let code, let description, _):
                return (code, description)
            case .noDamages(let code, let description, _):
                return (code, description)
            case .invalidOwnerNameLength(let code, let description, _):
                return (code, description)
            case .invalidOwnerSurnameLength(let code, let description, _):
                return (code, description)
            case .invalidOwnerMiddleNameLength(let code, let description, _):
                return (code, description)
            case .invalidSymbolsInOwnerName(let code, let description, _):
                return (code, description)
            case .invalidSymbolsInOwnerSurname(let code, let description, _):
                return (code, description)
            case .invalidSymbolsInOwnerMiddleName(let code, let description, _):
                return (code, description)
            case .invalidOwnerAddressLength(let code, let description, _):
                return (code, description)
            case .invalidOwnerOrganizationNameLength(let code, let description, _):
                return (code, description)
            case .invalidSymbolsInOwnerAddress(let code, let description, _):
                return (code, description)
            case .unknown(let code, let description):
                return (code, description)
        }
    }

    // swiftlint:disable:next function_body_length
    static func convert(from skdError: RSASDK.ValidationError) -> RsaSdkValidationError {
        switch skdError {
            case .emptyInvitationCode:
                return .emptyInvitationCode(code: skdError.code, description: skdError.description)
            case .invalidAccidentCoordinates:
                return .invalidAccidentCoordinates(code: skdError.code, description: skdError.description)
            case .emptyAccidentDate:
                return .emptyAccidentDate(code: skdError.code, description: skdError.description)
            case .emptyDTPScheme:
                return .emptyDTPScheme(code: skdError.code, description: skdError.description)
            case .invalidTransportBrand(let sdkParticipant):
                return .invalidTransportBrand(code: skdError.code, description: skdError.description,
                    participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidTransportModel(let sdkParticipant):
                return .invalidTransportModel(code: skdError.code, description: skdError.description,
                         participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidTransportVIN(let sdkParticipant):
                return .invalidTransportVIN(code: skdError.code, description: skdError.description,
                         participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidTransportRegmark(let sdkParticipant):
                return .invalidTransportRegmark(code: skdError.code, description: skdError.description,
                         participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .emptyCircumstancesList(let sdkParticipant):
                return .emptyCircumstancesList(code: skdError.code, description: skdError.description,
                         participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidCircumstancesCount(let sdkParticipant):
                return .invalidCircumstancesCount(code: skdError.code, description: skdError.description,
                         participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .circumstanceDescriptionIsEmpty(let sdkParticipant):
                return .circumstanceDescriptionIsEmpty(code: skdError.code, description: skdError.description,
                         participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidCircumstancesDescription(let sdkParticipant):
                return .invalidCircumstancesDescription(code: skdError.code, description: skdError.description,
                         participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidLicenseSeriesCount:
                return .invalidLicenseSeriesCount(code: skdError.code, description: skdError.description)
            case .invalidLicenseNumberCount:
                return .invalidLicenseNumberCount(code: skdError.code, description: skdError.description)
            case .emptyLicenseCategoryList:
                return .emptyLicenseCategoryList(code: skdError.code, description: skdError.description)
            case .invalidLicenseIssueDate:
                return .invalidLicenseIssueDate(code: skdError.code, description: skdError.description)
            case .invalidLicenseExpiryDate:
                return .invalidLicenseExpiryDate(code: skdError.code, description: skdError.description)
            case .invalidDriverAddress:
                return .invalidDriverAddress(code: skdError.code, description: skdError.description)
            case .invalidDriverPhone:
                return .invalidDriverPhone(code: skdError.code, description: skdError.description)
            case .emptyOwnerAddress(let sdkParticipant):
                return .emptyOwnerAddress(code: skdError.code, description: skdError.description,
                         participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidOwnerName(let sdkParticipant):
                return .invalidOwnerName(code: skdError.code, description: skdError.description,
                         participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .emptyInitialImpactSector(let sdkParticipant):
                return .emptyInitialImpactSector(code: skdError.code, description: skdError.description,
                         participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidPolicyID(let sdkParticipant):
                return .invalidPolicyID(code: skdError.code, description: skdError.description,
                         participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidPolicySeries(let sdkParticipant):
                return .invalidPolicySeries(code: skdError.code, description: skdError.description,
                         participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidPolicyNumber(let sdkParticipant):
                return .invalidPolicyNumber(code: skdError.code, description: skdError.description,
                         participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .emptyPolicyInsurer(let sdkParticipant):
                return .emptyPolicyInsurer(code: skdError.code, description: skdError.description,
                         participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .emptyDamagedDetailPhoto(let sdkDetailType, let sdkParticipant):
                return .emptyDamagedDetailPhoto(
                    code: skdError.code,
                    description: skdError.description,
                    vehiclePart: EuroProtocolVehiclePart.convert(from: sdkDetailType),
                    participant: EuroProtocolParticipant.convert(from: sdkParticipant)
                )
            case .emptyRegmarkPhoto(let sdkParticipant):
                return .emptyRegmarkPhoto(code: skdError.code, description: skdError.description,
                                          participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .noPolicy(let sdkParticipant):
                return .noPolicy(code: skdError.code, description: skdError.description,
                                 participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .noOwner(let sdkParticipant):
                return .noOwner(code: skdError.code, description: skdError.description,
                                participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .noCircumstance(let sdkParticipant):
                return .noCircumstance(code: skdError.code, description: skdError.description,
                                       participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .noDamages(let sdkParticipant):
                return .noDamages(code: skdError.code, description: skdError.description,
                                  participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidOwnerNameLength(let sdkParticipant):
                return .invalidOwnerNameLength(code: skdError.code, description: skdError.description,
                                               participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidOwnerSurnameLength(let sdkParticipant):
                return .invalidOwnerSurnameLength(code: skdError.code, description: skdError.description,
                                                  participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidOwnerMiddleNameLength(let sdkParticipant):
                return .invalidOwnerMiddleNameLength(code: skdError.code, description: skdError.description,
                                                     participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidSymbolsInOwnerName(let sdkParticipant):
                return .invalidSymbolsInOwnerName(code: skdError.code, description: skdError.description,
                                                  participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidSymbolsInOwnerSurname(let sdkParticipant):
                return .invalidSymbolsInOwnerSurname(code: skdError.code, description: skdError.description,
                                                     participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidSymbolsInOwnerMiddleName(let sdkParticipant):
                return .invalidSymbolsInOwnerMiddleName(code: skdError.code, description: skdError.description,
                                                        participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidOwnerAddressLength(let sdkParticipant):
                return .invalidOwnerAddressLength(code: skdError.code, description: skdError.description,
                                                  participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidOwnerOrganizationNameLength(let sdkParticipant):
                return .invalidOwnerOrganizationNameLength(code: skdError.code, description: skdError.description,
                                                           participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            case .invalidSymbolsInOwnerAddress(let sdkParticipant):
                return .invalidSymbolsInOwnerAddress(code: skdError.code, description: skdError.description,
                                                     participant: EuroProtocolParticipant.convert(from: sdkParticipant))
            @unknown default:
                return .unknown(code: skdError.code, description: skdError.description)
        }
    }
}
