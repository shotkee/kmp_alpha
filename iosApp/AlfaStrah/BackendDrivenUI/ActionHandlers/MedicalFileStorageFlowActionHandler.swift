//
//  MedicalFileStorageFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class MedicalFileStorageFlowActionHandler: ActionHandler<MedicalFileStorageFlowActionDTO> {
		required init(
			block: MedicalFileStorageFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				
				self.showMedicalCard(from: from)
				syncCompletion()
			}
		}
		
		private func showMedicalCard(
			from: UIViewController
		) {
			let medicalCardFlow = MedicalCardFlow(rootController: from)
			ApplicationFlow.shared.container.resolve(medicalCardFlow)
			medicalCardFlow.start()
		}
	}
}
