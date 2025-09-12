//
// PhotoModelsPresets
// AlfaStrah
//
// Created by Eugene Egorov on 15 January 2019.
// Copyright (c) 2019 Redmadrobot. All rights reserved.
//

// swiftlint:disable line_length file_length

class PhotoModelsPresets {
    var noAuthorities: [PhotoGroup] {
        common + noAuthoritiesDocuments
    }

    var authorities: [PhotoGroup] {
        common + authoritiesDocuments
    }

    let test: [PhotoGroup] = [
        PhotoGroup(
            title: "Место происшествия",
            hint: "Если вы не на месте ДТП,\nсделайте снимки места вокруг",
            type: .place,
            icon: "ico-insp-photo-place",
            minPhotos: 0,
            isPhotoLibraryAllowed: true,
            steps: [
                AutoPhotoStep(
                    title: "Что произошло",
                    order: 0,
                    attachmentType: .photoAccidentGeneral,
                    stepId: 1,
                    icon: "ico-kasko-incedent",
                    minPhotos: 1,
                    maxPhotos: 5,
                    hint: "Сделайте фото места ДТП с 4-х ракурсов. Выбирайте точку съемки так, чтобы на снимке была видна общая картина столкновения автомобилей.\n\n Если вы не на месте ДТП, сделайте фото машины с 4-х ракурсов, чтобы на снимке была видна общая картина места вокруг.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Где произошло ДТП",
                    order: 1,
                    attachmentType: .photoAccidentOrienting,
                    stepId: 15,
                    icon: "ico-kasko-location",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Важно показать расположение места происшествия относительно дорог, мостов, улиц, перекрестков, дорожных знаков, разметки, а также включить в кадр находящиеся вблизи постоянные ориентиры: дома, магазины и др.\n\n Если вы не на месте ДТП, сделайте снимки места вокруг.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Место удара",
                    order: 2,
                    attachmentType: .photoAccidentCorner,
                    stepId: 16,
                    icon: "ico-kasko-place",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Зафиксируйте место удара автомобилей с разных ракурсов.\n\n Если вы не на месте ДТП, сделайте фотографии места удара на вашем автомобиле.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Детальная съемка",
                    order: 3,
                    attachmentType: .photoAccidentDetailed,
                    stepId: 17,
                    icon: "ico-kasko-detali",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Снимите максимально крупно место удара и отлетевшие детали, если они имеются.",
                    photos: []
                ),
            ]
        )
    ]

    private let common: [PhotoGroup] = [
        PhotoGroup(
            title: "Место происшествия",
            hint: "Если вы не на месте ДТП,\nсделайте снимки места вокруг",
            type: .place,
            icon: "ico-insp-photo-place",
            minPhotos: 0,
            isPhotoLibraryAllowed: true,
            steps: [
                AutoPhotoStep(
                    title: "Что произошло",
                    order: 0,
                    attachmentType: .photoAccidentGeneral,
                    stepId: 1,
                    icon: "ico-kasko-incedent",
                    minPhotos: 1,
                    maxPhotos: 5,
                    hint: "Сделайте фото места ДТП с 4-х ракурсов. Выбирайте точку съемки так, чтобы на снимке была видна общая картина столкновения автомобилей.\n\n Если вы не на месте ДТП, сделайте фото машины с 4-х ракурсов, чтобы на снимке была видна общая картина места вокруг.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Где произошло ДТП",
                    order: 1,
                    attachmentType: .photoAccidentOrienting,
                    stepId: 15,
                    icon: "ico-kasko-location",
                    minPhotos: 1,
                    maxPhotos: 5,
                    hint: "Важно показать расположение места происшествия относительно дорог, мостов, улиц, перекрестков, дорожных знаков, разметки, а также включить в кадр находящиеся вблизи постоянные ориентиры: дома, магазины и др.\n\n Если вы не на месте ДТП, сделайте снимки места вокруг.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Место удара",
                    order: 2,
                    attachmentType: .photoAccidentCorner,
                    stepId: 16,
                    icon: "ico-kasko-place",
                    minPhotos: 1,
                    maxPhotos: 5,
                    hint: "Зафиксируйте место удара автомобилей с разных ракурсов.\n\n Если вы не на месте ДТП, сделайте фотографии места удара на вашем автомобиле.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Детальная съемка",
                    order: 3,
                    attachmentType: .photoAccidentDetailed,
                    stepId: 17,
                    icon: "ico-kasko-detali",
                    minPhotos: 1,
                    maxPhotos: 5,
                    hint: "Снимите максимально крупно место удара и отлетевшие детали, если они имеются.",
                    photos: []
                ),
            ]
        ),
        PhotoGroup(
            title: "Общий план ТС",
            hint: nil,
            type: .plan,
            icon: "ico-insp-photo-place",
            minPhotos: 1,
            isPhotoLibraryAllowed: false,
            steps: [
                AutoPhotoStep(
                    title: "Спереди",
                    order: 0,
                    attachmentType: .photoCarGeneral,
                    stepId: 2002,
                    icon: "vehicle_front",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Сделайте фото своего автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Спереди слева",
                    order: 1,
                    attachmentType: .photoCarGeneral45,
                    stepId: 1801,
                    icon: "vehicle_front_left",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Сделайте фото своего автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Сзади слева",
                    order: 2,
                    attachmentType: .photoCarGeneral45,
                    stepId: 1804,
                    icon: "vehicle_back_left",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Сделайте фото своего автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Сзади",
                    order: 3,
                    attachmentType: .photoCarGeneral,
                    stepId: 2001,
                    icon: "vehicle_back",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Сделайте фото своего автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Сзади справа",
                    order: 4,
                    attachmentType: .photoCarGeneral45,
                    stepId: 1803,
                    icon: "vehicle_back_right",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Сделайте фото своего автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Спереди справа",
                    order: 5,
                    attachmentType: .photoCarGeneral45,
                    stepId: 1802,
                    icon: "vehicle_front_right",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Сделайте фото своего автомобиля.",
                    photos: []
                ),
            ]
        ),
        PhotoGroup(
            title: "Поврежденные участки",
            hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля",
            type: .damage,
            icon: "ico-insp-photo-place",
            minPhotos: 1,
            isPhotoLibraryAllowed: false,
            steps: [
                AutoPhotoStep(
                    title: "Бампер передний",
                    order: 0,
                    attachmentType: .photoCarDamage,
                    stepId: 3,
                    icon: "",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Бампер задний",
                    order: 1,
                    attachmentType: .photoCarDamage,
                    stepId: 3001,
                    icon: "",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Крыло переднее левое",
                    order: 2,
                    attachmentType: .photoCarDamage,
                    stepId: 3002,
                    icon: "",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Крыло переднее правое",
                    order: 3,
                    attachmentType: .photoCarDamage,
                    stepId: 3003,
                    icon: "",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Крыло заднее левое",
                    order: 4,
                    attachmentType: .photoCarDamage,
                    stepId: 3004,
                    icon: "",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Крыло заднее правое",
                    order: 5,
                    attachmentType: .photoCarDamage,
                    stepId: 3005,
                    icon: "",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Дверь передняя левая",
                    order: 6,
                    attachmentType: .photoCarDamage,
                    stepId: 3006,
                    icon: "",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Дверь передняя правая",
                    order: 7,
                    attachmentType: .photoCarDamage,
                    stepId: 3007,
                    icon: "",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Дверь задняя левая",
                    order: 8,
                    attachmentType: .photoCarDamage,
                    stepId: 3008,
                    icon: "",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Дверь задняя правая",
                    order: 9,
                    attachmentType: .photoCarDamage,
                    stepId: 3009,
                    icon: "",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Капот",
                    order: 10,
                    attachmentType: .photoCarDamage,
                    stepId: 3010,
                    icon: "",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Крыша",
                    order: 11,
                    attachmentType: .photoCarDamage,
                    stepId: 3011,
                    icon: "",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Порог левый",
                    order: 12,
                    attachmentType: .photoCarDamage,
                    stepId: 3012,
                    icon: "",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Порог правый",
                    order: 13,
                    attachmentType: .photoCarDamage,
                    stepId: 3013,
                    icon: "",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Крышка багажника",
                    order: 14,
                    attachmentType: .photoCarDamage,
                    stepId: 3014,
                    icon: "",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Лобовое стекло",
                    order: 15,
                    attachmentType: .photoCarDamage,
                    stepId: 3015,
                    icon: "",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Заднее стекло",
                    order: 16,
                    attachmentType: .photoCarDamage,
                    stepId: 3016,
                    icon: "",
                    minPhotos: 0,
                    maxPhotos: 5,
                    hint: "Для оформления страхового случая вам необходимо сделать фото поврежденных участков автомобиля.",
                    photos: []
                ),
            ]
        ),
        PhotoGroup(
            title: "VIN и приборная панель",
            hint: nil,
            type: .vin,
            icon: "ico-insp-photo-place",
            minPhotos: 0,
            isPhotoLibraryAllowed: false,
            steps: [
                AutoPhotoStep(
                    title: "VIN код",
                    order: 0,
                    attachmentType: .photoCarVin,
                    stepId: 4,
                    icon: "ico_vin",
                    minPhotos: 1,
                    maxPhotos: 5,
                    hint: "Чаще всего VIN код можно найти в нижнем углу лобового стекла со стороны водителя. Также он может располагаться: под капотом, на стойке водительской двери и под обшивкой пола водительского сиденья.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Приборная панель",
                    order: 1,
                    attachmentType: .photoCarDashboard,
                    stepId: 19,
                    icon: "ico-kasko-pribor",
                    minPhotos: 1,
                    maxPhotos: 5,
                    hint: "Сделайте фото панели приборов с включенной индикацией приборов и текущим пробегом.",
                    photos: []
                ),
            ]
        ),
    ]

    private let noAuthoritiesDocuments: [PhotoGroup] = [
        PhotoGroup(
            title: "Документы",
            hint: nil,
            type: .docs,
            icon: "ico-sie-doc",
            minPhotos: 0,
            isPhotoLibraryAllowed: false,
            steps: [
                AutoPhotoStep(
                    title: "Свидетельство о регистрации ТС",
                    order: 0,
                    attachmentType: .registrationCertificate,
                    stepId: 5,
                    icon: "ico-kasko-documents",
                    minPhotos: 1,
                    maxPhotos: 5,
                    hint: "Сделайте фото документа с 2-х сторон.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Водительское удостоверение",
                    order: 1,
                    attachmentType: .drivingLicense,
                    stepId: 7,
                    icon: "ico-kasko-documents",
                    minPhotos: 1,
                    maxPhotos: 5,
                    hint: "Сделайте фото документа с 2-х сторон.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Извещение о ДТП (лицевая сторона)",
                    order: 2,
                    attachmentType: .accidentNotificationFace,
                    stepId: 20,
                    icon: "ico-kasko-documents",
                    minPhotos: 1,
                    maxPhotos: 5,
                    hint: "Сделайте фото документа с 2-х сторон.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Извещение о ДТП (обратная сторона Потерпевшего)",
                    order: 3,
                    attachmentType: .accidentNotificationSuffered,
                    stepId: 21,
                    icon: "ico-kasko-documents",
                    minPhotos: 1,
                    maxPhotos: 5,
                    hint: "Сделайте фото документа с 2-х сторон.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Извещение о ДТП (обратная сторона Виновника)",
                    order: 4,
                    attachmentType: .accidentNotificationCauser,
                    stepId: 22,
                    icon: "ico-kasko-documents",
                    minPhotos: 0,
                    maxPhotos: 2,
                    hint: "Сделайте фото документа с 2-х сторон.",
                    photos: []
                ),
            ]
        )
    ]

    private let authoritiesDocuments: [PhotoGroup] = [
        PhotoGroup(
            title: "Документы",
            hint: nil,
            type: .docs,
            icon: "ico-sie-doc",
            minPhotos: 0,
            isPhotoLibraryAllowed: false,
            steps: [
                AutoPhotoStep(
                    title: "Свидетельство о регистрации ТС",
                    order: 0,
                    attachmentType: .registrationCertificate,
                    stepId: 5,
                    icon: "ico-kasko-documents",
                    minPhotos: 1,
                    maxPhotos: 5,
                    hint: "Сделайте фото документа с 2-х сторон.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Водительское удостоверение",
                    order: 1,
                    attachmentType: .drivingLicense,
                    stepId: 7,
                    icon: "ico-kasko-documents",
                    minPhotos: 1,
                    maxPhotos: 5,
                    hint: "Сделайте фото документа с 2-х сторон.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Документы компетентных органов",
                    order: 2,
                    attachmentType: .documents,
                    stepId: 0,
                    icon: "ico-kasko-documents",
                    minPhotos: 1,
                    maxPhotos: 10,
                    hint: "Сделайте фото всех документов (максимум 10 фото).",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Извещение о ДТП (лицевая сторона)",
                    order: 3,
                    attachmentType: .accidentNotificationFace,
                    stepId: 20,
                    icon: "ico-kasko-documents",
                    minPhotos: 0,
                    maxPhotos: 2,
                    hint: "Сделайте фото документа с 2-х сторон.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Извещение о ДТП (обратная сторона Потерпевшего)",
                    order: 4,
                    attachmentType: .accidentNotificationSuffered,
                    stepId: 21,
                    icon: "ico-kasko-documents",
                    minPhotos: 0,
                    maxPhotos: 2,
                    hint: "Сделайте фото документа с 2-х сторон.",
                    photos: []
                ),
                AutoPhotoStep(
                    title: "Извещение о ДТП (обратная сторона Виновника)",
                    order: 5,
                    attachmentType: .accidentNotificationCauser,
                    stepId: 22,
                    icon: "ico-kasko-documents",
                    minPhotos: 0,
                    maxPhotos: 2,
                    hint: "Сделайте фото документа с 2-х сторон.",
                    photos: []
                ),
            ]
        )
    ]
}

// swiftlint:enable line_length file_length
