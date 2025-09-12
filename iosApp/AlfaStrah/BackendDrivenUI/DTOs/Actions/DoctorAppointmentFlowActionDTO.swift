//
//  DoctorAppointmentFlowActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class DoctorAppointmentFlowActionDTO: ActionDTO {
		enum Key: String {
			case insuranceId = "insuranceId"
			case appointmentId = "appointmentId"
			case source = "source"
		}
		
		let insuranceId: String?
		let appointmentId: String?
		let clinicType: ClinicType?
		
		required init(body: [String: Any]) {
			if let insuranceId = body[Key.insuranceId] as? Int {
				self.insuranceId = String(insuranceId)
			} else {
				self.insuranceId = nil
			}
			
			if let appointmentId = body[Key.appointmentId] as? Int {
				self.appointmentId = String(appointmentId)
			} else {
				self.appointmentId = nil
			}
			
			if let source = body[Key.source] as? String,
			   let clinicType = ClinicType(rawValue: source) {
				self.clinicType = clinicType
			} else {
				self.clinicType = nil
			}
			
			super.init(body: body)
		}
	}
	
	enum ClinicType: String {
		case online = "ONLINE"
		case avis = "AVIS"
	}
}
