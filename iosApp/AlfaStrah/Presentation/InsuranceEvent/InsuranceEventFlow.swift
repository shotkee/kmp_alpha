//
//  InsuranceEventFlow
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 23/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy
import CoreLocation

// swiftlint:disable file_length
class InsuranceEventFlow: BDUI.ActionHandlerFlow,
						  AttachmentServiceDependency,
						  EventReportServiceDependency,
						  InsuranceLifeServiceDependency,
						  InteractiveSupportServiceDependency {
	var attachmentService: AttachmentService!
	var eventReportService: EventReportService!
	var insuranceAlfaLifeService: InsuranceLifeService!
	var interactiveSupportService: InteractiveSupportService!
	
    var onlineClinicAppointmentFlow: CommonClinicAppointmentFlow?
	
	private var fromViewController: UIViewController?
	private var navigationController: UINavigationController?
    
    deinit {
        logger?.debug("")
    }

    private let storyboard = UIStoryboard(name: "InsuranceEvent", bundle: nil)

    private var insurance: Insurance?
    private let disposeBag: DisposeBag = DisposeBag()

	convenience init(insurance: Insurance? = nil, rootController: UIViewController) {
		self.init()
		
		self.fromViewController = rootController

		self.insurance = insurance
    }

    enum EventReportKind {
        case passenger(EventReport)
        case auto(EventReportAuto)
        case accident(EventReportAccident)

        var eventId: String {
            switch self {
                case .auto(let event):
                    return event.id
                case .passenger(let event):
                    return event.id
                case .accident(let event):
                    return event.id
            }
        }

        var eventNumber: String {
            switch self {
                case .auto(let event):
                    return event.number
                case .passenger(let event):
                    return event.number
                case .accident(let event):
                    return event.number
            }
        }
    }

    enum EventReportId {
        case passengers(String)
        case osago(String)
        case kasko(String)

        var value: String {
            switch self {
                case .passengers(let id), .osago(let id), .kasko(let id):
                    return id
            }
        }
    }

    enum DraftKind {
        case passengerDraft(PassengersEventDraft)
        case autoDraft(AutoEventDraft)
    }
    
    func handleActiveEventWithInsurances(for group: InsuranceGroupCategory, from: ViewController) {
        let hide = from.showLoadingIndicator(message: nil)
        getSosActivityInsurances(group: group) { result in
            hide {}
            switch result {
                case .success(let insurances):
                    self.createInsuranceEvent(insurances: insurances, group: group, from: from, showMode: .modal)
                case .failure(let error):
                    from.processError(error)
            }
        }
    }
    
    func handleActiveEventWithShortInsurances(for group: InsuranceGroupCategory, from: ViewController) {
        switch group.sosActivity?.kind {
            case .interactiveSupport:
                let shortInsurances = group.insuranceList
                
                if shortInsurances.count > 1 {
                    let insuranceFlow = InsurancesFlow()
                    container?.resolve(insuranceFlow)
                    
                    insuranceFlow.selectInsurance(
                        ids: shortInsurances.compactMap { $0.id },
                        requestOnboardingData: true,
                        from: from,
                        showMode: .modal
                    ) { insuranceShort, onboardingData, controller in
                        self.startInteractiveSupportOnboarding(
                            for: insuranceShort,
                            with: onboardingData,
                            from: controller,
                            showMode: .modal
                        )
                    }
                } else {
                    if let insuranceShort = shortInsurances.first {
                        startInteractiveSupportOnboarding(for: insuranceShort, from: from, showMode: .push)
                    }
                }
            case .onWebsite:
                
                let shortInsurances = group.insuranceList
                
                if shortInsurances.count > 1 {
                    let insuranceFlow = InsurancesFlow()
                    container?.resolve(insuranceFlow)
                    
                    insuranceFlow.selectInsurance(
                        ids: shortInsurances.compactMap { $0.id },
                        requestOnboardingData: false,
                        from: from,
                        showMode: .modal
                    ) { insuranceShort, onboardingData, controller in
                        self.createReportOnWebsiteEvent(insuranceId: insuranceShort.id, from: controller)
                    }
                } else {
                    if let insuranceShort = shortInsurances.first {
                        createReportOnWebsiteEvent(insuranceId: insuranceShort.id, from: from)
                    }
                }
            case
                .accidentInsuranceEvent,
                .autoInsuranceEvent,
                .call,
                .callback,
                .doctorAppointment,
                .onlinePayment,
                .passengersInsuranceEvent,
                .passengersInsuranceWebEvent,
                .unsupported,
                .voipCall,
				.life,
                .vzrInsuranceEvent,
                .none:
                break

        }
    }

    func startActiveEventsList(insuranceId: String, _ group: InsuranceGroupCategory, from: ViewController) {
        fromViewController = from
        if group.sosActivity?.kind.hasEventsList == false {
            switch group.sosActivity?.kind {
                case .interactiveSupport,
                     .onWebsite:
                    handleActiveEventWithShortInsurances(for: group, from: from)
                case
                    .accidentInsuranceEvent,
                    .autoInsuranceEvent,
                    .call,
                    .callback,
                    .doctorAppointment,
                    .onlinePayment,
                    .passengersInsuranceEvent,
                    .passengersInsuranceWebEvent,
                    .unsupported,
                    .voipCall,
					.life,
                    .vzrInsuranceEvent:
                    handleActiveEventWithInsurances(for: group, from: from)
                    
                case .none:
                    break

            }
        } else {
            let viewController: ActiveEventsViewController = UIStoryboard(name: "Home", bundle: nil).instantiate()
            viewController.addCloseButton { [weak viewController] in
                viewController?.dismiss(animated: true, completion: nil)
            }
            container?.resolve(viewController)
            viewController.input = ActiveEventsViewController.Input(
                data: { completion in
                    self.getActiveEvents(group) { result in
                        completion(result)
                    }
                },
                draft: { insurance in
                    switch insurance.insuranceEventKind {
                        case .auto:
                            return self.eventReportService
                                .autoEventDrafts()
                                .first { $0.insuranceId == insurance.id }
                                .map(DraftKind.autoDraft)
                        case .passengers:
                            return self.eventReportService.passengersDrafts().first { $0.insuranceId == insurance.id }
                                .map(DraftKind.passengerDraft)
						case .doctorAppointment, .accident, .none, .vzr, .propetry:
                            return nil
                    }
                }
            )
            viewController.output = .init(
                selectEvent: { [weak viewController] kind, insurance in
                    guard let controller = viewController else { return }

                    switch kind {
                        case .auto:
                            self.analytics.track(event: AnalyticsEvent.Auto.openReportAutoStatusMain)
                            self.showEventReport(kind, insurance: insurance, mode: .push)
                        case .passenger:
                            self.showEventReport(kind, insurance: insurance, mode: .push)
                        case .accident(let event):
                            let accidentFlow = AccidentEventFlow(rootController: controller)
                            self.container?.resolve(accidentFlow)
                            accidentFlow.start(insurance: insurance, flowMode: .show(event), showMode: .push)
                    }

                },
                selectDraft: { [weak viewController] draftKind, insurance in
                    guard let controller = viewController else { return }

                    switch draftKind {
                        case .passengerDraft(let draft):
                            self.analytics.track(event: AnalyticsEvent.Passenger.reportPassengersOpenDraftMain)
                            self.createInsuranceEvent(insurance: insurance, for: group, from: controller, showMode: .push, kaskoDraft: nil,
                                passengerDraft: draft)
                        case .autoDraft(let draft):
                            self.analytics.track(event: AnalyticsEvent.Auto.reportAutoOpenDraftMain)
                            self.createInsuranceEvent(insurance: insurance, for: group, from: controller, showMode: .push, kaskoDraft: draft,
                                passengerDraft: nil)
                    }
                },
                createEvent: { [weak viewController] insurances in
                    guard let controller = viewController else { return }

                    if let insurance = insurances.first {
                        switch insurance.insuranceEventKind {
                            case .auto:
                                self.analytics.track(event: AnalyticsEvent.Auto.reportAutoMainProceed)
                            case .passengers:
                                self.analytics.track(event: AnalyticsEvent.Passenger.reportPassengersMainProceed)
							case .none, .doctorAppointment, .accident, .vzr, .propetry:
                                break
                        }
                    }
                    self.createInsuranceEvent(insurances: insurances, group: group, from: controller)
                }
            )

            eventReportService.subscribeForDraftUpdates(
                listener: viewController.notify.draftUpdated
            ).disposed(by: viewController.disposeBag)
            let navigationController = RMRNavigationController(rootViewController: viewController)
            navigationController.strongDelegate = RMRNavigationControllerDelegate()
            self.navigationController = navigationController
            from.present(navigationController, animated: true, completion: nil)
        }
    }
	
	func showActiveEvents(for group: InsuranceGroupCategory, from: ViewController) {
		let viewController: ActiveEventsViewController = UIStoryboard(name: "Home", bundle: nil).instantiate()
		viewController.addCloseButton { [weak viewController] in
			viewController?.dismiss(animated: true, completion: nil)
		}
		container?.resolve(viewController)
		viewController.input = ActiveEventsViewController.Input(
			data: { completion in
				self.getActiveEvents(group) { result in
					completion(result)
				}
			},
			draft: { insurance in
				switch insurance.insuranceEventKind {
					case .auto:
						return self.eventReportService
							.autoEventDrafts()
							.first { $0.insuranceId == insurance.id }
							.map(DraftKind.autoDraft)
					case .passengers:
						return self.eventReportService.passengersDrafts().first { $0.insuranceId == insurance.id }
							.map(DraftKind.passengerDraft)
					case .doctorAppointment, .accident, .none, .vzr, .propetry:
						return nil
				}
			}
		)
		viewController.output = .init(
			selectEvent: { [weak viewController] kind, insurance in
				guard let controller = viewController else { return }

				switch kind {
					case .auto:
						self.analytics.track(event: AnalyticsEvent.Auto.openReportAutoStatusMain)
						self.showEventReport(kind, insurance: insurance, mode: .push)
					case .passenger:
						self.showEventReport(kind, insurance: insurance, mode: .push)
					case .accident(let event):
						let accidentFlow = AccidentEventFlow(rootController: controller)
						self.container?.resolve(accidentFlow)
						accidentFlow.start(insurance: insurance, flowMode: .show(event), showMode: .push)
				}

			},
			selectDraft: { [weak viewController] draftKind, insurance in
				guard let controller = viewController else { return }

				switch draftKind {
					case .passengerDraft(let draft):
						self.analytics.track(event: AnalyticsEvent.Passenger.reportPassengersOpenDraftMain)
						self.createInsuranceEvent(insurance: insurance, for: group, from: controller, showMode: .push, kaskoDraft: nil,
							passengerDraft: draft)
					case .autoDraft(let draft):
						self.analytics.track(event: AnalyticsEvent.Auto.reportAutoOpenDraftMain)
						self.createInsuranceEvent(insurance: insurance, for: group, from: controller, showMode: .push, kaskoDraft: draft,
							passengerDraft: nil)
				}
			},
			createEvent: { [weak viewController] insurances in
				guard let controller = viewController else { return }

				if let insurance = insurances.first {
					switch insurance.insuranceEventKind {
						case .auto:
							self.analytics.track(event: AnalyticsEvent.Auto.reportAutoMainProceed)
						case .passengers:
							self.analytics.track(event: AnalyticsEvent.Passenger.reportPassengersMainProceed)
						case .none, .doctorAppointment, .accident, .vzr, .propetry:
							break
					}
				}
				self.createInsuranceEvent(insurances: insurances, group: group, from: controller)
			}
		)

		eventReportService.subscribeForDraftUpdates(
			listener: viewController.notify.draftUpdated
		).disposed(by: viewController.disposeBag)
		let navigationController = RMRNavigationController(rootViewController: viewController)
		navigationController.strongDelegate = RMRNavigationControllerDelegate()
		self.navigationController = navigationController
		from.present(navigationController, animated: true, completion: nil)
	}

    private func createInsuranceEvent(
        insurances: [Insurance],
        group: InsuranceGroupCategory,
        from: ViewController,
        showMode: ViewControllerShowMode = .push
    ) {
        if insurances.count > 1 {
            chooseViewController(from: from, insurances: insurances, for: group, showMode: showMode)
        } else {
            guard let insurance = insurances.first
            else { return }

			createInsuranceEvent(insurance: insurance, sosActivity: group.sosActivity, for: group, from: from, showMode: .push)
        }
    }

    func chooseViewController(
        from: ViewController,
        insurances: [Insurance],
        for group: InsuranceGroupCategory,
        showMode: ViewControllerShowMode
    ) {
        let insuranceFlow = InsurancesFlow()
        container?.resolve(insuranceFlow)
        
        if let sosActivityKind = group.sosActivity?.kind {
            switch sosActivityKind {
                case .interactiveSupport:
                    insuranceFlow.selectInsurance(
                        ids: insurances.compactMap { $0.id },
                        requestOnboardingData: true,
                        from: from,
                        showMode: showMode
                    ) { insuranceShort, onboardingData, controller  in
                        guard let insurance = self.insurancesService.cachedInsurance(id: insuranceShort.id)
                        else { return }

                        self.createInsuranceEvent(
                            insurance: insurance,
                            for: group,
                            from: controller,
                            showMode: .modal,
                            onboardingData: onboardingData
                        )
                    }
                    
                case
                    .unsupported,
                    .call,
                    .callback,
                    .autoInsuranceEvent,
                    .doctorAppointment,
                    .voipCall,
                    .passengersInsuranceEvent,
                    .onlinePayment,
                    .vzrInsuranceEvent,
                    .accidentInsuranceEvent,
                    .onWebsite,
					.life,
                    .passengersInsuranceWebEvent:
                    insuranceFlow.selectInsurance(
                        ids: insurances.compactMap { $0.id },
						sosActivity: group.sosActivity,
                        from: from,
                        showMode: showMode
                    ) { insuranceShort, _, controller  in
                        guard let insurance = self.insurancesService.cachedInsurance(id: insuranceShort.id)
                        else { return }

						self.createInsuranceEvent(insurance: insurance, sosActivity: group.sosActivity, for: group, from: controller, showMode: .push)
                    }
            }
        }
    }

    private func getActiveEvents(
        _ group: InsuranceGroupCategory,
        _ completion: @escaping (Result<[ActiveEventsViewController.EventSection], AlfastrahError>) -> Void
    ) {
        getSosActivityInsurances(group: group) { results in
            switch results {
                case .success(let insurances):
                    self.activeEventReports(of: insurances) { result in
                        switch result {
                            case .success(let sections):
                                completion(.success(sections))
                            case .failure(let error):
                                completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    private func getSosActivityInsurances(
        group: InsuranceGroupCategory,
        completion: @escaping (Result<[Insurance], AlfastrahError>) -> Void
    ) {
        insurancesService.insurance(useCache: true, ids: group.sosActivity?.insuranceIdList ?? [], completion: completion)
    }
    
    private func activeEventReports(
        of insurances: [Insurance],
        completion: @escaping (Result<[ActiveEventsViewController.EventSection], AlfastrahError>) -> Void
    ) {
        let dispatchGroup = DispatchGroup()
        var errors: [AlfastrahError] = []
        var sections: [ActiveEventsViewController.EventSection] = []

        for insurance in insurances {
            dispatchGroup.enter()
            insuranceEventReports(with: insurance) { result in
                dispatchGroup.leave()
                switch result {
                    case .success(let events):
                        let filteredEvents = events.filter {
                            switch $0 {
                                case .auto(let auto):
                                    return auto.isOpened
                                case .passenger:
                                    return true
                                case .accident(let event):
                                    return event.isOpened
                            }
                        }
                        let section = ActiveEventsViewController.EventSection(insurance: insurance, events: filteredEvents)
                        sections.append(section)
                    case .failure(let error):
                        errors.append(error)
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            if let error = errors.first {
                completion(.failure(error))
                return
            }
            completion(.success(sections))
        }
    }

    private func insuranceEventReports(
        with insurance: Insurance,
        completion: @escaping (Result<[EventReportKind], AlfastrahError>) -> Void
    ) {
        switch insurance.insuranceEventKind {
            case .auto:
                if insurance.type == .kasko {
                    eventReportService.kaskoEventReports(insuranceId: insurance.id) {
                        completion(self.groupAutoEventReports($0))
                    }
                } else if insurance.type == .osago {
                    eventReportService.osagoEventReports(insuranceId: insurance.id) {
                        completion(self.groupAutoEventReports($0))
                    }
                } else {
                    completion(.success([]))
                }
			case .doctorAppointment, .passengers, .vzr, .none, .propetry:
                completion(.success([]))
            case .accident:
                eventReportService.accidentEventReports(insuranceId: insurance.id) {
                    completion(self.groupAccidentEventReports($0))
                }
        }
    }

    /// Start flow and create list of insurance event reports
    func eventReportsList() -> InsuranceEventReportsListViewController {
        let viewController: InsuranceEventReportsListViewController = storyboard.instantiate()
        container?.resolve(viewController)

        viewController.input = InsuranceEventReportsListViewController.Input(
            data: { completion in
                guard let insurance = self.insurance else { return }

                self.insuranceEventReports(with: insurance, completion: completion)
            },
            draft: {
                guard let insurance = self.insurance else { return nil }

                switch insurance.insuranceEventKind {
                    case .auto:
                        return self.eventReportService.autoEventDrafts().first { $0.insuranceId == insurance.id }.map(DraftKind.autoDraft)
                    case .passengers:
                        return self.eventReportService.passengersDrafts().first { $0.insuranceId == insurance.id }
                            .map(DraftKind.passengerDraft)
					case .doctorAppointment, .accident, .vzr, .none, .propetry:
                        return nil
                }
            }
        )
        viewController.output = InsuranceEventReportsListViewController.Output(
            selectEvent: { [weak viewController] kind in
                guard let controller = viewController, let insurance = self.insurance else { return }

                switch kind {
                    case .auto:
                        self.analytics.track(event: AnalyticsEvent.Auto.openReportAutoStatusPolicy)
                        self.showEventReport(kind, insurance: insurance, mode: .push)
                    case .passenger:
                        self.analytics.track(event: AnalyticsEvent.Passenger.openReportPassengersStatusPolicy)
                        self.showEventReport(kind, insurance: insurance, mode: .push)
                    case .accident(let event):
                        let accidentFlow = AccidentEventFlow(rootController: controller)
                        self.container?.resolve(accidentFlow)
                        accidentFlow.start(insurance: insurance, flowMode: .show(event), showMode: .push)
                }
            },
            selectDraft: { [weak viewController] draftKind in
                guard let controller = viewController, let insurance = self.insurance else { return }

                switch draftKind {
                    case .passengerDraft(let draft):
                        self.analytics.track(event: AnalyticsEvent.Passenger.reportPassengersOpenDraftPolicy)
                        self.createInsuranceEvent(insurance: insurance, from: controller, showMode: .push, kaskoDraft: nil,
                            passengerDraft: draft)
                    case .autoDraft(let draft):
                        self.analytics.track(event: AnalyticsEvent.Auto.reportAutoOpenDraftPolicy)
                        self.createInsuranceEvent(insurance: insurance, from: controller, showMode: .push, kaskoDraft: draft,
                            passengerDraft: nil)
                }
            },
            deleteDraft: { draftKind in
                switch draftKind {
                    case .passengerDraft(let draft):
                        self.eventReportService.deletePassengerDraft(draft)
                    case .autoDraft(let draft):
                        self.eventReportService.deleteAutoEventDraft(draft)
                }
            }
        )

        eventReportService.subscribeForDraftUpdates(listener: viewController.notify.draftUpdated).disposed(by: viewController.disposeBag)
        return viewController
    }
    
    func createReportOnWebsiteEvent(insuranceId: String, from: ViewController) {
        let hide = from.showLoadingIndicator(message: nil)
        insurancesService.reportOnWebsiteUrl(insuranceID: insuranceId) { result in
            hide(nil)
            switch result {
                case .success(let url):
                    WebViewer.openDocument(
                        url,
                        showShareButton: false,
                        from: from
                    )
                case .failure(let error):
                    ErrorHelper.show(
                        error: error,
                        alertPresenter: self.alertPresenter
                    )
            }
        }
    }
    
    private func startInteractiveSupportOnboarding(
        for insurance: InsuranceShort,
        with onboardingData: [InteractiveSupportData]? = nil,
        from: ViewController,
        showMode: ViewControllerShowMode
    ) {
        func startOnboarding(with onboardingData: [InteractiveSupportData]) {
            guard let onboardingDataForInsurance = onboardingData.first(where: { String($0.insuranceId) == insurance.id })
            else { return }
            
            let interactiveSupportFlow = InteractiveSupportFlow(rootController: from)
            container?.resolve(interactiveSupportFlow)
                    
            interactiveSupportFlow.start(
                for: insurance,
                with: onboardingDataForInsurance,
                flowStartScreenPresentationType: showMode == .modal ? .fromSheet : .fullScreen
            )
        }
        
        // if onboarding was start from section with single dms insurance we need request onboarding data separatly
        if let onboardingData {
            startOnboarding(with: onboardingData)
        } else {
            interactiveSupportService.onboarding(insuranceIds: [insurance.id]) { result in
                switch result {
                    case .success(let data):
                        startOnboarding(with: data)
                    case .failure(let error):
                        ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                }
            }
        }
    }
    
    private func startDoctorAppointment(
        for insurance: Insurance,
        with filterName: String?,
        from: UIViewController,
        showMode: ViewControllerShowMode
    ) {
        let clinicAppointmentFlow = ClinicAppointmentFlow(rootController: from)
        container?.resolve(clinicAppointmentFlow)
        clinicAppointmentFlow.onlineClinicAppointmentFlow = onlineClinicAppointmentFlow
        clinicAppointmentFlow.start(insurance: insurance, selectedFilterName: filterName, mode: showMode)
    }
        
    func createInsuranceEvent(
        insurance: Insurance,
		sosActivity: SosActivityModel? = nil,
        for group: InsuranceGroupCategory? = nil,
        from controller: ViewController,
        showMode: ViewControllerShowMode,
        kaskoDraft: AutoEventDraft? = nil,
        passengerDraft: PassengersEventDraft? = nil,
        onboardingData: [InteractiveSupportData]? = nil,
        filterName: String? = nil
    ) {
        func createPassengersEvent() {
            let passengersCreateFlow = CreatePassengersEventFlow(insurance: insurance)
            container?.resolve(passengersCreateFlow)
            passengersCreateFlow.startModaly(from: controller, draft: passengerDraft)
        }
        
        func createPassengersWebEvent () {
            let hide = controller.showLoadingIndicator(message: nil)
            eventReportService.passengersEventReportUrl(insurance.id) { result in
                hide(nil)
                switch result {
                    case .success(let url):
                        SafariViewController.open(
                            url,
                            from: controller
                        )
                    case .failure(let error):
                        ErrorHelper.show(
                            error: error,
                            alertPresenter: self.alertPresenter
                        )
                }
            }
        }
        
        logger?.debug("")

		if sosActivity?.kind == .life
			|| sosActivity?.kind == .onlinePayment
			|| insurance.sosActivities.contains(.life) {
			fromViewController = controller

			WebViewer.openDocument(
				url: { completion in
					if sosActivity?.kind == .onlinePayment {
						self.insuranceAlfaLifeService.accidentUrl(insuranceId: insurance.id, completion: completion)
					} else {
						self.insuranceAlfaLifeService.questionsAndAnswersUrl(insuranceId: insurance.id, completion: completion)
					}
				},
				openMode: .push,
				showShareButton: true,
				needSharedUrl: true,
				from: controller
			)
		}
        
        switch insurance.insuranceEventKind {
            case .auto:
				switch insurance.type {
					case .osago:
						let hide = controller.showLoadingIndicator(
							message: NSLocalizedString("common_load", comment: "")
						)
						self.backendDrivenService.eventReportOSAGO(insuranceId: insurance.id){ [weak controller] result in
							hide(nil)
							
							guard let viewController = controller
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
					
					default:
						let osagoCreateFlow = CreateAutoEventFlow()
						container?.resolve(osagoCreateFlow)
						osagoCreateFlow.start(with: insurance, from: controller, draft: kaskoDraft)
				}
                
            case .doctorAppointment:
                if let kind = group?.sosActivity?.kind {
                    switch kind {
                        case
                            .passengersInsuranceEvent,
                            .passengersInsuranceWebEvent,
                            .autoInsuranceEvent,
                            .accidentInsuranceEvent,
                            .call,
                            .callback,
                            .voipCall,
                            .onlinePayment,
                            .vzrInsuranceEvent,
                            .onWebsite,
							.life,
                            .unsupported:
                            break
                        case .doctorAppointment:
                            self.startDoctorAppointment(for: insurance, with: filterName, from: controller, showMode: showMode)
                        case .interactiveSupport:
                            guard let shortInsurance = group?.insuranceList.first(where: {
                                $0.id == insurance.id
                            })
                            else { return }
                            
                            self.startInteractiveSupportOnboarding(
                                for: shortInsurance,
                                with: onboardingData,
                                from: controller,
                                showMode: showMode
                            )
                    }
                } else {
                    if let sosActivityType = insurance.sosActivities.first(where: { $0 == .interactiveSupport }),
                       let groupList = insurancesService.cachedShortInsurances(forced: true)?.insuranceGroupList {
                        let shortInsurances = groupList
                            .flatMap { $0.insuranceGroupCategoryList }
                            .flatMap { $0.insuranceList }
                            .filter { $0.id == insurance.id }
                        
                        if let shortInsurance = shortInsurances.first {
                            self.startInteractiveSupportOnboarding(
                                for: shortInsurance,
                                with: onboardingData,
                                from: controller,
                                showMode: showMode
                            )
                        }
                    } else {
                        self.startDoctorAppointment(for: insurance, with: filterName, from: controller, showMode: showMode)
                    }
                }
                
            case .passengers:
                if let kind = group?.sosActivity?.kind {
                    switch kind {
                        case .passengersInsuranceEvent:
                            createPassengersEvent()
                        case .passengersInsuranceWebEvent:
                            createPassengersWebEvent()
                        case
                            .autoInsuranceEvent,
                            .doctorAppointment,
                            .accidentInsuranceEvent,
                            .call,
                            .callback,
                            .voipCall,
                            .onlinePayment,
                            .vzrInsuranceEvent,
                            .interactiveSupport,
                            .onWebsite,
							.life,
                            .unsupported:
                            break
                    }
                } else {
                    let sosActivities = insurance.sosActivities
                    if sosActivities.contains(.reportPassengersInsuranceEvent) {
                        createPassengersEvent()
                    } else if sosActivities.contains(.reportPassengersInsuranceWebEvent) {
                        createPassengersWebEvent()
                    }
                }
                
            case .vzr:
                let hide = controller.showLoadingIndicator(message: nil)
                eventReportService.vzrEventReportDeeplink(insurance.id) { result in
                    hide {}
                    switch result {
                        case .success(let url):
                            SafariViewController.open(url, from: controller)
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                }
                
            case .accident:
                let accidentFlow = AccidentEventFlow(rootController: controller)
                container?.resolve(accidentFlow)
                accidentFlow.start(insurance: insurance, flowMode: .createNewEvent, showMode: showMode)
            
            case .propetry:
                if insurance.sosActivities.contains(.reportOnWebsite) {
                    createReportOnWebsiteEvent(insuranceId: insurance.id, from: controller)
                }

            case .none:
                break
                
        }
    }

    func startWithEventReport(reportId: EventReportId, insurance: Insurance) {
        let fromVC = (fromViewController as? ViewController)
        let hide = fromVC?.showLoadingIndicator(message: nil)
        switch reportId {
            case .passengers(let id):
                eventReportService.passengersEventReport(reportId: id) { result in
                    hide? {}
                    switch result {
                        case .success(let report):
                            self.showEventReport(.passenger(report), insurance: insurance, mode: .modal)
                        case .failure(let error):
                            fromVC.map { $0.processError(error) }
                    }
                }
            case .osago, .kasko:
                eventReportService.autoEventReport(reportId: reportId) { result in
                    hide? {}
                    switch result {
                        case .success(let report):
                            self.showEventReport(.auto(report), insurance: insurance, mode: .modal)
                        case .failure(let error):
                            fromVC.map { $0.processError(error) }
                    }
                }
        }
    }

    private func showEventReport(_ event: EventReportKind, insurance: Insurance, mode: ViewControllerShowMode) {
        let viewController: InsuranceEventReportViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = InsuranceEventReportViewController.Input(
            eventReport: event,
            insurance: insurance
        )

        // swiftlint:disable:next trailing_closure
        viewController.output = InsuranceEventReportViewController.Output(
            routeTap: routeTap,
            phoneTap: phoneTap,
            decisionTap: { [weak viewController] url in
                guard self.accountService.isAuthorized
                else { return }
                
                guard let viewController = viewController
                else { return }
                
                guard !self.accountService.isDemo
                else {
					DemoBottomSheet.presentInfoDemoSheet(from: viewController)
                    return
                }
                
                self.linkTap(url)
            },
			showChat: { [weak viewController] in
				guard let viewController
				else { return }
				
				if self.accountService.isDemo
				{
					DemoBottomSheet.presentInfoDemoSheet(from: viewController)
				}
				else
				{
					self.showChat()
				}
			},
            addPhoto: { [weak viewController] in
                guard let controller = viewController 
				else { return }

                self.addPhoto(forEvent: event, from: controller)
            },
			onOpenWeb: { [weak viewController] in
				guard let viewController
				else { return }
				
				WebViewer.openDocument(
					$0,
					urlShareable: $0,
					from: viewController
				)
			}
        )

        if mode == .modal, let fromVC = fromViewController ?? navigationController {
            viewController.addCloseButton { [weak viewController] in
                viewController?.dismiss(animated: true, completion: nil)
            }
            let navigationController = RMRNavigationController()
            navigationController.strongDelegate = RMRNavigationControllerDelegate()
            navigationController.viewControllers = [ viewController ]
            self.navigationController = navigationController
            fromVC.present(navigationController, animated: true, completion: nil)
        } else {
            if let navController = navigationController {
                navController.pushViewController(viewController, animated: true)
            } else if let navController = fromViewController?.navigationController {
                navController.pushViewController(viewController, animated: true)
            }
        }

    }

    // MARK: - Add Photo to auto event

    private lazy var photoSelectionBehavior = DocumentPickerBehavior()

    private func addPhoto(forEvent event: EventReportKind, from: UIViewController) {
        guard accountService.isAuthorized
        else { return }
        
        let navController = navigationController ?? fromViewController?.navigationController
        
        guard let controller = navController?.topViewController as? ViewController
        else { return }
        
        guard !accountService.isDemo
        else {
			DemoBottomSheet.presentInfoDemoSheet(from: controller)
            return
        }

        self.photoSelectionBehavior.pickDocuments(
            from,
            attachmentService: self.attachmentService,
            sources: [ .camera ],
            maxDocuments: 5,
            cameraHint: nil
        ) { [weak self] attachments in
            guard let self = self
            else { return }

            let autoEventAttachments = attachments.map {
                AutoEventAttachment(
                    id: UUID().uuidString,
                    eventReportId: event.eventId,
                    filename: $0.filename,
                    fileType: .documents,
                    isOptional: true
                )
            }
            self.attachmentService.addToUploadQueue(attachments: autoEventAttachments)
            self.showAttachmentsUpload(event: event)
        }
    }

    private func showAttachmentsUpload(event: EventReportKind) {
        let viewController: AttachmentUploadViewController = UIStoryboard(name: "CreateAutoEvent", bundle: nil).instantiate()
        container?.resolve(viewController)
        let navController = navigationController ?? fromViewController?.navigationController
        viewController.input = .init(
            eventReportId: event.eventId,
            text: NSLocalizedString("photos_upload_tip", comment: ""),
            presentationMode: .push
        )
        viewController.output = .init(
            close: {
                ApplicationFlow.shared.show(item: .tabBar(.home))
            },
            doneAction: {
                navController?.popViewController(animated: true)
            }
        )
        navController?.pushViewController(viewController, animated: true)
    }

    // MARK: - Data

    private func groupAutoEventReports(
        _ result: Result<[EventReportAuto], AlfastrahError>
    ) -> Result<[EventReportKind], AlfastrahError> {
        result.map { reports in
            reports.sorted { $0.displayDate > $1.displayDate }.map(EventReportKind.auto)
        }
    }

    private func groupPassengersEventReports(
        _ result: Result<[EventReport], AlfastrahError>
    ) -> Result<[EventReportKind], AlfastrahError> {
        result.map { reports in
            reports.map(EventReportKind.passenger)
        }
    }

    private func groupAccidentEventReports(
        _ result: Result<[EventReportAccident], AlfastrahError>
    ) -> Result<[EventReportKind], AlfastrahError> {
        result.map { reports in
            reports.map(EventReportKind.accident)
        }
    }
    
    // MARK: - Helpers

    private func linkTap(_ url: URL) {
        guard let navigationController = navigationController else { return }
        
        SafariViewController.open(url, from: navigationController)
    }

    private func routeTap(_ coordinate: CLLocationCoordinate2D, title: String?) {
        CoordinateHandler.handleCoordinate(coordinate, title: title)
    }

    private func phoneTap(_ phone: Phone) {
        PhoneHelper.handlePhone(plain: phone.plain, humanReadable: phone.humanReadable)
    }

    private func showChat() {
        ApplicationFlow.shared.show(item: .tabBar(.chat))
    }
}
