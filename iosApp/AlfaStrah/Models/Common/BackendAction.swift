//
//  BackendAction.swift
//  AlfaStrah
//
//  Created by vit on 02.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct BackendAction: Entity {
    // sourcery: transformer.name = "action_title"
    let title: String
    
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum InternalActionType: String {
        // sourcery: enumTransformer.value = "insurance"
        case isurance = "insurance"
        // sourcery: enumTransformer.value = "dms_appointment_offline_mw"
        case offlineAppointment = "dms_appointment_offline_mw"
        // sourcery: enumTransformer.value = "dms_appointment_online"
        case onlineAppointment = "dms_appointment_online"
        // sourcery: enumTransformer.value = "url",  transformer = "UrlTransformer<Any>()"
        case url = "url"
        // sourcery: enumTransformer.value = "telemed"
        case telemed = "telemed"
        // sourcery: enumTransformer.value = "event_report_osago"
        case osagoReport = "event_report_osago"
        // sourcery: enumTransformer.value = "event_report_kasko"
        case kaskoReport = "event_report_kasko"
        // sourcery: enumTransformer.value = "loyalty"
        case loyalty = "loyalty"
        // sourcery: enumTransformer.value = "property_prolongation"
        case propetryProlonagation = "property_prolongation"
        // sourcery: enumTransformer.value = "clinic_appointment"
        case clinicAppointment = "clinic_appointment"
        // sourcery: enumTransformer.value = "doctor_call"
        case doctorCall = "doctor_call"
    }
    // sourcery: transformer.name = "action_type"
    let internalType: InternalActionType
    
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum UrlOpenMethod: String {
        // sourcery: enumTransformer.value = "webview"
        case webview = "webview"
        // sourcery: enumTransformer.value = "external"
        case external = "external"
    }
    
    // sourcery: transformer.name = "action_info"
    let additionalParameters: [String: Any]?
    
    enum ActionType {
        case insurance(id: String)
        case offlineAppointment(insuranceId: String, appointmentId: Int)
        case onlineAppointment(insuranceId: String, doctorVisitId: Int)
        case path(url: URL, urlShareable: URL?, openMethod: UrlOpenMethod)
        case telemedicine(insuranceId: String)
        case osagoReport(insuranceId: String, reportId: Int)
        case kaskoReport(insuranceId: String, reportId: Int)
        case loyalty
        case propertyProlongation(insuranceId: String)
        case clinicAppointment(insuranceId: String)
        case doctorCall(insuranceId: String, data: BackendDoctorCall)
    }
        
    var type: ActionType? {
        struct ParameterKey {
            static let insuranceId = "insurance_id"
            static let appointmentId = "appointment_id"
            static let doctorVisitId = "doctor_visit_id"
            static let urlPath = "url"
            static let urlShareable = "url_shareable"
            static let urlOpenMethod = "type"
            static let reportId = "event_report_id"
            static let doctorCall = "doctor_call_data"
        }
        
        if internalType == .loyalty {
            return .loyalty
        }
        
        guard let parameters = additionalParameters
        else { return nil }
        
        switch internalType {
            case .isurance:
                guard let insuranceId = parameters[ParameterKey.insuranceId] as? Int
                else { return nil }
                
                return .insurance(id: String(insuranceId))
                
            case .offlineAppointment:
                guard let insuranceId = parameters[ParameterKey.insuranceId] as? Int,
                      let appointmentId = parameters[ParameterKey.appointmentId] as? Int
                else { return nil }
                
                return .offlineAppointment(insuranceId: String(insuranceId), appointmentId: appointmentId)
                
            case .onlineAppointment:
                guard let insuranceId = parameters[ParameterKey.insuranceId] as? Int,
                      let doctorVisitId = parameters[ParameterKey.doctorVisitId] as? Int
                else { return nil }
                
                return .onlineAppointment(insuranceId: String(insuranceId), doctorVisitId: doctorVisitId)
                
            case .url:
                guard let path = parameters[ParameterKey.urlPath] as? String,
                      let url = URL(string: path),
                      let openMethodString = parameters[ParameterKey.urlOpenMethod] as? String,
                      let urlOpenMethod = UrlOpenMethod(rawValue: openMethodString)
                else { return nil }
            
                let urlShareable: URL?
            
                if let pathShareable = parameters[ParameterKey.urlShareable] as? String {
                    urlShareable = URL(string: pathShareable)
                }
                else {
                    urlShareable = nil
                }
            
                return .path(
                    url: url,
                    urlShareable: urlShareable,
                    openMethod: urlOpenMethod
                )
                
            case .telemed:
                guard let insuranceId = parameters[ParameterKey.insuranceId] as? Int
                else { return nil }
                
                return .telemedicine(insuranceId: String(insuranceId))
                
            case .osagoReport:
                guard let insuranceId = parameters[ParameterKey.insuranceId] as? Int,
                      let reportId = parameters[ParameterKey.reportId] as? Int
                else { return nil }
                return .osagoReport(insuranceId: String(insuranceId), reportId: reportId)
            case .kaskoReport:
                guard let insuranceId = parameters[ParameterKey.insuranceId] as? Int,
                      let reportId = parameters[ParameterKey.reportId] as? Int
                else { return nil }
                
                return .kaskoReport(insuranceId: String(insuranceId), reportId: reportId)
                
            case .loyalty:
                return .loyalty
                
            case .propetryProlonagation:
                guard let insuranceId = parameters[ParameterKey.insuranceId] as? Int
                else { return nil }
                return .propertyProlongation(insuranceId: String(insuranceId))
                
            case .clinicAppointment:
                guard let insuranceId = parameters[ParameterKey.insuranceId] as? Int
                else { return nil }
                
                return .clinicAppointment(insuranceId: String(insuranceId))
            case .doctorCall:
                guard let insuranceId = parameters[ParameterKey.insuranceId] as? Int,
                      let doctorCallDataDcitionary = parameters[ParameterKey.doctorCall] as? [String: Any],
                      let doctorCallData = BackendDoctorCallTransformer().transform(source: doctorCallDataDcitionary).value
                else { return nil }
                
                return .doctorCall(
                    insuranceId: String(insuranceId),
                    data: doctorCallData
                )
        }
    }
}
