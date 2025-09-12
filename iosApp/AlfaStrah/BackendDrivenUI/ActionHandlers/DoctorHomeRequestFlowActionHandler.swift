//
//  DoctorHomeRequestFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class DoctorHomeRequestFlowActionHandler: ActionHandler<DoctorHomeRequestFlowActionDTO> {
		required init(
			block: DoctorHomeRequestFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let doctorCall = block.doctorCall
				else {
					syncCompletion()
					return
				}
				
				let interactiveSupportFLow = InteractiveSupportFlow(rootController: from)
				ApplicationFlow.shared.container.resolve(interactiveSupportFLow)
				
				interactiveSupportFLow.showDoctorCallQuestionnaireBDUI(doctorCall: doctorCall)
					
				syncCompletion()
			}
		}
	}
}
