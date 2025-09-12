//
//  DoctorHomeRequestFlowActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class DoctorHomeRequestFlowActionDTO: ActionDTO {
		let doctorCall: DoctorCallBDUI?
		
		required init(body: [String: Any]) {
			self.doctorCall = DoctorCallBDUITransformer().transform(source: body).value
			
			super.init(body: body)
		}
	}
}
