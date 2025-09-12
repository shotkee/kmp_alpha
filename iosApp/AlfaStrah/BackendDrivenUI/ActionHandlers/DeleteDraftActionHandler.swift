//
//  DeleteDraftActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class DeleteDraftActionHandler: ActionHandler<DeleteDraftActionDTO>,
									AlertPresenterDependency,
									DraftsCalculationsServiceDependency {
		var alertPresenter: AlertPresenter!
		var draftsCalculationsService: DraftsCalculationsService!
		
		required init(
			block: DeleteDraftActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let draftId = block.id
				else {
					syncCompletion()
					return
				}
				
				self.deleteDraft(with: draftId, on: from) {}
					
				syncCompletion()
			}
		}
		
		private func deleteDraft(with id: Int, on viewController: UIViewController, completion: @escaping () -> Void) {
			let hide = viewController.showLoadingIndicator(
				message: NSLocalizedString("draft_delete_loader_description", comment: "")
			)
			
			self.draftsCalculationsService.deleteDraft(by: id) { result in
				hide(nil)
				switch result {
					case .success:
						completion()
						
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
						
				}
			}
		}
	}
}
