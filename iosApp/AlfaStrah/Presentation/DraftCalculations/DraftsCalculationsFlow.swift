//
//  DraftsCalculationsFlow.swift
//  AlfaStrah
//
//  Created by mac on 17.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

class DraftsCalculationsFlow: BaseFlow, DraftsCalculationsServiceDependency, AccountServiceDependency {
    var draftsCalculationsService: DraftsCalculationsService!
	var accountService: AccountService!

    func start() {
        let viewController = DraftsCalculationsViewController()
        container?.resolve(viewController)
		viewController.input = .init(
			appear: { [weak viewController] in
				viewController?.notify.update(.loading)
			},
            draftCategories: { [weak self] completion in
                guard let self
                else { return }
				
				guard !self.accountService.isDemo
				else {
					viewController.notify.update(.demo)
					return
				}
				
                self.draftsCalculationsService.getDraftCategories { result in
                    completion?()

                    switch result {
                        case .success(let draftCategoriesWithInfo):
							viewController.notify.update(.data(draftCategoriesWithInfo))
                        case .failure(let error):
							viewController.notify.update(.failure)
                    }
                }
            }
        )
		viewController.output = .init(
            buyInsurance: { [weak viewController] in
                guard let viewController
                else { return }
				viewController.presentingViewController?.dismiss(animated: true) {
					ApplicationFlow.shared.show(item: .buyInsurance)
                }
            },
            toChat: { [weak viewController] in
                guard let viewController
                else { return }

                let chatFlow = ChatFlow()
                self.container?.resolve(chatFlow)
                chatFlow.show(from: viewController, mode: .fullscreen)
            },
			openDraft: { [weak viewController] url in
				guard let viewController,
					  let url
				else { return }
				
				WebViewer.openDocument(
					url,
					showShareButton: false,
					from: viewController
				)
			},
			deleteDrafts: { [weak viewController] drafts in
				guard let viewController
				else { return }
				
				self.draftsToDelete = []
				self.draftsToDelete.append(contentsOf: drafts)
				
				self.showRemoveDraftsAlert(from: viewController) { [weak viewController] in
					viewController?.notify.update(.loading)
					
					self.draftsCalculationsService.getDraftCategories { [weak viewController] result in
						switch result {
							case .success(let draftCategoriesWithInfo):
								viewController?.notify.update(.data(draftCategoriesWithInfo))
							case .failure:
								viewController?.notify.update(.failure)
						}
					}
				}
			}
        )

		viewController.addCloseButton { [weak viewController] in
			viewController?.presentingViewController?.dismiss(animated: true)
        }

        createAndShowNavigationController(viewController: viewController, mode: .modal)
    }
	
	private var draftsToDelete: [DraftsCalculationsData] = []
	
	private func showRemoveDraftsAlert(
		from viewController: UIViewController,
		completion: @escaping () -> Void
	) {
		let localized = NSLocalizedString(
			"deleted_drafts_count",
			comment: ""
		)
		
		let rootString = String(
			format: localized,
			locale: .init(identifier: "ru"),
			self.draftsToDelete.count
		)
		
		let isMultipleDraftsToDelete = self.draftsToDelete.count > 1
		
		let alert = UIAlertController(
			title: isMultipleDraftsToDelete
				? NSLocalizedString("draft_delete_alert_title", comment: "")
				: NSLocalizedString("draft_single_delete_alert_title", comment: ""),
			message: isMultipleDraftsToDelete ? rootString : "",
			preferredStyle: .alert
		)
		
		let removeAction = UIAlertAction(
			title: NSLocalizedString("common_delete", comment: ""),
			style: .default
		) { [weak viewController] _ in
			guard let viewController = viewController
			else { return }
			
			self.deleteDrafts(on: viewController, completion: completion)
		}
		
		let cancelAction = UIAlertAction(
			title: NSLocalizedString("common_cancel_button", comment: ""),
			style: .cancel
		)
		
		alert.addAction(removeAction)
		alert.addAction(cancelAction)

		viewController.present(alert, animated: true)
	}
	
	private func deleteDrafts(on viewController: UIViewController, completion: @escaping () -> Void) {
		let hide = viewController.showLoadingIndicator(
			message: NSLocalizedString("draft_delete_loader_description", comment: "")
		)
		
		let dispatchGroup = DispatchGroup()
		var lastError: AlfastrahError?
		
		let drafts = self.draftsToDelete
		
		var successfullyDeletedDrafts: [DraftsCalculationsData] = []
		
		for draft in drafts {
			dispatchGroup.enter()
			self.draftsCalculationsService.deleteDraft(by: draft.id) { result in
				dispatchGroup.leave()
				switch result {
					case .success:
						successfullyDeletedDrafts.append(draft)
						
					case .failure(let error):
						lastError = error
						
				}
			}
		}
		
		dispatchGroup.notify(queue: .main) { [weak viewController] in
			hide(nil)
			
			for draft in successfullyDeletedDrafts {
				if let indexToDelete = self.draftsToDelete.firstIndex(where: { $0.id == draft.id }) {
					self.draftsToDelete.remove(at: indexToDelete)
				}
			}
			
			guard let viewController
			else { return }
			
			if lastError != nil {
				self.showRemoveDraftFailureAlert(from: viewController, completion: completion)
			} else {
				completion()
			}
		}
	}
	
	private func showRemoveDraftFailureAlert(
		from viewController: UIViewController,
		completion: @escaping () -> Void
	) {
		let alert = UIAlertController(
			title: NSLocalizedString("draft_delete_retry_alert_title", comment: ""),
			message: NSLocalizedString("draft_delete_retry_alert_description", comment: ""),
			preferredStyle: .alert
		)

		let retryAction = UIAlertAction(
			title: NSLocalizedString("common_retry", comment: ""),
			style: .default
		) { [weak viewController] _ in
			guard let viewController = viewController
			else { return }
			
			if self.draftsToDelete.isEmpty {
				completion()
			} else {
				self.deleteDrafts(on: viewController, completion: completion)
			}
		}

		let cancelAction = UIAlertAction(
			title: NSLocalizedString("common_cancel_button", comment: ""),
			style: .cancel
		)

		alert.addAction(retryAction)
		alert.addAction(cancelAction)

		viewController.present(alert, animated: true)
	}
}
