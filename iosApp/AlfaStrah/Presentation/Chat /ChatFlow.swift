//
// ChatFlow
// AlfaStrah
//
// Created by Eugene Egorov on 07 December 2018.
// Copyright (c) 2018 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class ChatFlow: DependencyContainerDependency,
				AttachmentServiceDependency,
				ChatServiceDependency,
				InsurancesServiceDependency,
				AnalyticsServiceDependency,
				AlertPresenterDependency,
				AccountServiceDependency,
				LoggerDependency,
				MedicalCardServiceDependency {
    var container: DependencyInjectionContainer?
    var alertPresenter: AlertPresenter!
    var chatService: ChatService!
	var attachmentService: AttachmentService!
	var medicalCardService: MedicalCardService!
	var insurancesService: InsurancesService!
	var accountService: AccountService!
	var analytics: AnalyticsService!
    var logger: TaggedLogger?
    let initialViewController: UINavigationController

    private let disposeBag: DisposeBag = DisposeBag()
    		
	private var filePickerFileEntries: [FilePickerFileEntry] = []
	
	private var attachmentsUpdatedSubscriptions: Subscriptions<Void> = Subscriptions()

    deinit {
        logger?.debug("")
    }

    init() {
        let navigationController = RMRNavigationController()
        navigationController.strongDelegate = RMRNavigationControllerDelegate()
        initialViewController = navigationController
    }
	
	func setupInitalController() {
		initialViewController.setViewControllers([ createChatViewController() ], animated: false)
	}

    func start() {
		setupInitalController()
        initialViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabbar_chat_title", comment: ""),
            image: .Icons.chat,
            selectedImage: nil
        )
    }
    
    enum ViewControllerPresentingMode {
        case fullscreen
        case sheet
    }

    func show(from viewController: ViewController, mode: ViewControllerPresentingMode) {
        let chatViewController = createChatViewController()
        
        let closeButton = ActionBarButtonItem(
            image: UIImage(named: "icon-close"),
            style: .plain,
            target: nil,
            action: nil
        )
        
        closeButton.actionClosure = { [weak chatViewController] in
            guard let chatViewController = chatViewController
            else { return }

            chatViewController.dismiss(animated: true)
        }
        chatViewController.navigationItem.leftBarButtonItem = closeButton

        initialViewController.setViewControllers([ chatViewController ], animated: false)
        
        switch mode {
            case .fullscreen:
                viewController.present(initialViewController, animated: true)
            case .sheet:
                viewController.present(initialViewController, animated: true, with: .formSheet)
        }
    }
    
    private func createChatViewController() -> ChatViewController {
        let chatViewController = ChatViewController()
        container?.resolve(chatViewController)
        
		chatViewController.input = .init(
			didAppear: {
				if let analyticsData = analyticsData(from: self.insurancesService.cachedShortInsurances(forced: true), for: .health) {
					self.analytics.track(
						event: AnalyticsEvent.App.openChat,
						properties: ["authorized": self.accountService.isAuthorized],
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
				}
			}
		)
		
        chatViewController.output = .init(
            getLastOperatorRating: {
                self.chatService.getLastRatingOperatorWith(id: self.chatService.currentOperator?.getID())
            },
            showRateOperator: { [weak chatViewController] score in
                guard let chatViewController
                else { return }
                
				self.showRateOperator(with: score, from: chatViewController)
            },
			attachFile: { [weak chatViewController] in
				guard let chatViewController
				else { return }
				
				self.showFileSourceSelectionBottomSheet(from: chatViewController)
			}
        )

        // weak chatViewController is important because it is cause of a memory leak
        chatService.subscribeForServiceStateUpdates { [weak chatViewController] chatServiceState in
            chatViewController?.notify.updateState(chatServiceState)
        }.disposed(by: chatViewController.disposeBag)
        
        chatService.subscribeForOperatorIsTypingUpdates { [weak chatViewController] isTyping in
            chatViewController?.notify.setTypingIndicatorVisible(isTyping)
        }.disposed(by: chatViewController.disposeBag)
        
        chatService.subscribeChatMessagesChanged { [weak chatViewController] in
            chatViewController?.notify.messagesChanged()
        }.disposed(by: chatViewController.disposeBag)
		
		chatService.subscribeChatOperatorScore{ [weak chatViewController] in
			chatViewController?.notify.operatorScoreChanged()
		}.disposed(by: chatViewController.disposeBag)
		
		chatService.subscribeChatOperatorScoreResult{ [weak chatViewController] result in
			chatViewController?.notify.showScoreOperationResult(result)
		}.disposed(by: chatViewController.disposeBag)
		                
        return chatViewController
    }
		
	private func showFileSourceSelectionBottomSheet(from: UIViewController) {
		guard chatService.serviceState == ChatServiceState.chatting(.chatting)
		else { return }
				
		let viewController = FileSourceSelectionBottomViewController()
		
		viewController.input = .init(
			title: NSLocalizedString("upload_photo_or_file", comment: ""),
			description:
				"\(NSLocalizedString("size_should_not_exceed", comment: "")) \(NSLocalizedString("chat_files_source_size_limit", comment: ""))"
		)
		
		viewController.output = .init(
			completion: { [weak viewController] selectedSource in
				viewController?.dismiss(animated: true) {
					switch selectedSource {
						case .camera:
							Permissions.camera { [weak from] granted in
								guard granted, let from
								else { return }
								
								self.showFilePicker(from: from, for: .camera)
							}
							
						case .gallery:
							if #available(iOS 14.0, *) {
								Permissions.photoLibrary(for: .readWrite) { [weak from] granted in
									guard granted, let from
									else { return }
									
									self.showFilePicker(from: from, for: .gallery)
								}
							} else {
								self.showFilePicker(from: from, for: .gallery)
							}
							
						case .documents, .medicalCard:
							self.showFilePicker(from: from, for: selectedSource
						)
					}
				}
			}
		)
		
		from.showBottomSheet(contentViewController: viewController)
	}
	
	private func showFilePicker(from: UIViewController, for selectedSource: FilePickerSource) {
		if let picker = FilePicker.shared.pick(
			from: selectedSource,
			filesSelected: { [weak from] entries in
				guard let from
				else { return }
				
				self.handleSelectedFiles(entries, from: from)
			},
			dismissCompletion: { [weak from] in
				guard let from
				else { return }
						
				self.showDocumentsBottomSheet(from: from)
			},
			on: from
		) {
			from.present(picker, animated: true)
		}
	}
	
	private func showDocumentsBottomSheet(from: UIViewController) {
		guard chatService.serviceState == .chatting(.chatting)
		else { return }
		
		openFilesUploadInputBottomViewController(from: from, completion: { _ in })
	}
		
	private func handleSelectedFiles(_ entries: [FilePickerFileEntry], from: UIViewController) {
		let currentEntriesCount = self.filePickerFileEntries.count
		let maxSelectedEntriesCount = 10
		
		guard currentEntriesCount < maxSelectedEntriesCount
		else { return }
		
		let entriesCountToAppend = maxSelectedEntriesCount - currentEntriesCount - 1
				
		if entries.count - 1 > entriesCountToAppend {
			let entriesToAppend = entries[0...entriesCountToAppend]
			filePickerFileEntries.append(contentsOf: entriesToAppend)
		} else {
			filePickerFileEntries.append(contentsOf: entries)
		}
	}
		
	private func openFilesUploadInputBottomViewController(
		from: UIViewController,
		completion: @escaping ([Attachment]) -> Void
	) {
		let viewController: ChatAttachmentsInputBottomViewController = .init()
		container?.resolve(viewController)
				
		viewController.input = .init(
			title: NSLocalizedString("common_pick_documents", comment: ""),
			description: NSLocalizedString("common_documents_sub_title_count", comment: ""),
			doneButtonTitle: NSLocalizedString("common_send", comment: ""),
			fileEntries: { return self.filePickerFileEntries }
		)
		
		viewController.output = .init(
			close: { [weak viewController] in
				viewController?.dismiss(animated: true)
			},
			done: { [weak viewController] in
				guard let viewController
				else { return }
				
				for fileEntry in self.filePickerFileEntries {
					guard let attachment = fileEntry.attachment
					else { continue }
					
					switch fileEntry.state {
						case .ready:
							self.chatService.send(attachment: attachment) { result in
								switch result {
									case .success:
										if let index = self.filePickerFileEntries.firstIndex(where: {
											$0.attachment?.id == attachment.id
										}) {
											if let attachment = self.filePickerFileEntries[index].attachment,
											   FileManager.default.fileExistsAtURL(attachment.url) {
													try? FileManager.default.removeItem(at: attachment.url)
											}
											
											self.filePickerFileEntries.remove(at: index)
										}
										
									case .failure(let error):
										self.logger?.error(error.localizedDescription)
										ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
										
								}
							}
						case .processing, .error:
							break
					}
				}
				
				viewController.dismiss(animated: true) {}
			},
			delete: { fileEntries in
				let ids = fileEntries.compactMap { $0.attachment?.id }
				self.filePickerFileEntries.removeAll { ids.contains($0.attachment?.id ?? "") }
				
				self.attachmentsUpdatedSubscriptions.fire(())
			},
			pickFile: { [weak viewController] in
				viewController?.dismiss(animated: true) { [weak from] in
					guard let from
					else { return }
					
					self.showFileSourceSelectionBottomSheet(from: from)
				}
			},
			showPhoto: { showPhotoController, animated, completion in
				viewController.present(
					showPhotoController,
					animated: animated,
					completion: completion
				)
			},
			openDocument: { [weak viewController] attachment in
				guard let viewController
				else { return }
				
				LocalDocumentViewer.open(
					attachment.url,
					from: viewController,
					uti: attachment.url.uti ?? "com.adobe.pdf"
				)
			}
		)
		
		attachmentsUpdatedSubscriptions
			.add(viewController.notify.filesUpdated)
			.disposed(by: viewController.disposeBag)
		
		from.showBottomSheet(contentViewController: viewController)
	}
	
	private func showRateOperator(with score: Int?, from: ChatViewController) {
        guard let currentOperator = chatService.currentOperator
        else { return }

        let controller = RateOperatorViewController()
        container?.resolve(controller)
		
        controller.input = .init(
			operatorInfo: currentOperator,
			newScore: score
		)
		
        controller.output = .init(
            confirm: { [unowned controller] rating, comment in
                self.chatService.rateOperatorWith(
                    requestId: currentOperator.getID(),
                    comment: comment,
                    byRating: rating,
					senderId: currentOperator.getSenderId(),
                    completionHandler: controller
                )
            },
            completion: { [weak from] result in
                guard let from = from
                else { return }

                switch result {
                    case .success:
						from.dismiss(animated: true) {
							from.notify.showScoreOperationResult(true)
						}
                    case .failure(let error):
						from.dismiss(animated: true) {
							from.notify.showScoreOperationResult(false)
						}
                }
            }
        )
        
        controller.addCloseButton { [unowned from] in
            from.dismiss(animated: true)
        }
        
        let navigationController = RMRNavigationController(rootViewController: controller)
        navigationController.strongDelegate = RMRNavigationControllerDelegate()
        navigationController.modalPresentationStyle = .fullScreen
        
        from.present(navigationController, animated: true)
    }
}
