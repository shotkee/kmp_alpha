//
//  DoctorAppointmentsFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class DoctorAppointmentsFlowActionHandler: ActionHandler<DoctorAppointmentsFlowActionDTO> {
		required init(
			block: DoctorAppointmentsFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let insuranceId = block.insuranceId
				else {
					syncCompletion()
					return
				}
				
				self.showDoctorApointments(for: insuranceId, from: from)
				
				syncCompletion()
			}
		}
		
		private func showDoctorApointments(for insuranceId: String, from: ViewController) {
			let flow = InsurancesFlow()
			ApplicationFlow.shared.container.resolve(flow)
			flow.fromViewController = from
			flow.showDoctorAppointments(for: insuranceId, from: from)
		}
	}
}
