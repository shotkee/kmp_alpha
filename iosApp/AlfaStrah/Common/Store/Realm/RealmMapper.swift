//
// RealmMapper
// AlfaStrah
//
// Created by Eugene Egorov on 04 February 2019.
// Copyright (c) 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmEntity: Object {
}

class RealmTransformer<T: Entity> {
    var objectType: RealmEntity.Type {
        RealmEntity.self
    }

    func transform(entity: T) throws -> RealmEntity {
        throw RealmError.typeMismatch
    }

    func transform<R: RealmEntity>(entity: T) throws -> R {
        if let object = try transform(entity: entity) as? R {
            return object
        } else {
            throw RealmError.typeMismatch
        }
    }

    func transform(object: RealmEntity) throws -> T {
        throw RealmError.typeMismatch
    }
}

class RealmMapper {
    let schemaVersion: UInt64 = 44

    let objectTypes: [RealmEntity.Type] = [
        RealmAppNotification.self,
        RealmAppNotificationField.self,
        RealmPhone.self,
        RealmStoa.self,
        RealmCoordinate.self,
        RealmInsurance.self,
        RealmInsuranceParticipant.self,
        RealmInsuranceBill.self,
        RealmVehicle.self,
        RealmTripSegment.self,
        RealmInfoFieldGroup.self,
        RealmInfoField.self,
        RealmInsuranceCategory.self,
        RealmInsuranceMain.self,
        RealmInsuranceShort.self,
        RealmInsuranceGroup.self,
        RealmInsuranceGroupCategory.self,
        RealmInsuranceCategoryMain.self,
        RealmInstruction.self,
        RealmInstructionStep.self,
        RealmSosModel.self,
        RealmSosPhone.self,
        RealmSosActivityModel.self,
        RealmLoyaltyOperation.self,
        RealmLoyaltyModel.self,
        RealmInsuranceDeeplinkType.self,
        RealmQuestionCategory.self,
        RealmQuestionGroup.self,
        RealmQuestion.self,
        RealmAutoEventAttachment.self,
        RealmAttachmentsUploadStatus.self,
        RealmPassengersEventAttachment.self,
        RealmAutoPhotoAttachmentDraft.self,
        RealmAutoEventDraft.self,
        RealmPassengersEventDraft.self,
        RealmRiskValue.self,
        RealmVzrOnOffInsurance.self,
        RealmVzrOnOffTrip.self,
        RealmAttachmentEventLog.self,
        RealmAttachmentSavingFailureLog.self,
        RealmAccidentEventAttachment.self,
        RealmMedicalCardFileEntry.self,
        RealmSosEmergencyCommunication.self,
        RealmSosEmergencyCommunicationBlock.self,
        RealmSosEmergencyCommunicationItem.self,
        RealmSosUXPhone.self,
        RealmSosEmergencyConnectionScreenInformation.self,
        RealmSosInsured.self,
        RealmInsuranceType.self,
        RealmAnonymousSos.self,
        RealmInteractiveSupportOnboardingShowEntry.self,
        RealmSosUXPhone.self,
        RealmVoipCall.self,
		RealmChatFileEntry.self,
		RealmChatOperator.self,
		RealmInsuranceRender.self,
		RealmInsuranceRenderHeader.self,
        RealmVoipCall.self,
		RealmAnalyticsInsuranceProfile.self,
		RealmThemedValue.self,
		RealmBonusPointsData.self,
		RealmThemedText.self,
		RealmBonus.self,
		RealmPoints.self,
		RealmThemedButton.self,
		RealmBackendAction.self,
		RealmThemedLink.self,
		RealmChatFileEntry.self,
		RealmConfidant.self,
		RealmConfidantBanner.self
    ]

    func transformer<T: Entity>() throws -> RealmTransformer<T> {
        switch T.self {
            case is InsuranceMain.Type:
                return RealmInsuranceMainTransformer<T>()
            case is AppNotification.Type:
                return RealmAppNotificationTransformer<T>()
            case is Insurance.Type:
                return RealmInsuranceTransformer<T>()
            case is InsuranceCategory.Type:
                return RealmInsuranceCategoryTransformer<T>()
            case is LoyaltyModel.Type:
                return RealmLoyaltyModelTransformer<T>()
            case is QuestionCategory.Type:
                return RealmQuestionCategoryTransformer<T>()
            case is AutoEventDraft.Type:
                return RealmAutoEventDraftTransformer<T>()
            case is PassengersEventDraft.Type:
                return RealmPassengersEventDraftTransformer<T>()
            case is AutoPhotoAttachmentDraft.Type:
                return RealmAutoPhotoAttachmentDraftTransformer<T>()
            case is AutoEventAttachment.Type:
                return RealmAutoEventAttachmentTransformer<T>()
            case is AttachmentsUploadStatus.Type:
                return RealmAttachmentsUploadStatusTransformer<T>()
            case is PassengersEventAttachment.Type:
                return RealmPassengersEventAttachmentTransformer<T>()
            case is VzrOnOffInsurance.Type:
                return RealmVzrOnOffInsuranceTransformer<T>()
            case is AttachmentEventLog.Type:
                return RealmAttachmentEventLogTransformer<T>()
            case is AttachmentSavingFailureLog.Type:
                return RealmAttachmentSavingFailureLogTransformer<T>()
            case is AccidentEventAttachment.Type:
                return RealmAccidentEventAttachmentTransformer<T>()
            case is MedicalCardFileEntry.Type:
                return RealmMedicalCardFileEntryTransformer<T>()
            case is SosEmergencyCommunication.Type:
                return RealmSosEmergencyCommunicationTransformer<T>()
			case is Confidant.Type:
				return RealmConfidantTransformer<T>()
			case is ConfidantBanner.Type:
				return RealmConfidantBannerTransformer<T>()
            case is SosEmergencyCommunicationBlock.Type:
                return RealmSosEmergencyCommunicationBlockTransformer<T>()
            case is SosEmergencyCommunicationItem.Type:
                return RealmSosEmergencyCommunicationItemTransformer<T>()
            case is SosUXPhone.Type:
                return RealmSosUXPhoneTransformer<T>()
			case is ThemedValue.Type:
				return RealmThemedValueTransformer<T>()
            case is SosEmergencyConnectionScreenInformation.Type:
                return RealmSosEmergencyConnectionScreenInformationTransformer<T>()
            case is SosInsured.Type:
                return RealmSosInsuredTransformer<T>()
            case is InsuranceType.Type:
                return RealmSosInsuranceTypeTransformer<T>()
            case is AnonymousSos.Type:
                return RealmAnonymousSosTransformer<T>()
            case is InteractiveSupportOnboardingShowEntry.Type:
                return RealmInteractiveSupportOnboardingShowEntryTransformer<T>()
            case is VoipCall.Type:
                return RealmVoipCallTransformer<T>()
			case is InsuranceRender.Type:
				return RealmInsuranceRenderTransformer<T>()
			case is InsuranceRenderHeader.Type:
				return RealmInsuranceRenderHeaderTransformer<T>()
			case is AnalyticsInsuranceProfile.Type:
				return RealmAnalyticsInsuranceProfileTransformer<T>()
			case is BonusPointsData.Type:
				return RealmBonusPointsDataTransformer<T>()
			case is BackendAction.Type:
				return RealmBackendActionTransformer<T>()
			case is ThemedLink.Type:
				return RealmThemedLinkTransformer<T>()
			case is ChatFileEntry.Type:
				return RealmChatFileEntryTransformer<T>()
			case is CascanaChatOperator.Type:
				return RealmChatOperatorTransformer<T>()
            default:
                throw RealmError.noTransformer
        }
    }
}
