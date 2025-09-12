//
//  InstructionFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class InstructionFlowActionHandler: ActionHandler<InstructionFlowActionDTO>,
										AlertPresenterDependency,
										InsurancesServiceDependency {
		var alertPresenter: AlertPresenter!
		var insurancesService: InsurancesService!
		
		required init(
			block: InstructionFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let categoryId = block.categoryId
				else {
					syncCompletion()
					return
				}
				
				let hide = from.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
				
				self.insurancesService.insurances(useCache: true) { [weak from] result in
					hide(nil)
					
					guard let from
					else {
						syncCompletion()
						return
					}
					
					switch result {
						case .success(let response):
							let instructions = response.sosList.flatMap {
								$0.instructionList.filter { $0.insuranceCategoryId == categoryId }
							}
							self.showInstructionsList(instructions: instructions, fromVC: from)
							
						case .failure(let error):
							ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
							
					}
					
					syncCompletion()
				}
			}
		}
		
		private func showInstructionsList(instructions: [Instruction], fromVC: ViewController) {
			let storyboard = UIStoryboard(name: "Instruction", bundle: nil)
			let viewController: InstructionListViewController = storyboard.instantiate()

			viewController.input = .init(
				instructions: instructions
			)
			viewController.output = .init(
				details: { [weak viewController] instruction in
					guard let viewController = viewController else { return }

					self.showInstructionDetails(instruction: instruction, fromVC: viewController)
				}
			)
			fromVC.navigationController?.pushViewController(viewController, animated: true)
		}
		
		private func showInstructionDetails(instruction: Instruction, fromVC: ViewController) {
			let storyboard: UIStoryboard = UIStoryboard(name: "Instruction", bundle: nil)
			let viewController: InstructionViewController = storyboard.instantiate()
			viewController.input = .init(
				instruction: instruction
			)
			fromVC.navigationController?.pushViewController(viewController, animated: true)
		}
	}
}
