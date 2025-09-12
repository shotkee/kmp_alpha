//
//  AttachmentFileType
//  AlfaStrah
//
//  Created by Eugene Ivanov on 30/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

enum AttachmentPhotoType: Int {
    case documents = 0 // Справка об участии в ДТП (обязательно)
    case photoAccidentGeneral = 1 // Обзорная съемка (до 5 фото)
    case photoCarGeneral = 2 // Фото ТС общего плана,  по оси движения ТС
    case photoCarDamage = 3 // Фото ТС фотографии поврежденных элементов
    case photoCarVin = 4 // Фото ТС фото VIN
    case registrationCertificate = 5 // Свидетельство о регистрации ТС, ПТС
    case passport = 6 // Паспорт
    case drivingLicense = 7 // Водительское удостоверение
    case drivingDirective = 8 // Доверенность
    case rentalContract = 9 // Договор аренды/лизинга
    case administrativeLetter = 10 // Распорядительное письмо от банка
    case tripTicket = 11 // Путевой лист
    case investigationProtocol = 12 // Протокол о возбуждении админ.расследования
    case medicalAct = 13 // Акт медицинского освидетельствования
    case judgement = 14 // Постановление по делу/либо отказ
    case photoAccidentOrienting = 15 // Ориентирующая съёмка (до 3 фото)
    case photoAccidentCorner = 16 // Угловая съёмка места ДТП
    case photoAccidentDetailed = 17 // Детальная съёмка
    case photoCarGeneral45 = 18 // общего плана,  под углом 45 градусов с расстояния 2,5-3 м
    case photoCarDashboard = 19 // Фото ТС фото панели приборов с включенной индикацией приборов и текущего пробега
    case accidentNotificationFace = 20 // Извещение о ДТП (лицевая сторона)
    case accidentNotificationSuffered = 21 // Извещение о ДТП (оборотная сторона Потерпевшего)
    case accidentNotificationCauser = 22 // Извещение о ДТП (оборотная сторона Виновника)
}
