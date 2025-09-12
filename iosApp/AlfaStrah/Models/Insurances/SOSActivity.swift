//
//  SOSActivity.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 14/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

// sourcery: transformer
struct SosActivityModel: Entity {
    // sourcery: transformer.name = "id"
    var kind: SOSActivityKind
    var title: String
    var description: String
    // sourcery: transformer.name = "sos_phone_list"
    var sosPhoneList: [SosPhone]
    // sourcery: transformer.name = "insurance_id_list"
    var insuranceIdList: [String]

    var isActive: Bool {
        switch kind {
            case .call:
                return !sosPhoneList.isEmpty
            case
                .callback,
                .voipCall,
                .autoInsuranceEvent,
                .doctorAppointment,
                .passengersInsuranceEvent,
                .passengersInsuranceWebEvent,
                .onlinePayment,
                .accidentInsuranceEvent,
                .vzrInsuranceEvent,
                .interactiveSupport,
                .onWebsite,
				.life,
                .unsupported:
                return !insuranceIdList.isEmpty
        }
    }

    var isSupported: Bool {
        kind != .unsupported
    }
}

// sourcery: transformer
struct SosPhone: Entity {
    var title: String
    var description: String
    var phone: String
    // sourcery: transformer.name = "internet_call"
    var voipCall: VoipCall?
}

// sourcery: enumTransformer
enum SOSActivityKind: Int {
    // sourcery: defaultCase
    case unsupported = 0
    case call = 1
    case callback = 2
    case autoInsuranceEvent = 3
    case doctorAppointment = 4
    case voipCall = 5
    case passengersInsuranceEvent = 6
    case onlinePayment = 8
    case vzrInsuranceEvent = 9
    case accidentInsuranceEvent = 10
    case passengersInsuranceWebEvent = 11
	case life = 12
    case interactiveSupport = 13
    case onWebsite = 14
    
    var hasEventsList: Bool {
        switch self {
            case
                .autoInsuranceEvent,
                .doctorAppointment,
                .passengersInsuranceEvent,
                .accidentInsuranceEvent:
                return true
            case
                .call,
                .callback,
                .voipCall,
                .onlinePayment,
                .vzrInsuranceEvent,
                .passengersInsuranceWebEvent,
                .interactiveSupport,
                .onWebsite,
				.life,
                .unsupported:
                return false
        }
    }
}

// sourcery: enumTransformer
enum SOSActivity: Int {
    // sourcery: defaultCase
    case unsupported = 0
    // Звонок
    case call = 1
    // Заказать обратный звонок
    case callback = 2
    // Зарегистрировать страховой случай
    case reportInsuranceEvent = 3
    // Запись к врачу
    case doctorAppointment = 4
    // Инструкция
    case instruction = 5
    // VoIP звонок
    case voipCall = 6
    // Бесплатный звонок
    case freeCall = 7
    // Оформить страховой случай ОСАГО
    case reportOSAGOInsuranceEvent = 8
    // Купить снова
    case buyAgain = 9
    // Купить новый
    case buyNew = 10
    // Оформить страховой случай Пассажиры
    case reportPassengersInsuranceEvent = 11
    // Оформить страховой случай ВЗР
    case reportVzrInsuranceEvent = 12
    // Оформить страховой случай НС
    case reportAccidentInsuranceEvent = 13
    // Оформить страховой случай Пассажиры через сайт
    case reportPassengersInsuranceWebEvent = 14
	// АльфаСтрахование-Жизнь, Вопросы и ответы
	case life = 15
	
    case interactiveSupport = 16
    
    // Оформить cтраховой случай на сайте
    case reportOnWebsite = 17
    
    /* These activities will never come from server */
    case information = 100
    case receivePaymentOnline = 101
}
