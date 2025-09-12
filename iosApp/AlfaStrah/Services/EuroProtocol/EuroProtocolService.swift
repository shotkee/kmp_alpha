//
//  EuroProtocolService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 29.03.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Legacy

enum EuroProtocolServicePermissionsStatus {
    case permissionsGranted
    case locationPermissionRequired
    case cameraAccessRequired
    case photoStoragePermissionRequired
    case unknown
}

enum EuroProtocolServiceError: Error {
    case successResponseParsingError
    case sdkAuthInfoMissing
    case sdkError(RsaSdkError)
    case error(AlfastrahError)

    var errorMessage: (title: String, message: String) {
        switch self {
            case .sdkAuthInfoMissing:
                return (
                    title: NSLocalizedString("insurance_euro_protocol_sdk_auth_error_title", comment: ""),
                    message: displayValue ?? ""
                )
            case .successResponseParsingError:
                return (
                    title: NSLocalizedString("common_error_something_went_wrong_tile", comment: ""),
                    message: displayValue ?? ""
                )
            case .sdkError(let error):
                return (
                    title: error.errorMessage.title ?? "",
                    message: error.errorMessage.message
                )
            case .error(let error):
                return (
                    title: NSLocalizedString("common_loading_error", comment: ""),
                    message: error.displayValue ?? ""
                )
        }
    }
}

protocol EuroProtocolService: Updatable {
    var permissionsStatus: EuroProtocolServicePermissionsStatus { get }
    func subscribeForPermissionsStatusUpdates(listener: @escaping (EuroProtocolServicePermissionsStatus) -> Void) -> Subscription
    func requestPermissions()

    // Esia auth
    var esiaUser: EsiaUser? { get }

    func getEsiaLinkInfo(completion: @escaping (Result<EsiaLinkInfo, EuroProtocolServiceError>) -> Void)
    func getEsiaUser(tokenScs: String, completion: @escaping (Result<EsiaUserData, EuroProtocolServiceError>) -> Void)

    // Alfastrah
    func reportCreatedOsagoEvent(
        insurance: SeriesAndNumberDocument,
        aisNumber: String,
        completion: @escaping (Result<String, EuroProtocolServiceError>) -> Void
    )

    // Local data
    func clearCachedData()
    var hasDisagreements: Bool? { get set }
    var participantBInviteModel: ParticipantBInviteModel { get set }
    var aisIdentifier: String? { get set }
    var aisAlfaRegistrationId: String? { get set }

    // SDK methods

    func checkActiveSessionPresent() -> Bool

    var reviewTimeLeft: TimeInterval? { get }

    /// SDK_1 (initSDK) Инициализация SDK
    func startSdk(completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void)

    /// SDK_2 (finalizeSDK) Завершение работы SDK
    func stopSdk(completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void)

    /// SDK_4 (setProtectedPhoto) Защищенная фотография
    func protectedPhoto(
        action: EuroProtocolPhotoAction,
        imageType: EuroProtocolPrivateImageType,
        completion: @escaping (Result<UIImage?, EuroProtocolServiceError>) -> Void
    )

    /// SDK_5 (setFreePhoto) Незащищенная фотография
    func freePhoto(index: Int, action: EuroProtocolPhotoAction, completion: @escaping (Result<UIImage?, EuroProtocolServiceError>) -> Void)

    /// SDK_6 (setPolicyInfo) Добавление полиса
    func setPolicyInfo(
        participant: EuroProtocolParticipant,
        seriesAndNumber: SeriesAndNumberDocument,
        completion: @escaping (Result<OSAGOCheckParticipant, EuroProtocolServiceError>) -> Void
    )

    /// SDK_7 (setDriverInfo) Передача данных водителя
    func setDriverInfo(info: DriverDocuments, completion: @escaping (Result<String, EuroProtocolServiceError>) -> Void)

    /// SDK_8 (initLinkQR) Генерация QR-Code приглашения второго участника
    func initLinkQR(
        add participant: EuroProtocolParticipantInviteInfo,
        completion: @escaping (Result<UIImage, EuroProtocolServiceError>) -> Void
    )

    /// SDK_11 (setAccidentCoords) Сохранение координат места ДТП
    func setAccidentCoords(address: String, completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void)

    /// SDK_12 (setAccidentTime) Передача даты и времени ДТП
    func setAccidentDate(_ date: Date, completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void)

    /// SDK_14 (setAccidentFirstHit) Передача места первоначального удара в ТС участника
    func setAccidentFirstHitPlace(
        participant: EuroProtocolParticipant,
        schemeType: EuroProtocolFirstBumpScheme,
        completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void
    )

    /// SDK_15 (setAccidentCircumstances) Передача кода обстоятельства ДТП
    func setAccidentCircumstances(
        participant: EuroProtocolParticipant,
        circumstances: [EuroProtocolCircumstance],
        description: String?,
        completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void
    )

    /// SDK_16 (setAccidentDamagedParts) Передача списка поврежденных деталей ТС
    func setAccidentDamagedParts(
        participant: EuroProtocolParticipant,
        parts: [EuroProtocolVehiclePart],
        completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void
    )

    /// SDK_17 (setAccidentWitnessInfo) Передача данных свидетелей ДТП
    func setAccidentWitnessInfo(
        first: EuroProtocolWitness?,
        second: EuroProtocolWitness?,
        completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void
    )

    /// SDK_18 (createDraft) Создание черновика извещения о ДТП в ЕПГУ
    func createDraft(
        disagreements: Bool,
        validateOnly: Bool,
        completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void
    )

    /// SDK_19 (acceptDraft) Подписание черновика извещения о ДТП
    func acceptDraft(completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void)

    /// SDK_20 (declineDraft) Отклонение черновика извещения
    func declineDraft(completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void)

    // SDK_21 (sendNotice) Фиксация извещения АИС ОСАГО
    func sendNotice(completion: @escaping (Result<String, EuroProtocolServiceError>) -> Void)

    /// SDK_22 (setOwner) Передача данных владельца ТС
    func setOwner(
        participant: EuroProtocolParticipant,
        owner: EuroProtocolOwner,
        completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void
    )

    /// SDK_23 (getCurrentContent) Чтение полей черновика
    func getCurrentDraftContentModel(
        completion: @escaping (Result<EuroProtocolCurrentDraftContentModel, EuroProtocolServiceError>) -> Void
    )

    /// SDK_24 (getDraftStatus) Чтение статуса черновика ЕПГУ
    func getDraftStatus(completion: @escaping (Result<EuroProtocolDraftStatus, EuroProtocolServiceError>) -> Void)

    /// SDK_25 (getDraftContent) Чтение полей черновика ЕПГУ
    func getDraftContent(completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void)

    /// SDK_26 (getImage) Получение изображения по номеру документа
    func getImage(type: EuroProtocolImageType) -> Result<UIImage?, EuroProtocolServiceError>

    /// SDK_29 (setAdditionalData) Метод отправки дополнительной информации по ДТП
    func setAccidentDescription(
        participant: EuroProtocolParticipant,
        accidentDescription: String?,
        completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void)
}
