//
//  MockRestOsagoProlongationService.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 03.03.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Legacy

class MockOsagoProlongationService: OsagoProlongationService {
    func insurancesOsagoProlongationCalcRequest(
        insuranceId: String,
        completion: @escaping (Result<OsagoProlongation, AlfastrahError>) -> Void
    ) -> NetworkTask {
        let task = CancellableMockTask(
            result: .success(osagoProlongation),
            completion: completion
        )
        task.start()
        return task
    }

    func insurancesOsagoProlongationChangeRequest(
        changeRequest: OsagoProlongationChangeRequest,
        completion: @escaping (Result<Void, AlfastrahError>) -> Void
    ) {
        completion(.failure(.api(.init(httpCode: 999, internalCode: 0, title: "Not implemented", message: "Not implemented"))))
    }

    func insurancesOsagoProlongationDeeplinkRequest(
        insuranceId: String,
        agreedToPersonalDataPolicy: Bool,
        completion: @escaping (Result<OsagoProlongationDeeplink, AlfastrahError>) -> Void
    ) {
        completion(.failure(.api(.init(httpCode: 999, internalCode: 0, title: "Not implemented", message: "Not implemented"))))
    }

    func insurancesOsagoProlongationProgramRequest(
        insuranceID: String,
        completion: @escaping (Result<OsagoProlongationURLs, AlfastrahError>) -> Void
    ) -> NetworkTask {
        let task = CancellableMockTask(
            result: .failure(
                .api(
                    .init(
                        httpCode: 999,
                        internalCode: 0,
                        title: "Not implemented",
                        message: "Not implemented"
                    )
                )
            ),
            completion: completion
        )
        task.start()
        return task
    }

    private lazy var osagoProlongation: OsagoProlongation = .init(
        state: state,
        calculateInfo: calculateInfo,
        errorInfo: errorInfo,
        editInfo: editInfo
    )

    private lazy var state: OsagoProlongation.StateType = .error

    private lazy var calculateInfo: OsagoProlongationCalculateInfo = {
        OsagoProlongationCalculateInfo(
            sum: 56775785,
            startDate: Date(),
            endDate: Date(),
            carMark: "NISSAN SKYLINE R34 GTR",
            carRegistrationNumber: "AA 1111 AA",
            carVin: "CMKVDKMDLVMLVMDLMVDLMLKNDVLNDLVNDLNVDLNVDLVNDLNVLDNVLNVLDNVL"
        )
    }()

    private lazy var errorInfo: OsagoProlongationErrorInfo = {
        OsagoProlongationErrorInfo(
            title: "ERROR ERROR ERROR ERROR ERROR",
            message: "error error error error error error error",
            errorsArray: [
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error",
                "error error error error error error error"
            ]
        )

    }()

    private lazy var editInfo: OsagoProlongationEditInfo = {
        OsagoProlongationEditInfo(
            description: "description description description description description",
            participants: [
                OsagoProlongationParticipant(
                    description: "description description description description description",
                    title: "title title title title title",
                    detailed: OsagoProlongationParticipantDetailed(
                        description: "description description description description description",
                        fieldGroups: [
                            OsagoProlongationFieldGroup(
                                title: "title title title title title",
                                fields: [
                                    OsagoProlongationField(
                                        id: UUID().uuidString,
                                        title: "ФИО",
                                        value: "Иванов Иван Иванович",
                                        hasError: false,
                                        dataType: nil,
                                        dataString: nil,
                                        dataDate: nil,
                                        dataGeo: nil,
                                        dataDriverLicense: nil
                                    ),
                                    OsagoProlongationField(
                                        id: UUID().uuidString,
                                        title: "Дата рождения",
                                        value: "5 августа 1992",
                                        hasError: false,
                                        dataType: nil,
                                        dataString: nil,
                                        dataDate: nil,
                                        dataGeo: nil,
                                        dataDriverLicense: nil
                                    ),
                                    OsagoProlongationField(
                                        id: UUID().uuidString,
                                        title: "Серия и номер паспорта",
                                        value: "1617 188271",
                                        hasError: false,
                                        dataType: nil,
                                        dataString: nil,
                                        dataDate: nil,
                                        dataGeo: nil,
                                        dataDriverLicense: nil
                                    ),
                                    OsagoProlongationField(
                                        id: UUID().uuidString,
                                        title: "Дата выдачи паспорта",
                                        value: "5 августа 2008",
                                        hasError: false,
                                        dataType: nil,
                                        dataString: nil,
                                        dataDate: nil,
                                        dataGeo: nil,
                                        dataDriverLicense: nil
                                    )
                                ]
                            ),
                            OsagoProlongationFieldGroup(
                                title: "title title title title title",
                                fields: [
                                    OsagoProlongationField(
                                        id: UUID().uuidString,
                                        title: "Серия и номер ВУ",
                                        value: "77 01397000",
                                        hasError: true,
                                        dataType: .driverLicense,
                                        dataString: nil,
                                        dataDate: nil,
                                        dataGeo: nil,
                                        dataDriverLicense: SeriesAndNumberDocument(
                                            series: "77",
                                            number: "01397000"
                                        )
                                    ),
                                    OsagoProlongationField(
                                        id: UUID().uuidString,
                                        title: "Дата выдачи ВУ",
                                        value: "5 августа 1992",
                                        hasError: true,
                                        dataType: .date,
                                        dataString: nil,
                                        dataDate: Date(),
                                        dataGeo: nil,
                                        dataDriverLicense: nil
                                    ),
                                    OsagoProlongationField(
                                        id: UUID().uuidString,
                                        title: "Адрес прописки",
                                        value: "Комарова 25а, 14",
                                        hasError: true,
                                        dataType: .geo,
                                        dataString: nil,
                                        dataDate: nil,
                                        dataGeo: GeoPlace(
                                            title: "GeoPlace Title",
                                            description: "GeoPlace description",
                                            fullTitle: "GeoPlace fullTitle",
                                            country: "Украина",
                                            region: "Московская обл.",
                                            district: "Комунарский",
                                            city: "Москва",
                                            street: "Поварская",
                                            house: "52",
                                            apartment: "1423",
											fiasId: nil,
											fiasLevel: nil,
											coordinate: nil
                                        ),
                                        dataDriverLicense: nil
                                    ),
                                    OsagoProlongationField(
                                        id: UUID().uuidString,
                                        title: "String data",
                                        value: "String value",
                                        hasError: true,
                                        dataType: .string,
                                        dataString: "String value",
                                        dataDate: nil,
                                        dataGeo: nil,
                                        dataDriverLicense: nil
                                    )
                                ]
                            )
                        ]
                    ),
                    hasError: true,
                    errorText: "errorText errorText errorText errorText errorText errorText errorText"
                ),
                OsagoProlongationParticipant(
                    description: "description description description description description",
                    title: "title title title title title",
                    detailed: OsagoProlongationParticipantDetailed(
                        description: "description description description description description",
                        fieldGroups: [
                            OsagoProlongationFieldGroup(
                                title: "title title title title title",
                                fields: [
                                    OsagoProlongationField(
                                        id: UUID().uuidString,
                                        title: "ФИО",
                                        value: "Иванов Иван Иванович",
                                        hasError: false,
                                        dataType: nil,
                                        dataString: nil,
                                        dataDate: nil,
                                        dataGeo: nil,
                                        dataDriverLicense: nil
                                    ),
                                    OsagoProlongationField(
                                        id: UUID().uuidString,
                                        title: "Дата рождения",
                                        value: "5 августа 1992",
                                        hasError: false,
                                        dataType: nil,
                                        dataString: nil,
                                        dataDate: nil,
                                        dataGeo: nil,
                                        dataDriverLicense: nil
                                    ),
                                    OsagoProlongationField(
                                        id: UUID().uuidString,
                                        title: "Серия и номер паспорта",
                                        value: "1617 188271",
                                        hasError: false,
                                        dataType: nil,
                                        dataString: nil,
                                        dataDate: nil,
                                        dataGeo: nil,
                                        dataDriverLicense: nil
                                    ),
                                    OsagoProlongationField(
                                        id: UUID().uuidString,
                                        title: "Дата выдачи паспорта",
                                        value: "5 августа 2008",
                                        hasError: false,
                                        dataType: nil,
                                        dataString: nil,
                                        dataDate: nil,
                                        dataGeo: nil,
                                        dataDriverLicense: nil
                                    )
                                ]
                            ),
                            OsagoProlongationFieldGroup(
                                title: "title title title title title",
                                fields: [
                                    OsagoProlongationField(
                                        id: UUID().uuidString,
                                        title: "Серия и номер ВУ",
                                        value: "77 01397000",
                                        hasError: false,
                                        dataType: .driverLicense,
                                        dataString: nil,
                                        dataDate: nil,
                                        dataGeo: nil,
                                        dataDriverLicense: SeriesAndNumberDocument(
                                            series: "77",
                                            number: "01397000"
                                        )
                                    ),
                                    OsagoProlongationField(
                                        id: UUID().uuidString,
                                        title: "Дата выдачи ВУ",
                                        value: "5 августа 1992",
                                        hasError: false,
                                        dataType: .date,
                                        dataString: nil,
                                        dataDate: Date(),
                                        dataGeo: nil,
                                        dataDriverLicense: nil
                                    ),
                                    OsagoProlongationField(
                                        id: UUID().uuidString,
                                        title: "Адрес прописки",
                                        value: "Комарова 25а, 14",
                                        hasError: false,
                                        dataType: .geo,
                                        dataString: nil,
                                        dataDate: nil,
                                        dataGeo: GeoPlace(
                                            title: "GeoPlace Title",
                                            description: "GeoPlace description",
                                            fullTitle: "GeoPlace fullTitle",
                                            country: "GeoPlace country",
                                            region: "Тульская обл.",
                                            district: "GeoPlace district",
                                            city: "г. Тула",
                                            street: "Комарова",
                                            house: "25а",
                                            apartment: "14",
											fiasId: nil,
											fiasLevel: nil,
											coordinate: nil
                                        ),
                                        dataDriverLicense: nil
                                    ),
                                    OsagoProlongationField(
                                        id: UUID().uuidString,
                                        title: "String data",
                                        value: "String value",
                                        hasError: false,
                                        dataType: .string,
                                        dataString: "String value",
                                        dataDate: nil,
                                        dataGeo: nil,
                                        dataDriverLicense: nil
                                    )
                                ]
                            )
                        ]
                    ),
                    hasError: false,
                    errorText: nil
                )
            ]
        )
    }()

    private var info: OsagoProlongation.OsagoProlongationInfo {
        switch state {
            case .unsupported:
                return .unsupported

            case .inProcessed:
                return .inProcessed

            case .success:
                return .success(info: calculateInfo)

            case .failure:
                return .failure(errorInfo: errorInfo)

            case .error:
                return .error(errorInfo: errorInfo, editInfo: editInfo)
        }
    }
}
