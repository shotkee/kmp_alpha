//
//  InsurancesFlow
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 05/12/2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy
import PassKit
import WebKit

// swiftlint:disable file_length
class InsurancesFlow: BDUI.ActionHandlerFlow,
					  AttachmentServiceDependency,
					  FlatOnOffServiceDependency,
					  KaskoExtensionServiceDependency,
					  MarksWebServiceDependency,
					  InsuranceLifeServiceDependency,
					  InteractiveSupportServiceDependency,
					  PassbookServiceDependency,
					  VzrOnOffServiceDependency {
	var attachmentService: AttachmentService!
	var flatOnOffService: FlatOnOffService!
	var kaskoExtensionService: KaskoExtensionService!
	var marksWebService: MarksWebService!
	var insuranceAlfaLifeService: InsuranceLifeService!
	var interactiveSupportService: InteractiveSupportService!
	var passbookService: PassbookService!
	var vzrOnOffService: VzrOnOffService!
	
	weak var fromViewController: UIViewController?
	weak var navigationController: UINavigationController?
	
	var onlineClinicAppointmentFlow: CommonClinicAppointmentFlow?
	
	deinit {
		logger?.debug("")
	}
	
	private let storyboard = UIStoryboard(name: "Insurances", bundle: nil)
	
    func showInsurance(
		id: String,
		from: ViewController,
		isModal: Bool = false,
		kind: Insurance.Kind? = nil
	) {
        logger?.debug("")

        fromViewController = from
		
		switch kind {
			case .dms:
				showInsuranceWithInsuranceRender(id: id, from: from, isModal: isModal)
				
			case .accident, .flatOnOff, .kasko, .life, .osago, .passengers, .property, .vzr, .unknown, .vzrOnOff, .none:
				showInsuranceById(id, from: from, isModal: isModal)
				
		}
    }
	
	func showInsurance(
		_ insurance: InsuranceShort,
		from: ViewController,
		isModal: Bool = false
	) {
		logger?.debug("")

		fromViewController = from
				
		switch insurance.type {
			case .dms:
				showInsuranceWithInsuranceRender(id: insurance.id, from: from, isModal: isModal)
			case
				.kasko,
				.osago,
				.vzr,
				.property,
				.passengers,
				.life,
				.accident,
				.kaskoOnOff,
				.vzrOnOff,
				.flatOnOff:
				let hide = from.showLoadingIndicator(
					message: NSLocalizedString("common_load", comment: "")
				)
		
				insurancesService.insurance(useCache: true, id: insurance.id) { result in
					hide(nil)
					switch result {
						case .success(let insurance):
							self.showInsuranceById(insurance.id, from: from, isModal: isModal)
						case .failure(let error):
							ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
					}
				}
				
			case .unsupported:
				break
		}
	}
	
	// MARK: - DEPRECATED. For dms only.
	private func showInsuranceWithInsuranceRender(
		id: String,
		from: ViewController,
		isModal: Bool = false
	) {
		let hide = fromViewController?.showLoadingIndicator(
			message: NSLocalizedString("common_load", comment: "")
		)
		
		insurancesService.insurances(useCache: true) { result in
			switch result {
				case .success(let response):
					let insurance = response.insuranceGroupList
						.flatMap { $0.insuranceGroupCategoryList }
						.flatMap { $0.insuranceList }
						.filter { $0.id == id }.first
					
					guard let render = insurance?.render,
						  let renderUrl = render.url
					else {
						hide?(nil)
						
						// try to show old flow if bdui return nil render
						self.showInsuranceById(id, from: from, isModal: isModal)
						
						return
					}

					BDUI.ViewControllerUtils.showBackendDrivenViewController(
						from: from,
						for: renderUrl,
						with: Dictionary(
							uniqueKeysWithValues: render.headers.map { ($0.name, $0.value) }
						),
						use: self.backendDrivenService,
						use: self.analytics,
						backendActionSelectorHandler: { events, viewController in
							guard let viewController
							else { return }
							
							self.handleBackendEvents(
								events,
								on: viewController,
								with: nil,
								isModal: isModal,
								syncCompletion: nil
							)
						},
						syncCompletion: nil
					) {
						hide?(nil)
					}
				case .failure(let error):
					hide?(nil)
					ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
			}
		}
	}
	
	private func showInsuranceById(
		_ id: String,
		from: ViewController,
		isModal: Bool = false
	) {
		let hide = from.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""), clearBackground: true)
		
		category(forInsuranceId: id, useCache: false) { result in
			hide(nil)
			switch result {
				case .success((let insurance, let category)):
					guard let category = category else {
						self.alertPresenter.show(
							alert: ErrorNotificationAlert(
								error: nil,
								text: NSLocalizedString("common_missing_category", comment: "")
							)
						)
						return
					}
					if isModal {
						self.showModalInsurance(insurance, category: category)
					} else {
						self.showInsurance(insurance, category: category)
					}
				case .failure(let error):
					from.processError(error)
			}
		}
	}
	
	private func getInsurance(
		insuranceId: String,
		completion: @escaping (Insurance) -> Void
	) {
		guard let controller = self.fromViewController
		else { return }
			
		let hide = controller.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
		insurancesService.insurance(useCache: true, id: insuranceId) { result in
			hide(nil)
			switch result {
				case .success(let insurance):
					completion(insurance)
				case .failure(let error):
					ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
			}
		}
	}
	
	private func showInteractiveSupport(insurance: InsuranceShort, from: ViewController, completion: @escaping () -> Void) {
		interactiveSupportService.onboarding(insuranceIds: [insurance.id]) { result in
			completion()
			switch result {
				case .success(let data):
					guard let onboardingDataForInsurance = data.first(where: { String($0.insuranceId) == insurance.id })
					else { return }
					
					let interactiveSupportFlow = InteractiveSupportFlow(rootController: from)
					self.container?.resolve(interactiveSupportFlow)
							
					interactiveSupportFlow.start(
						for: insurance,
						with: onboardingDataForInsurance,
						flowStartScreenPresentationType: .fullScreen
					)
				case .failure(let error):
					ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
			}
		}
	}
	
	private func openChatFullscreen(from: ViewController) {
		let chatFlow = ChatFlow()
		container?.resolve(chatFlow)
		chatFlow.show(from: from, mode: .fullscreen)
	}
	
	private func showCallNumberActionSheet(
		phone: BDUI.PhoneComponentDTO,
		viewController: ViewController
	) {
		
		guard let humanReadable = phone.humanReadable,
			  let plain = phone.plain
		else { return }
		
		let actionSheet = UIAlertController(
			title: humanReadable,
			message: nil,
			preferredStyle: .actionSheet
		)
		
		if phone.canMakeCall ?? false == true {
			let callNumberAction = UIAlertAction(
				title: NSLocalizedString("common_call", comment: ""),
				style: .default
			) { _ in
				
				guard let url = URL(string: "telprompt://" + plain)
				else { return }
				
				UIApplication.shared.open(url, completionHandler: nil)
			}
			actionSheet.addAction(callNumberAction)
		}
		
		if phone.canCopyValue ?? false == true {
			let copyNumberAction = UIAlertAction(
				title: NSLocalizedString("common_copy", comment: ""),
				style: .default,
				handler: { _ in
					UIPasteboard.general.string = plain
				}
			)
			
			actionSheet.addAction(copyNumberAction)
		}
		
		let cancel = UIAlertAction(
			title: NSLocalizedString(
				"common_cancel_button",
				comment: ""
			),
			style: .cancel,
			handler: nil
		)

		actionSheet.addAction(cancel)
		
		viewController.present(
			actionSheet,
			animated: true
		)
	}
	
    func showVzrOnOffInsurance(from: ViewController) {
        logger?.debug("")

        fromViewController = from
        let hide = from.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
        vzrOnOffService.insurances { result in
            switch result {
                case .success(let insurances):
                    guard let insurance = insurances.first else {
                        return hide(nil)
                    }

                    self.category(forInsuranceId: insurance.insuranceId, useCache: true) { result in
                        hide(nil)
                        switch result {
                            case.success((let insurance, let category)):
                                guard let categoty = category else {
                                    self.alertPresenter.show(
                                        alert: ErrorNotificationAlert(
                                            error: nil,
                                            text: NSLocalizedString("common_missing_category", comment: "")
                                        )
                                    )
                                    return
                                }

                                self.showModalInsurance(insurance, category: categoty)
                            case .failure(let error):
                                from.processError(error)
                        }
                    }
                case .failure(let error):
                    hide(nil)
                    from.processError(error)
            }
        }
    }

    func showInsuranceBills(insurance: Insurance, from: ViewController) {
        let insuranceBillsFlow = InsuranceBillsFlow(rootController: from)
        self.container?.resolve(insuranceBillsFlow)
        insuranceBillsFlow.showBills(insurance: insurance, from: from)
    }

    func showGuaranteeLetters(insurance: Insurance, from: ViewController) {
        let guaranteeLettersFlow = GuaranteeLettersFlow(rootController: from)
        self.container?.resolve(guaranteeLettersFlow)
        guaranteeLettersFlow.showGuaranteeLetters(insurance: insurance, from: from)
    }

    func showRenew(
        insuranceId: String,
        renewalType: InsuranceShort.RenewType?,
        from: ViewController,
        showMode: ViewControllerShowMode = .modal)
    {
        logger?.debug("")

        fromViewController = from
        let hide = from.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
        category(forInsuranceId: insuranceId, useCache: true) { result in
            hide(nil)
            switch result {
                case .success(let (insurance, _)):
                    switch insurance.type {
                        case .kasko:
                            self.renewKasko(
                                insurance,
                                renewalType: renewalType,
                                from: from
                            )
                        case .osago:
                            self.renewOsago(insurance.id, from: from, showMode: showMode)
                        case .dms, .passengers, .unknown, .vzr, .life, .accident, .vzrOnOff, .flatOnOff:
                            self.renewOrdinary(insurance.id, from: from)
                        case .property:
                            if insurance.renewablePropertySubtype != nil {
                                self.renewRemontNeighbours(insurance, from: from)
                            } else {
                                self.renewOrdinary(insurance.id, from: from)
                            }
                    }
                case .failure(let error):
                    hide(nil)
                    from.processError(error)
            }
        }
    }

    func searchInsuranceModal(from: UIViewController) {
        let viewController = searchInsuranceViewController()
        viewController.addCloseButton { [weak viewController] in
            viewController?.dismiss(animated: true, completion: nil)
        }
        let navigationController = RMRNavigationController(rootViewController: viewController)
        navigationController.strongDelegate = RMRNavigationControllerDelegate()
        from.present(navigationController, animated: true, completion: nil)
        fromViewController = navigationController
    }

    private func searchInsurance() {
        fromViewController?.navigationController?.pushViewController(searchInsuranceViewController(), animated: true)
    }

    func showArchiveInsurancesList(from: UIViewController) {
        fromViewController = from
        archiveInsurancesList(owner: .me)
    }

    func selectInsurance(
        ids: [String],
		sosActivity: SosActivityModel? = nil,
        requestOnboardingData: Bool = false,
        from: ViewController,
        showMode: ViewControllerShowMode,
        completion: @escaping (_ insurance: InsuranceShort, _ onboardingData: [InteractiveSupportData]?, _ controller: ViewController) -> Void
    ) {
        logger?.debug("")

        fromViewController = from
        
        let viewController = SelectInsuranceViewController()
        container?.resolve(viewController)
        
        viewController.input = .init(
            data: { useCache, completion in
                self.insuranceItems(
                    by: ids,
					sosActivity: sosActivity,
                    useCache: useCache,
                    withOnboardingData: requestOnboardingData,
                    completion: completion
                )
            }
        )
        
        viewController.output = .init(
            selectByInsuranceId: { [weak viewController] insuranceId in
                guard let viewController
                else { return }
                
                self.insurancesService.insurances(useCache: true) { result in
                    switch result {
                        case .success(let response):
                            let insurances = response.insuranceGroupList
                                .flatMap { $0.insuranceGroupCategoryList }
                                .flatMap { $0.insuranceList }
                                .filter { ids.contains($0.id) }
                            
                            if let insurance = insurances.first(where: {
                                $0.id == insuranceId
                            }) {
                                completion(insurance, self.onboardingData, viewController)
                            }
                            
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                }
            }
        )
        
        switch showMode {
            case .push:
                fromViewController?.navigationController?.pushViewController(viewController, animated: true)
                
            case .modal:
                viewController.addCloseButton {
                    self.fromViewController?.dismiss(animated: true)
                }
                
                let navigationController = RMRNavigationController(rootViewController: viewController)
                navigationController.strongDelegate = RMRNavigationControllerDelegate()
                self.navigationController = navigationController
                fromViewController?.present(navigationController, animated: true)
                
        }
    }
    
    private var onboardingData: [InteractiveSupportData]?
    
    private func insuranceItems(
        by ids: [String],
		sosActivity: SosActivityModel? = nil,
        useCache: Bool = true,
        withOnboardingData: Bool = false,
        completion: @escaping (Result<[SelectInsuranceViewController.Item], AlfastrahError>) -> Void
    ) {
        if withOnboardingData {
            let dispatchGroup = DispatchGroup()
            var lastError: AlfastrahError?
            var insuranceMain: InsuranceMain?

            if self.onboardingData == nil {
                dispatchGroup.enter()
                interactiveSupportService.onboarding(insuranceIds: ids) { [weak self] result in
                    dispatchGroup.leave()
                    guard let self
                    else { return }
                    
                    switch result {
                        case .success(let data):
                            self.onboardingData = data
                        case .failure(let error):
                            lastError = error
                    }
                }
            }
            
            dispatchGroup.enter()
            insurancesService.insurances(useCache: useCache) { [weak self] result in
                dispatchGroup.leave()
                guard let self
                else { return }

                switch result {
                    case .success(let data):
                        insuranceMain = data
                    case .failure(let error):
                        lastError = error
                }
            }

            dispatchGroup.notify(queue: .main) {
                if let error = lastError {
                    completion(.failure(error))
                } else {
                    let insurances = insuranceMain?.insuranceGroupList
                        .flatMap { $0.insuranceGroupCategoryList }
                        .flatMap { $0.insuranceList }
                        .filter { ids.contains($0.id) } ?? []

                    var items: [SelectInsuranceViewController.Item] = []

                    for insurance in insurances {
                        let onboardingDataForInsuranceId = self.onboardingData?.first(where: { String($0.insuranceId) == insurance.id })

                        items.append(
                            SelectInsuranceViewController.Item(
                                insuranceId: insurance.id,
                                title: insurance.title,
                                subtitle: insurance.description ?? "",
                                description: onboardingDataForInsuranceId?.insurer ?? ""
                            )
                        )
                    }

                    completion(.success(items))
                }
            }
        } else {
            insurancesService.insurances(useCache: useCache) { result in
                switch result {
                    case .success(let response):
                        let insurances = response.insuranceGroupList
                            .flatMap { $0.insuranceGroupCategoryList }
                            .flatMap { $0.insuranceList }
                            .filter { ids.contains($0.id) }

                        let items = insurances.map {
							if sosActivity?.kind == .life || sosActivity?.kind == .onlinePayment {
								return SelectInsuranceViewController.Item(
									insuranceId: $0.id,
									title: $0.title,
									subtitle: NSLocalizedString("select_insurance_expiration_until", comment: "") +
										AppLocale.shortDateString($0.endDate),
									description: $0.description ?? ""
								)
							}
							
							return SelectInsuranceViewController.Item(
								insuranceId: $0.id,
								title: $0.title,
								subtitle: $0.description ?? "",
								description: ""
							)
                        }

                        completion(.success(items))

                    case .failure(let error):
                    
                        completion(.failure(error))
                }
            }
        }
    }

    func eventInsurance(
        from: ViewController,
		sosActivity: SosActivityModel? = nil,
        showMode: ViewControllerShowMode,
        ids: [String]
    ) {
        if ids.count > 1 {
            selectInsurance(ids: ids, sosActivity: sosActivity, from: from, showMode: showMode) { insuranceShort, _, controller in
                let hide = from.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
                self.insurancesService.insurance(useCache: true, id: insuranceShort.id) { result in
                    hide(nil)
                    switch result {
                        case .success(let insurance):
                            let insuranceEventFlow = InsuranceEventFlow(insurance: insurance, rootController: controller)
                            self.container?.resolve(insuranceEventFlow)

                            insuranceEventFlow.createInsuranceEvent(
								insurance: insurance,
								sosActivity: sosActivity,
								from: controller,
								showMode: .push
							)
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                }
            }
        } else if let id = ids.first {
            if let insurance = self.insurancesService.cachedInsurance(id: id) {
                self.showCreateEvent(insurance: insurance, sosActivity: sosActivity, controller: from, showMode: showMode)
            } else {
                let hide = from.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
                self.insurancesService.insurance(useCache: true, id: id) { result in
                    hide(nil)
                    switch result {
                        case .success(let insurance):
                            self.showCreateEvent(insurance: insurance, sosActivity: sosActivity, controller: from, showMode: showMode)
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                }
            }
		} else if sosActivity?.kind == .onlinePayment {
			WebViewer.openDocument(
				url: { completion in
					self.insuranceAlfaLifeService.accidentUrl(insuranceId: "", completion: completion)
				},
				openMode: .push,
				showShareButton: true,
				needSharedUrl: true,
				from: from
			)
		}
    }

    private func archiveInsurancesList(owner: InsuranceOwnerKind) {
        let viewController = archiveInsurancesListViewController(owner: owner)
        fromViewController?.navigationController?.pushViewController(viewController, animated: true)
    }

    func archiveInsurancesListModal(from: UIViewController) {
        let viewController = archiveInsurancesListViewController(owner: .me)
        viewController.addCloseButton { [weak viewController] in
            viewController?.dismiss(animated: true, completion: nil)
        }
        let navigationController = RMRNavigationController(rootViewController: viewController)
        navigationController.strongDelegate = RMRNavigationControllerDelegate()
        from.present(navigationController, animated: true, completion: nil)
        fromViewController = viewController
    }

	// swiftlint:disable:next function_body_length
    private func archiveInsurancesListViewController(owner: InsuranceOwnerKind) -> ArchiveInsurancesListViewController {
        let viewController: ArchiveInsurancesListViewController = storyboard.instantiate()
        container?.resolve(viewController)
		
        viewController.input = ArchiveInsurancesListViewController.Input(
            data: { completion in
                self.groupedInsurances(owner: owner, archive: true, useCache: false, completion: completion)
            },
            timeLeftString: InsuranceHelper.timeLeftString
        )
		
        viewController.output = ArchiveInsurancesListViewController.Output(
			select: { [weak viewController] insurance, category in
				guard let viewController
				else { return }
				
				switch insurance.type {
					case .dms:
						guard let render = insurance.render,
							  let renderUrl = render.url
						else {
							// try to show old flow if bdui return nil render
							self.showInsurance(insurance, category: category)
							
							return
						}
						
						let hide = viewController.showLoadingIndicator(
							message: NSLocalizedString("common_load", comment: "")
						)
						
						BDUI.ViewControllerUtils.showBackendDrivenViewController(
							from: viewController,
							for: renderUrl,
							with: Dictionary(
								uniqueKeysWithValues: render.headers.map { ($0.name, $0.value) }
							),
							use: self.backendDrivenService,
							use: self.analytics,
							backendActionSelectorHandler: { events, viewController in
								guard let viewController
								else { return }
								
								self.handleBackendEvents(
									events,
									on: viewController,
									with: nil,
									isModal: false,
									syncCompletion: nil
								)
							}, 
							syncCompletion: nil,
							completion: {
								hide(nil)
							}
						)
						
					case .accident, .flatOnOff, .kasko, .life, .osago, .passengers, .property, .vzr, .unknown, .vzrOnOff:
						self.showInsurance(insurance, category: category)
						
						if let analyticsData = analyticsData(
							from: self.insurancesService.cachedShortInsurances(forced: true),
							for: insurance.id
						) {
							self.analytics.track(
								navigationSource: .archives,
								insuranceId: insurance.id,
								isAuthorized: self.accountService.isAuthorized,
								event: AnalyticsEvent.Dms.details,
								userProfileProperties: analyticsData.analyticsUserProfileProperties
							)
						}
				}
			}
        )
		
        return viewController
    }

    private func showModalInsurance(_ insurance: Insurance, category: InsuranceCategory) {
        let navigationController = RMRNavigationController()
        navigationController.strongDelegate = RMRNavigationControllerDelegate()
        self.navigationController = navigationController
        let viewController: InsuranceViewController = insuranceViewController(insurance, category: category)
        viewController.addCloseButton { [weak viewController] in
            viewController?.dismiss(animated: true, completion: nil)
        }
        self.navigationController?.setViewControllers([ viewController ], animated: true)
        fromViewController?.present(navigationController, animated: true, completion: nil)
    }

    private func showInsurance(
		_ insurance: Insurance,
		category: InsuranceCategory,
		hideTabSwitch: Bool = false,
		initialSelectedTab: InsuranceViewController.State = .insuranceInfo,
		navigationTitle: String? = nil
	) {
		let viewController = insuranceViewController(
			insurance,
			category: category,
			hideTabSwitch: hideTabSwitch,
			initialSelectedTab: initialSelectedTab,
			navigationTitle: navigationTitle
		)
		
		if let navigationController {
			navigationController.pushViewController(viewController, animated: true)
			
			return
		}
		
		self.navigationController = fromViewController?.navigationController
		fromViewController?.navigationController?.pushViewController(viewController, animated: true)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    private func insuranceViewController(
		_ insurance: Insurance,
		category: InsuranceCategory,
		hideTabSwitch: Bool = false,
		initialSelectedTab: InsuranceViewController.State = .insuranceInfo,
		navigationTitle: String? = nil
	) -> InsuranceViewController {
        let viewController: InsuranceViewController = storyboard.instantiate()
        container?.resolve(viewController)
        // swiftlint:disable:next trailing_closure
        viewController.input = InsuranceViewController.Input(
            insurance: insurance,
            category: category,
			isDemo: self.accountService.isDemo,
            canAddToPassbook: passbookService.isAvailable,
            eventListController: insuranceEventListController(insurance, from: viewController),
            vzrOnOffDashboard: { completion in
                guard insurance.type == .vzrOnOff else {
                    return completion(.success(nil))
                }

                // swiftlint:disable:next array_init
                self.vzrOnOffService.dashboard(insuranceId: insurance.id) { completion($0.map { $0 }) }
            },
            flatOnOffInsurance: { completion in
                self.getFlatOnOffInsurance(insurance: insurance, completion: completion)
            },
            flatOnOffBalance: flatOnOffService.balance,
			hideTabSwitch: hideTabSwitch,
			initialSelectedTab: initialSelectedTab,
			title: navigationTitle
        )
        viewController.output = InsuranceViewController.Output(
            linkTap: { [weak viewController] url in
                guard let controller = viewController else { return }

                self.linkTap(url, from: controller)
            },
            pdfLinkTap: { [weak viewController] url in
                guard let viewController 
				else { return }
                
                self.pdfLinkTap(url, from: viewController)
            },
            openBills: { [weak viewController] in
                guard let viewController
				else { return }
				
				if let analyticsData = analyticsData(
						from: self.insurancesService.cachedShortInsurances(forced: true),
						for: insurance.id
				) {
					self.analytics.track(
						navigationSource: AnalyticsParam.NavigationSource.dmsDetails,
						insuranceId: insurance.id,
						event: AnalyticsEvent.Dms.bills,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
				}
                
                let hide = viewController.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
                self.insurancesService.insurance(useCache: true, id: insurance.id) { result in
                    hide(nil)
                    switch result {
                        case .success(let insurance):
                            self.showInsuranceBills(insurance: insurance, from: viewController)
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                }
            },
            openGuaranteeLetters: { [weak viewController] in
                guard let viewController
				else { return }

                self.showGuaranteeLetters(insurance: insurance, from: viewController)
				
				if let analyticsData = analyticsData(
					from: self.insurancesService.cachedShortInsurances(forced: true),
					for: insurance.id
				) {
					self.analytics.track(
						navigationSource: AnalyticsParam.NavigationSource.dmsDetails,
						insuranceId: insurance.id,
						event: AnalyticsEvent.Dms.guaranteeLetters,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
				}
            },
            phoneTap: self.phoneTap,
            renewInsurance: { [weak viewController] in
                guard let controller = viewController else { return }

                self.showRenew(
                    insuranceId: insurance.id,
                    renewalType: nil,
                    from: controller,
                    showMode: .push
                )
            },
            buyNewInsurance: { [weak viewController] in
                guard let controller = viewController else { return }

                self.buyNewInsurance(insurance, from: controller)
            },
            makeChanges: { [weak viewController] in
                guard let controller = viewController else { return }

                self.makeChangesToInsurance(
                    insurance,
                    from: controller
                )
            },
            osagoTerminate: { [weak viewController] in
                guard let viewController
                else { return }
                
                self.terminateOsago(
                    insurance,
                    from: viewController
                )
            },
            vzrTerminate: { [weak viewController] in
                guard let viewController
                else { return }
                
                let hide = viewController.showLoadingIndicator(message: nil)
                
                self.vzrOnOffService.vzrTerminateUrl(insuranceId: insurance.id) { [weak viewController] result in
                    hide(nil)
                    
                    guard let viewController = viewController
                    else { return }

                    switch result {
                        case .success(let url):
                            WebViewer.openDocument(
                                url,
                                showShareButton: true,
                                from: viewController
                            )
                        case .failure(let error):
                            viewController.processError(error)
                    }
                }
            },
            addToPassbook: { [weak viewController] in
                guard let viewController
				else { return }

                self.addToPassbook(insurance: insurance, from: viewController)
            },
            instructions: { [weak viewController] in
                guard let viewController
				else { return }

                self.getSosListInstructions(viewController: viewController, category: category)
            },
            askQuestion: {
				if self.accountService.isDemo
				{
					DemoBottomSheet.presentInfoDemoSheet(from: viewController)
				}
				else
				{
					ApplicationFlow.shared.show(item: .tabBar(.chat))
				}
            },
            tripIntermediatePoints: { [weak viewController] sourceView in
                guard let controller = viewController, !insurance.tripIntermediatePoints.isEmpty else { return }

                self.showTripPoints(insurance: insurance, sourceView: sourceView, controller: controller)
            },
            createEvent: { [weak viewController] filterName in
                guard let viewController
				else { return }
								
				switch insurance.type {
					case .osago:						
						let hide = viewController.showLoadingIndicator(
							message: NSLocalizedString("common_load", comment: "")
						)
						self.backendDrivenService.eventReportOSAGO(insuranceId: insurance.id){ [weak viewController] result in
							hide(nil)
							
							guard let viewController
							else { return }
							
							switch result {
								case .success(let data):
									if let sreenBackendComponent = BDUI.DataComponentDTO(body: data).screen {
										BDUI.CommonActionHandlers.shared.showFloatingScreen(
											with: sreenBackendComponent,
											from: viewController,
											backendActionSelectorHandler: { events, viewController in
												guard let viewController
												else { return }
												
												self.handleBackendEvents(
													events,
													on: viewController,
													with: sreenBackendComponent.screenId,
													isModal: false,
													syncCompletion: nil
												)
											}
										)
									}

								case .failure(let error):
									ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
							}
						}

					case
							.kasko,
							.dms,
							.vzr,
							.property,
							.passengers,
							.life,
							.accident,
							.vzrOnOff,
							.flatOnOff:
						let sosActivity = self.insurancesService.cachedShortInsurances(forced: true).flatMap {
							$0.insuranceGroupList.flatMap {
								$0.insuranceGroupCategoryList.filter {
									!$0.insuranceList.filter { $0.id == insurance.id }.isEmpty
								}
							}
						}?.first?.sosActivity
						
						
						self.showCreateEvent(
							insurance: insurance,
							sosActivity: sosActivity,
							filterName: filterName,
							controller: viewController,
							showMode: .push
						)
						
						if let analyticsData = analyticsData(
							from: self.insurancesService.cachedShortInsurances(forced: true),
							for: insurance.id
						) {
							switch analyticsData.sosActivityKind {
								case .doctorAppointment:
									self.analytics.track(
										navigationSource: AnalyticsParam.NavigationSource.dmsDetails,
										insuranceId: insurance.id,
										event: AnalyticsEvent.Clinic.appointmentPolicy,
										userProfileProperties: analyticsData.analyticsUserProfileProperties
									)
									
									self.analytics.track(
										navigationSource: AnalyticsParam.NavigationSource.dmsDetails,
										insuranceId: insurance.id,
										event: AnalyticsEvent.Dms.clinics,
										userProfileProperties: analyticsData.analyticsUserProfileProperties
									)
									
								case .interactiveSupport:
									self.analytics.track(
										navigationSource: AnalyticsParam.NavigationSource.dmsDetails,
										insuranceId: insurance.id,
										event: AnalyticsEvent.Clinic.appointmentPolicy,
										userProfileProperties: analyticsData.analyticsUserProfileProperties
									)
									
									self.analytics.track(
										navigationSource: AnalyticsParam.NavigationSource.dmsDetails,
										insuranceId: insurance.id,
										event: AnalyticsEvent.Dms.interactiveSupport,
										userProfileProperties: analyticsData.analyticsUserProfileProperties
									)
									
								case
										.accidentInsuranceEvent,
										.autoInsuranceEvent,
										.call,
										.callback,
										.life,
										.onWebsite,
										.onlinePayment,
										.passengersInsuranceEvent,
										.passengersInsuranceWebEvent,
										.unsupported,
										.voipCall,
										.vzrInsuranceEvent,
										.none:
									break
									
							}
						}
					case .unknown:
						break
				}
			},
			telemedicine: {
				self.showTelemedicineInfo(insurance: insurance)
				
				if let analyticsData = analyticsData(
					from: self.insurancesService.cachedShortInsurances(forced: true),
					for: insurance.id
				) {
					self.analytics.track(
						navigationSource: AnalyticsParam.NavigationSource.dmsDetails,
						insuranceId: insurance.id,
						event: AnalyticsEvent.Dms.telemedicine,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
				}
			},
            callKidsDoctor: {
                if insurance.isYandexEmployeeChild == true, let kidsDoctorPhone = insurance.kidsDoctorPhone {
                    self.phoneTap(kidsDoctorPhone)
                }
            },
            vzrBuyDays: { [weak viewController] in
                guard let controller = viewController else { return }

                self.showVzrOnOff(.buyDays, from: controller, insuranceId: insurance.id)
            },
            vzrStartTrip: { [weak viewController] in
                guard let controller = viewController else { return }

                self.showVzrOnOff(.startTrip, from: controller, insuranceId: insurance.id)
            },
            vzrTripList: { [weak viewController] in
                guard let controller = viewController else { return }

                self.showVzrOnOff(.tripHistory, from: controller, insuranceId: insurance.id)
            },
            vzrPurchaseList: { [weak viewController] in
                guard let controller = viewController else { return }

                self.showVzrOnOff(.purchaseHistory, from: controller, insuranceId: insurance.id)
            },
            vzrOnOffRequestPermissions: vzrOnOffService.requestPermissionsIfNeeded,
            flatOnOffBuyDays: { [unowned viewController] in
                self.showFlatOnOff(mode: .buyDays, from: viewController, insurance: insurance)
            },
            flatOnOffActivate: { [unowned viewController] in
                self.showFlatOnOff(mode: .activate, from: viewController, insurance: insurance)
            },
            flatOnOffOpenActivations: { // [unowned viewController] in
                // [TODO]: Temporarily remove action
                //         self.showFlatOnOff(mode: .activations, from: viewController, insurance: insurance)
            },
            flatOnOffOpenPurchases: { /* [TODO]: Implement */ },
            changeFranchiseProgram: { [weak self, weak viewController] in
                guard let self,
					  let viewController
                else { return }

                self.showFranchiseTransition(insurance: insurance, from: viewController)
				
				if let analyticsData = analyticsData(
					from: self.insurancesService.cachedShortInsurances(forced: true),
					for: insurance.id
				) {
					self.analytics.track(
						navigationSource: AnalyticsParam.NavigationSource.dmsDetails,
						insuranceId: insurance.id,
						event: AnalyticsEvent.Dms.franchise,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
				}
            },
            useVzrBonuses: { [weak self, weak viewController] in
                guard let self,
                      let viewController
                else { return }
                
                let hide = viewController.showLoadingIndicator(message: nil)
                
                self.vzrOnOffService.vzrBonusesUrl(insuranceId: insurance.id) {
                    [weak viewController] result in

                    hide(nil)
                    
                    guard let viewController = viewController
                    else { return }

                    switch result {
                        case .success(let url):
                            WebViewer.openDocument(
                                url,
                                showShareButton: false,
                                from: viewController
                            )
                        case .failure(let error):
                            viewController.processError(error)
                    }
                }
				
				if let analyticsData = analyticsData(
					from: self.insurancesService.cachedShortInsurances(forced: true),
					for: insurance.id
				) {
					self.analytics.track(
						navigationSource: AnalyticsParam.NavigationSource.dmsDetails,
						insuranceId: insurance.id,
						event: AnalyticsEvent.Dms.vzrBonuses,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
				}
            },
            vzrFranchiseCertificate: { [weak self, weak viewController] in
                guard let self = self,
                      let viewController = viewController
                else { return }
                
                let hide = viewController.showLoadingIndicator(message: nil)
                
                self.vzrOnOffService.vzrBonusFranchiseCerificatesUrl(insuranceId: insurance.id) {
                    [weak viewController] result in

                    hide(nil)
                    
                    guard let viewController = viewController
                    else { return }

                    switch result {
                        case .success(let url):
                            WebViewer.openDocument(
                                url,
                                showShareButton: false,
                                from: viewController
                            )
                        case .failure(let error):
                            viewController.processError(error)
                    }
                }
            },
            kaskoExtend: { [weak self, weak viewController] in
                guard let self = self,
                      let viewController = viewController
                else { return }
                
                let hide = viewController.showLoadingIndicator(message: nil)
                
                self.kaskoExtensionService.kaskoExtensionUrl(insuranceId: insurance.id) {
                    [weak viewController] result in

                    hide(nil)
                    
                    guard let viewController = viewController
                    else { return }

                    switch result {
                        case .success(let url):
                            WebViewer.openDocument(
                                url,
                                showShareButton: false,
                                from: viewController
                            )
                        case .failure(let error):
                            viewController.processError(error)
                    }
                }
            },
            vzrRefundCertificate: { [weak self, weak viewController] in
                guard let self,
                      let viewController
                else { return }
                
                let hide = viewController.showLoadingIndicator(message: nil)
                
                self.vzrOnOffService.vzrBonusRefundUrl(insuranceId: insurance.id) {
                    [weak viewController] result in

                    hide(nil)
                    
                    guard let viewController = viewController
                    else { return }

                    switch result {
                        case .success(let url):
                            WebViewer.openDocument(
                                url,
                                showShareButton: false,
                                from: viewController
                            )
                        case .failure(let error):
                            viewController.processError(error)
                    }
                }
				
				if let analyticsData = analyticsData(
					from: self.insurancesService.cachedShortInsurances(forced: true),
					for: insurance.id
				) {
					self.analytics.track(
						navigationSource: AnalyticsParam.NavigationSource.dmsDetails,
						insuranceId: insurance.id,
						event: AnalyticsEvent.Dms.vzrRefundCertificate,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
				}
            },
            dmsCostRecovery: { [weak viewController] in
                guard let viewController
                else { return }
                
                self.showDmsCostRecovery(insurance: insurance, from: viewController)
				
				if let analyticsData = analyticsData(
					from: self.insurancesService.cachedShortInsurances(forced: true),
					for: insurance.id
				) {
					self.analytics.track(
						navigationSource: AnalyticsParam.NavigationSource.dmsDetails,
						insuranceId: insurance.id,
						event: AnalyticsEvent.Dms.costRecovery,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
				}
            },
            openHealthAcademy: { [weak viewController] in
                guard let controller = viewController
                else { return }
                
                self.showHealthAcademy(from: controller)
            },
            openInsuranceProgram: { [weak viewController] in
                guard let viewController
                else { return }
                self.showInsuranceProgram(insurance: insurance, from: viewController)
				
				if let analyticsData = analyticsData(
					from: self.insurancesService.cachedShortInsurances(forced: true),
					for: insurance.id
				) {
					self.analytics.track(
						navigationSource: AnalyticsParam.NavigationSource.dmsDetails,
						insuranceId: insurance.id,
						event: AnalyticsEvent.Dms.insuranceProgram,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
				}
            },
            medicalCard: { [weak viewController] in
                guard let viewController
                else { return }
                
                self.showMedicalCard(
                    from: viewController
                )
				
				if let analyticsData = analyticsData(
					from: self.insurancesService.cachedShortInsurances(forced: true),
					for: insurance.id
				) {
					self.analytics.track(
						navigationSource: AnalyticsParam.NavigationSource.dmsDetails,
						insuranceId: insurance.id,
						event: AnalyticsEvent.Dms.medicalCard,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
				}
            },
            manageSubscription: { [weak self, weak viewController] in
                guard let self = self,
                      let viewController = viewController
                else { return }
                let hide = viewController.showLoadingIndicator(message: nil)
                self.marksWebService.manageSubscriptionUrl(insuranceId: insurance.id) { result in
                    hide(nil)
                    switch result {
                        case .success(let url):
                            self.linkTap(url, from: viewController)
                        case .failure(let error):
                            viewController.processError(error)
                    }
                }
            },
            appointBeneficiary: { [weak self, weak viewController] in
                guard let self = self,
                      let viewController = viewController
                else { return }
                let hide = viewController.showLoadingIndicator(message: nil)
                self.marksWebService.appointBeneficiaryUrl(insuranceId: insurance.id) { result in
                    hide(nil)
                    switch result {
                        case .success(let url):
                            self.linkTap(url, from: viewController)
                        case .failure(let error):
                            viewController.processError(error)
                    }
                }
            },
            editInsuranceAgreement: { [weak self, weak viewController] in
                guard let self = self,
                      let viewController = viewController
                else { return }
                let hide = viewController.showLoadingIndicator(message: nil)
                self.marksWebService.editInsuranceAgreementUrl(insuranceId: insurance.id) { result in
                    hide(nil)
                    switch result {
                        case .success(let url):
                            self.linkTap(url, from: viewController)
                        case .failure(let error):
                            viewController.processError(error)
                    }
                }
            },
			insuranceInfoTap: {
				if let analyticsData = analyticsData(
					from: self.insurancesService.cachedShortInsurances(forced: true),
					for: insurance.id
				) {
					self.analytics.track(
						navigationSource: AnalyticsParam.NavigationSource.dmsDetails,
						insuranceId: insurance.id,
						event: AnalyticsEvent.Dms.insuranceDetails,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
				}
			},
			tabSwitched: { insurance in
				switch insurance.insuranceEventKind {
					case .doctorAppointment:
						if let analyticsData = analyticsData(
							from: self.insurancesService.cachedShortInsurances(forced: true),
							for: insurance.id
						) {
							self.analytics.track(
								navigationSource: AnalyticsParam.NavigationSource.dmsDetails,
								insuranceId: insurance.id,
								event: AnalyticsEvent.Dms.appointmentsList,
								userProfileProperties: analyticsData.analyticsUserProfileProperties
							)
						}
						
					case .accident, .auto, .none, .passengers, .vzr, .propetry:
						break
						
				}
			},
			demo: { [weak viewController] in
				
				guard let viewController
				else { return }
				
				DemoBottomSheet.presentInfoDemoSheet(from: viewController)
			},
			medicalServiceTap: { field in
				if let analyticsData = analyticsData(
					from: self.insurancesService.cachedShortInsurances(forced: true),
					for: insurance.id
				) {
					let properties: [String: String] = [
						AnalyticsParam.Key.navigationSource: AnalyticsParam.NavigationSource.dmsDetails.rawValue,
						AnalyticsParam.Key.insuranceId: insurance.id,
						AnalyticsParam.Key.contentType: {
							switch field.type {
								case .text:
									return "TEXT"
								case .map:
									return "MAP"
								case .link:
									return "LINK"
								case .phone:
									return "PHONE"
								case .clinicsList:
									return "CLINICS"
							}
						}(),
						AnalyticsParam.Key.content: field.text
					]
					
					self.analytics.track(
						event: AnalyticsEvent.Dms.medicalService,
						properties: properties,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
					
					switch field.type {
						case .clinicsList:
							self.analytics.track(
								navigationSource: AnalyticsParam.NavigationSource.dmsDetails,
								insuranceId: analyticsData.insuranceId,
								event: AnalyticsEvent.Dms.clinics,
								userProfileProperties: analyticsData.analyticsUserProfileProperties
							)
						case .map, .link, .text, .phone:
							break
					}
				}
			}
        )
        
        insurancesService.subscribeForSingleInsuranceUpdate(
            listener: viewController.notify.insuranceUpdated
        ).disposed(by: viewController.disposeBag)
        
        return viewController
    }
    // swiftlint:enable function_body_length cyclomatic_complexity
    
    private func showMedicalCard(
        from: UIViewController
    ) {
        let medicalCardFlow = MedicalCardFlow(rootController: from)
        self.container?.resolve(medicalCardFlow)
        medicalCardFlow.start()
    }

    private func showCreateEvent(
        insurance: Insurance,
		sosActivity: SosActivityModel? = nil,
        filterName: String? = nil,
        controller: ViewController,
        showMode: ViewControllerShowMode
    ) {
        let insuranceEventFlow = InsuranceEventFlow(insurance: insurance, rootController: controller)
        self.container?.resolve(insuranceEventFlow)
        insuranceEventFlow.onlineClinicAppointmentFlow = onlineClinicAppointmentFlow
        insuranceEventFlow.createInsuranceEvent(insurance: insurance, sosActivity: sosActivity, from: controller, showMode: showMode, filterName: filterName)
    }

    private func showTripPoints(insurance: Insurance, sourceView: UIView, controller: InsuranceViewController) {
        let tripPointsController = TripPointsPopoverController(points: insurance.tripIntermediatePoints)
        tripPointsController.popoverPresentationController?.sourceView = sourceView
        tripPointsController.popoverPresentationController?.sourceRect = sourceView.bounds
        controller.present(tripPointsController, animated: true, completion: nil)
    }

    private func getSosListInstructions(viewController: InsuranceViewController, category: InsuranceCategory) {
        let hide = viewController.showLoadingIndicator(message: nil)
        self.insurancesService.insurances(useCache: true) { [weak viewController] result in
			hide(nil)
			
            guard let fromVC = viewController
			else { return }

            switch result {
                case .success(let response):
                    let instructions
                        = response.sosList.flatMap { $0.instructionList.filter { $0.insuranceCategoryId == category.id } }
                    self.showInstructionsList(instructions: instructions, fromVC: fromVC)
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }

    private func getFlatOnOffInsurance(insurance: Insurance, completion: @escaping (Result<FlatOnOffInsurance, AlfastrahError>) -> Void) {
        self.flatOnOffService.insurances { result in
            switch result {
                case .success(let insurances):
                    if let flat = insurances.first(where: { $0.id == insurance.id }) {
                        completion(.success(flat))
                    } else {
                        completion(.failure(.error(FlatOnOffServiceError.insuranceNotFound)))
                    }
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
	
	func showDoctorAppointments(for insuranceId: String, from: ViewController) {
		let hide = from.showLoadingIndicator(
			message: NSLocalizedString("common_load", comment: "")
		)
		
		category(forInsuranceId: insuranceId, useCache: true) { result in
			hide(nil)
			switch result {
				case.success((let insurance, let category)):
					guard let category
					else {
						self.alertPresenter.show(
							alert: ErrorNotificationAlert(
								error: nil,
								text: NSLocalizedString("common_missing_category", comment: "")
							)
						)
						return
					}
					
					self.showInsurance(
						insurance,
						category: category,
						hideTabSwitch: true,
						initialSelectedTab: .insuranceEvent,
						navigationTitle: NSLocalizedString("clinic_appointment_online_create_title", comment: "")
					)
					
				case .failure(let error):
					ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
			}
		}
	}

    private func showVzrOnOff(_ option: VzrOnOffFlow.StartOption, from controller: ViewController, insuranceId: String) {
        let flow = VzrOnOffFlow(rootController: controller)
        container?.resolve(flow)
        flow.start(option: option, insuranceId: insuranceId)
    }

    private func showFlatOnOff(mode: FlatOnOffFlow.Mode, from viewController: UIViewController, insurance: Insurance) {
        let flow = FlatOnOffFlow(rootController: viewController)
        container?.resolve(flow)
        flow.start(mode: mode, insurance: insurance)
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

    private func insuranceEventListController(
        _ insurance: Insurance,
        from: UIViewController
    ) -> UIViewController? {
        switch insurance.insuranceEventKind {
            case .auto, .passengers, .accident, .propetry:
                let insuranceEventFlow = InsuranceEventFlow(insurance: insurance, rootController: from)
                container?.resolve(insuranceEventFlow)
                return insuranceEventFlow.eventReportsList()
            case .doctorAppointment:
                let onlineClinicAppointmentFlow = CommonClinicAppointmentFlow(rootController: from)
                container?.resolve(onlineClinicAppointmentFlow)
                self.onlineClinicAppointmentFlow = onlineClinicAppointmentFlow
                return onlineClinicAppointmentFlow.start(insurance: insurance)
            case .vzr:
                return insuranceEntryViewController(
                    insuranceId: insurance.id
                )
			case .none:
                return nil
        }
    }
    
    private func insuranceEntryViewController(
        insuranceId: String
    ) -> InsuranceEntryViewController {
        let insuranceEntryViewController = InsuranceEntryViewController()
        container?.resolve(insuranceEntryViewController)
        insuranceEntryViewController.input = .init(
            insuranceReportsVZR: {
                self.vzrOnOffService.vzrReports(
                    insuranceId: insuranceId,
                    completion: { [weak insuranceEntryViewController] result in
                        switch result {
                            
                            case .success(let vzrReports):
                                insuranceEntryViewController?.notify.updateWithState(.filled(vzrReports)
                                )
                            case .failure:
                                insuranceEntryViewController?.notify.updateWithState(
                                    .failure
                                )
                            }
                    }
                )
            })
    
        insuranceEntryViewController.output = .init(
            goToAboutEntry: { [weak insuranceEntryViewController] in
                self.createAndPushAboutInsuranceEntryViewController(
                    reportId: $0
                )
            }
        )
        return insuranceEntryViewController
    }
    
    private func createAndPushAboutInsuranceEntryViewController(reportId: Int64) {
        let aboutInsuranceEntryViewController = AboutInsuranceEntryViewController()
        container?.resolve(aboutInsuranceEntryViewController)
        aboutInsuranceEntryViewController.input = .init(
            insuranceReportVZRDetailed: {
                self.vzrOnOffService.vzrReportDetailed(
                    reportId: reportId,
                    completion: { [weak aboutInsuranceEntryViewController] result in
                        switch result {
                            case .success(let vzrReportDetailed):
                                aboutInsuranceEntryViewController?.notify.updateWithState(
                                    .filled(vzrReportDetailed)
                                )
                            case .failure:
                                aboutInsuranceEntryViewController?.notify.updateWithState(
                                    .failure
                                )
                        }
                    }
                )
            }
        )
        aboutInsuranceEntryViewController.output = .init(
            goToChat: {
                ApplicationFlow.shared.show(item: .tabBar(.chat))
            },
            goToWeb: { [weak aboutInsuranceEntryViewController] url in
                guard let aboutInsuranceEntryViewController = aboutInsuranceEntryViewController
                else { return }
                
                WebViewer.openDocument(
                    url,
                    withAuthorization: true,
                    needSharedUrl: false,
                    from: aboutInsuranceEntryViewController
                )
            }
        )
        navigationController?.pushViewController(
            aboutInsuranceEntryViewController,
            animated: true
        )
    }

    private func searchInsuranceViewController() -> CreateInsuranceSearchRequestViewController {
        let storyboard = UIStoryboard(name: "InsuranceSearchRequest", bundle: nil)
        let controller: CreateInsuranceSearchRequestViewController = storyboard.instantiateInitial()
        container?.resolve(controller)
        return controller
    }

    private func showTelemedicineInfo(insurance: Insurance) {
        let viewController: TelemedicineInfoViewController = storyboard.instantiate()
        container?.resolve(viewController)
        // swiftlint:disable:next trailing_closure
        viewController.output = TelemedicineInfoViewController.Output(
            telemedicine: { [weak viewController] in
                guard let controller = viewController else { return }

                self.showTelemedicine(insurance: insurance, from: controller)
            }
        )
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func showFranchiseTransition(insurance: Insurance, from: UIViewController) {
        let franchiseTransitionFlow = FranchiseTransitionFlow(rootController: from)
        self.container?.resolve(franchiseTransitionFlow)
        franchiseTransitionFlow.showFranchiseTransitionScreen(insuranceId: insurance.id)
    }
    
    private func showDmsCostRecovery(insurance: Insurance, from: UIViewController) {
        let dmsCostRecoveryFlow = DmsCostRecoveryFlow(rootController: from)
        self.container?.resolve(dmsCostRecoveryFlow)
        dmsCostRecoveryFlow.start(insuranceId: insurance.id)
    }
    
    private func showHealthAcademy(from: UIViewController) {
        let healthAcademyFlow = HealthAcademyFlow(rootController: from)
        self.container?.resolve(healthAcademyFlow)
        healthAcademyFlow.show()
    }
    
	private func showInsuranceProgram(insurance: Insurance, from: UIViewController, insuranceHelpUrl: URL? = nil) {
        let insuranceProgramFlow = InsuranceProgramFlow(rootController: from)
        self.container?.resolve(insuranceProgramFlow)
        insuranceProgramFlow.show(
			insuranceId: insurance.id,
			insuranceHelpType: insurance.helpType,
			insuranceHelpUrl: {
				if let url = insuranceHelpUrl {
					return url
				}
				return insurance.helpURL
			}()
		)
    }

    // MARK: - Archive Insurances Update
    private func groupedInsurances(
        owner: InsuranceOwnerKind,
        archive: Bool,
        useCache: Bool,
        completion: @escaping (Result<[GroupedInsurances], AlfastrahError>) -> Void
    ) {
        var insuranceCategories: [InsuranceCategory] = []

        // 2: load [Insurance]
        let insurancesCompletion: (Result<[Insurance], AlfastrahError>) -> Void = { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let insurances):
                    let insurances = insurances.filter { archive ? $0.isArchive : true }
                    completion(.success(InsuranceHelper.groupInsurances(insurances, with: insuranceCategories)))
                case .failure(let error):
                    self.logger?.error(error.localizedDescription)
                    completion(.failure(error))
            }
        }

        // 1: load [InsuranceCategory]
        loadInsuranceCategories(useCache: useCache) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let categories):
                    insuranceCategories = categories
                    self.loadInsurances(owner: owner, includeArchive: archive, useCache: useCache, completion: insurancesCompletion)
                case .failure(let error):
                    self.logger?.error(error.localizedDescription)
                    completion(.failure(error))
            }
        }
    }

    private func category(forInsuranceId
        id: String,
        useCache: Bool,
        completion: @escaping (Result<(Insurance, InsuranceCategory?), AlfastrahError>) -> Void
    ) {
        var insuranceCategories: [InsuranceCategory] = []

        // 2: load Insurance
        let insuranceCompletion: (Result<Insurance, AlfastrahError>) -> Void = { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let insurance):
                    let category = insuranceCategories.first(where: { $0.productIds.contains(insurance.productId) })

                    completion(.success((insurance, category)))
                case .failure(let error):
                    self.logger?.error(error.localizedDescription)
                    completion(.failure(error))
            }
        }

        // 1: load [InsuranceCategory]
        loadInsuranceCategories(useCache: useCache) { [weak self] result in
            guard let self = self else { return }

            switch result {
                case .success(let categories):
                    insuranceCategories = categories
                    self.loadInsurance(id: id, useCache: useCache, completion: insuranceCompletion)
                case .failure(let error):
                    self.logger?.error(error.localizedDescription)
                    completion(.failure(error))
            }
        }
    }

    // MARK: - Data reception

    private func loadInsurances(
        owner: InsuranceOwnerKind,
        includeArchive: Bool, useCache: Bool,
        completion: @escaping (Result<[Insurance], AlfastrahError>) -> Void
    ) {
        let cached: [Insurance] = useCache ? insurancesService.cachedInsurances(owner: owner, includeArchive: includeArchive) : []
        if !cached.isEmpty {
           completion(.success(cached))
        } else {
            insurancesService.insurances(owner: owner, includeArchive: includeArchive, completion: completion)
        }
    }

    private func loadInsuranceCategories(
        useCache: Bool,
        completion: @escaping (Result<[InsuranceCategory], AlfastrahError>) -> Void
    ) {
        let cached: [InsuranceCategory] = useCache ? insurancesService.cachedInsuranceCategories() : []
        if !cached.isEmpty {
            completion(.success(cached))
        } else {
            insurancesService.insuranceCategories(completion: completion)
        }
    }

    private func loadInsurance(
        id: String,
        useCache: Bool,
        completion: @escaping (Result<Insurance, AlfastrahError>) -> Void
    ) {
        insurancesService.insurance(useCache: useCache, id: id, completion: completion)
    }

    // MARK: - Insurance actions

    // TODO: Refactor KASKORenewFlow (JIRA: AS-2391)
    private var kaskoRenewFlow: KASKORenewFlow?

    private func renewKasko(
        _ insurance: Insurance,
        renewalType: InsuranceShort.RenewType?,
        from controller: UIViewController
    )
    {
        let flow = KASKORenewFlow(rootController: controller)
        container?.resolve(flow)
        kaskoRenewFlow = flow

        flow.start(
            insurance: insurance,
            renewalType: renewalType
        )
    }

    func renewRemontNeighbours(_ insurance: Insurance, from controller: UIViewController) {
        let flow = RemontNeighboursRenewFlow()
        container?.resolve(flow)
        flow.start(from: controller, insurance: insurance)
    }

    private func renewOsago(_ insuranceId: String, from controller: UIViewController, showMode: ViewControllerShowMode) {
        let flow = OSAGORenewFlow(rootController: controller)
        container?.resolve(flow)
        flow.start(insuranceId: insuranceId)
    }

    private func renewOrdinary(_ insuranceId: String, from controller: ViewController) {
        let cancellable = CancellableNetworkTaskContainer()
        let hide = controller.showLoadingIndicator(
            message: NSLocalizedString("common_loading_title", comment: ""),
            cancellable: cancellable
        )
        let networkTask = insurancesService.insuranceRenewUrl(insuranceID: insuranceId) { result in
            hide(nil)
            switch result {
                case .success(let url):
                    self.linkTap(url, from: controller)
                case .failure(let error):
                    guard !error.isCanceled else { return }

                    self.show(error: error)
            }
        }
        cancellable.addCancellables([ networkTask ])
    }

    private func buyNewInsurance(_ insurance: Insurance, from controller: UIViewController) {
        let cancellable = CancellableNetworkTaskContainer()
        let hide = controller.showLoadingIndicator(
            message: NSLocalizedString("common_loading_title", comment: ""),
            cancellable: cancellable
        )
        let networkTask = insurancesService.insuranceFromPreviousPurchaseDeeplinkUrl(productId: insurance.productId) { result in
            hide(nil)
            switch result {
                case .success(let url):
                    self.linkTap(url, from: controller)
                case .failure(let error):
                    guard !error.isCanceled else { return }

                    self.show(error: error)
            }
        }
        cancellable.addCancellables([ networkTask ])
    }
    
    private func makeChangesToInsurance(_ insurance: Insurance, from controller: ViewController) {
        guard accountService.isAuthorized
        else { return }
        
        guard !accountService.isDemo
        else {
            DemoAlertHelper().showDemoAlert(from: controller)
            return
        }
                
        let cancellable = CancellableNetworkTaskContainer()
        let hide = controller.showLoadingIndicator(
            message: NSLocalizedString("common_loading_title", comment: ""),
            cancellable: cancellable
        )
        
        let networkTask = self.insurancesService.osagoChangeUrl(insuranceID: insurance.id) { result in
            hide(nil)
            switch result {
                case .success(let url):
                    self.linkTap(
                        url,
                        from: controller
                    )
                case .failure(let error):
                    guard !error.isCanceled
                    else { return }
                    
                    self.show(error: error)
            }
        }
        cancellable.addCancellables([ networkTask ])
    }
    
    private func terminateOsago(_ insurance: Insurance, from viewController: ViewController) {
        guard accountService.isAuthorized
        else { return }
        
        guard !accountService.isDemo
        else {
            DemoAlertHelper().showDemoAlert(from: viewController)
            return
        }
        
        let cancellable = CancellableNetworkTaskContainer()
        let hide = viewController.showLoadingIndicator(
            message: NSLocalizedString("common_loading_title", comment: ""),
            cancellable: cancellable
        )
                    
        let networkTask = self.insurancesService.osagoTerminationUrl(insuranceID: insurance.id) { result in
            hide(nil)
            switch result {
                case .success(let url):
                    self.linkTap(
                        url,
                        from: viewController
                    )
                case .failure(let error):
                    guard !error.isCanceled
                    else { return }
                    
                    self.show(error: error)
            }
        }
        cancellable.addCancellables([ networkTask ])
    }
    
    private func addToPassbook(insurance: Insurance, from controller: UIViewController) {
        guard accountService.isAuthorized
        else { return }
        
        guard !accountService.isDemo
        else {
			DemoBottomSheet.presentInfoDemoSheet(from: controller)
            return
        }
        
        let cancellable = CancellableNetworkTaskContainer()
        let hide = controller.showLoadingIndicator(
            message: NSLocalizedString("common_loading_title", comment: ""),
            cancellable: cancellable
        )

        let networkTask = self.passbookService.addPass(for: insurance) { result in
            hide(nil)
            switch result {
                case .success(let pass):
                    guard let passController = PKAddPassesViewController(pass: pass) else { return }
                    controller.present(passController, animated: true, completion: nil)
                case .failure(let error):
                    switch error {
                        case .passAlreadyExists:
                            self.show(error: error)
                        case .error(let error):
                            guard !error.isCanceled else { return }

                            self.show(error: error)
                    }
            }
        }
        cancellable.addCancellables([ networkTask ])
    }

    private func showTelemedicine(insurance: Insurance, from controller: ViewController) {
        let hide = controller.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))

        insurancesService.telemedicineUrl(insuranceId: insurance.id) { result in
            hide(nil)
            switch result {
                case .success(let url):
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                case .failure(let error):
                    self.show(error: error)
            }
        }
    }

    // MARK: - Helpers
    private func linkTap(_ url: URL, from: UIViewController) {
        SafariViewController.open(url, from: from)
    }
    
    private func pdfLinkTap(_ url: URL, from: UIViewController) {
        WebViewer.openDocument(url, from: from)
    }

    private func phoneTap(_ phone: Phone) {
        PhoneHelper.handlePhone(plain: phone.plain, humanReadable: phone.humanReadable)
    }

    private func showChat() {
        ApplicationFlow.shared.show(item: .tabBar(.chat))
    }

    // MARK: - Error handle

    private func show(error: Error) {
        ErrorHelper.show(error: error, alertPresenter: alertPresenter)
    }
}
// swiftlint:enable file_length
