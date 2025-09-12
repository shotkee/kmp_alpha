//
// AppNotification
// AlfaStrah
//
// Created by Eugene Egorov on 20 November 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

// sourcery: transformer
struct AppNotification: Entity, Equatable {
    // sourcery: enumTransformer
    enum Kind: Int {
        // sourcery: defaultCase
        case unsupported = 0
        /// Используемые поля:
        /// - Название title
        /// - Краткий текст annotation
        /// - Длинный текст full_text
        case message = 1

        /// Используемые поля:
        /// - Название title
        /// - Набор полей ключ+значение field_list
        case fieldList = 2

        /// Используемые поля:
        /// - Название title
        /// - Набор полей ключ+значение field_list
        /// - appointment
        /// - Телефон для справок phone
        /// - Дата обращения user_request_date
        case offlineAppointment = 3

        /// Используемые поля:
        /// - Название title
        /// - Набор полей ключ+значение field_list
        /// - stoa
        /// - Телефон для справок phone
        /// - Полис insurance
        /// - Номер страхового случая event_number
        case stoa = 4

        /// Запрос на дозагрузку фотографий в СС Каско
        /// Название title
        /// Набор полей ключ+значение field_list
        /// Идентификатор event_report_id
        /// Массив photo_types
        case kaskoLoadMorePhoto = 5

        /// Ответ на запрос продления полиса [ОСАГО].
        /// Название title
        /// Набор полей ключ+значение field_list
        case osagoRenew = 6

        /// Полис имущество скоро закончится, вероятно пользователь хочет его продлить
        /// Название title
        /// Краткий текст annotation
        /// Описание full_text
        case realtyRenew = 7

        /// Используемые поля:
        /// - Название title
        /// - Краткий текст annotation
        /// - Длинный текст full_text
        /// - Визит на прием doctor_visit_id
        case onlineAppointment = 8

        /// Используемые поля:
        /// - Название title
        /// - Краткий текст annotation
        /// - Длинный текст full_text
        /// - Визит на прием insurance_id
        case telemedicineСonclusion = 9

        /// Используемые поля:
        /// - Название title
        /// - Краткий текст annotation
        /// - Длинный текст full_text
        /// - Визит на прием insurance_id
        case telemedicineSoon = 10

        /// Используемые поля:
        /// - Название title
        /// - Краткий текст annotation
        /// - Длинный текст full_text
        /// - Визит на прием insurance_id
        case telemedicineNewMessage = 11

        /// Используемые поля:
        /// - Название title
        /// - Краткий текст annotation
        /// - Длинный текст full_text
        /// - Визит на прием insurance_id
        case telemedicineCall = 12

        /// Используемые поля:
        /// - Название title
        /// - Длинный текст full_text
        /// - Опционально ссылка url
        /// - Опционально экран target
        case newsNotification = 13
    }

    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    var type: AppNotification.Kind

    var title: String

    var annotation: String

    // sourcery: transformer.name = "full_text"
    var fullText: String

    // sourcery: transformer = "TimestampTransformer<Any>(scale: 1)"
    var date: Date

    var important: Bool

    // sourcery: transformer.name = "insurance_id"
    var insuranceId: String

    var stoa: Stoa?

    // sourcery: transformer = IdTransformer<Any>(), transformer.name = "appointment_id"
    var offlineAppointmentId: String?

    // sourcery: transformer.name = "field_list"
    var fieldList: [AppNotificationField]?

    var phone: Phone?

    // sourcery: transformer.name = "user_request_date", transformer = "TimestampTransformer<Any>(scale: 1)"
    var userRequestDate: Date?

    // sourcery: transformer.name = "event_number"
    var eventNumber: String?

    // sourcery: transformer = IdTransformer<Any>(), transformer.name = "doctor_visit_id"
    var onlineAppointmentId: String?

    // sourcery: transformer.name = "is_read"
    var isRead: Bool

    var url: String?

    var target: DeeplinkDestination

    static func == (lhs: AppNotification, rhs: AppNotification) -> Bool {
        lhs.id == rhs.id
    }
}
