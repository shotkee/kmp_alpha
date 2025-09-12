//
//  SosFlow
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 15/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

// swiftlint:disable file_length
class SosFlow: DependencyContainerDependency,
               InsurancesServiceDependency,
               AccountServiceDependency,
               AlertPresenterDependency,
               GeolocationServiceDependency,
               PhoneCallsServiceDependency,
               LoggerDependency,
               AnalyticsServiceDependency,
               EventReportServiceDependency,
               VoipServiceDependency {
    var container: DependencyInjectionContainer?
    var alertPresenter: AlertPresenter!
    var insurancesService: InsurancesService!
    var geoLocationService: GeoLocationService!
    var accountService: AccountService!
    var phoneCallsService: PhoneCallsService!
    var eventReportService: EventReportService!
    var applicationFlow: ApplicationFlow = ApplicationFlow.shared
    var logger: TaggedLogger?
    var analytics: AnalyticsService!
    var voipService: VoipService!

    private weak var initialViewController: UINavigationController!

    deinit {
        logger?.debug("")
    }

    private let storyboard: UIStoryboard = UIStoryboard(name: "Sos", bundle: nil)

    func start() -> UINavigationController {
        let navigationController = RMRNavigationController()
        navigationController.strongDelegate = RMRNavigationControllerDelegate()
        initialViewController = navigationController
        initialViewController.setViewControllers([ createSosController() ], animated: false)
        return initialViewController
    }

    private func createSosController() -> SosViewController {
        let viewController: SosViewController = SosViewController()
        container?.resolve(viewController)
        viewController.addBackButton { [weak viewController, weak self] in
            viewController?.dismiss(animated: true, completion: nil)
            self?.insurancesService.cancelEmergencyHelp()
        }
        viewController.input = .init(
			isAuthorized: { self.accountService.isAuthorized }, 
			isDemo: { self.accountService.isDemo },
            anonymousSos: insurancesService.cachedAnonymousSos(),
            data: insuranceMain
        )
        viewController.output = .init(
            select: { [weak self] sosModel in
                guard let self = self
                else { return }
                
                switch sosModel.kind {
                    case .unsupported:
                        break
                    case .category:
                        switch sosModel.insuranceCategory?.type {
                            case .auto?:
                                self.analytics.track(event: AnalyticsEvent.SOS.sosAuto)
                            case .health?:
                                self.analytics.track(event: AnalyticsEvent.SOS.sosHealth)
                            case .property?:
                                self.analytics.track(event: AnalyticsEvent.SOS.sosProperty)
                            case .travel?:
                                self.analytics.track(event: AnalyticsEvent.SOS.sosTrip)
                            case .passengers?:
                                self.analytics.track(event: AnalyticsEvent.SOS.sosPassengers)
                            case .life?, .unsupported, nil:
                                break
                        }
                    
                        if sosModel.insuranceCategory?.type == .health,
                           self.accountService.isAuthorized,
                           sosModel.isHealthFlow {
                            viewController.notify.updateWithState(.loading)
                            self.getEmergencyHelp(
                                viewController: viewController,
                                sosModel: sosModel
                            )
                        }
                        else {
                            viewController.notify.updateViewUserInteractionEnabled()
							
							if sosModel.insuranceCategory?.type == .auto
							{
								let hide = viewController.showLoadingIndicator(
									message: NSLocalizedString("common_load", comment: "")
								)
								
								self.insurancesService.checkOsagoBlock(
									completion:
								{
									result in
									
									hide(nil)
									switch result
									{
										case .success(let checkOsagoBlock):
											self.showSosActivitiesController(
												for: sosModel,
												checkOsagoBlock: checkOsagoBlock
											)
										
										case .failure:
											self.showSosActivitiesController(
												for: sosModel
											)
									}
								})
							}
							else
							{
								self.showSosActivitiesController(for: sosModel)
							}
                        }
                    case .phone:
                        guard let phone = sosModel.sosPhone else { return }

                        self.phoneTap(phone)
                }
			}, 
			demo:
			{
				[weak viewController] in
				
				guard let viewController
				else { return }
				
				DemoBottomSheet.presentInfoDemoSheet(from: viewController)
			},
			addOrEditConfidant:
			{
				[weak viewController] confidant in
				
				guard let viewController = viewController
				else { return }
				
				let mode: ConfidantViewController.Mode
				
				if let confidant = confidant 
				{
					mode = .saveChanges(confidant)
				}
				else 
				{
					mode = .save
				}
				
				self.showConfidantViewController(
					viewController: viewController,
					mode: mode
				)
					
			},
            callPhone: { [weak viewController] titlePopup, phoneNumber in
                
                guard let viewController = viewController
                else { return }
                
                self.showCallNumberActionSheet(
                    titlePopup: titlePopup,
                    phoneNumber: phoneNumber,
                    viewController: viewController
                )
            }
        )
        return viewController
    }
    
    private func definingTransition(
        viewController: ViewController,
        insureds: [SosInsured]
    ) {
        if insureds.count > 1 {
            showSosHealthViewController(sosInsured: insureds)
        } else if let insured = insureds.first,
                insured.insuranceTypes.count > 1 {
            showSosHealthViewController(
                insurancesType: insured.insuranceTypes
            )
        } else if let insured = insureds.first,
                  let insuranceType = insured.insuranceTypes.first {
            
            let phonesIsEmpty = insuranceType.phones.isEmpty
            let voipCallsIsEmpty = insuranceType.voipCalls.isEmpty
                 
            if !phonesIsEmpty && !voipCallsIsEmpty {
                self.showSosHealthViewController(
                    phones: insuranceType.phones,
                    voipCalls: insuranceType.voipCalls
                )
            } else if !phonesIsEmpty {
                showCallNumberActionSheet(
                    phones: insuranceType.phones,
                    viewController: viewController
                )
            }
        }
    }
    
    private func showSosHealthViewController(
        sosInsured: [SosInsured]
    ) {
        let viewController = SosHealthViewController()
        viewController.input = .init(
            scenario: .insured(sosInsured)
        )
        
        let closeButton = ActionBarButtonItem(
            image: UIImage(named: "icon-close"),
            style: .plain,
            target: nil,
            action: nil
        )
        
        closeButton.actionClosure = { [weak viewController] in
            guard let viewController = viewController
            else { return }
            
            ApplicationFlow.shared.show(item: .tabBar(.home))
        }
        
        viewController.addBackButton {
            self.initialViewController.popViewController(animated: false)
        }
        
        viewController.navigationItem.rightBarButtonItem = closeButton
        
        viewController.output = .init(
            showInsurancesType: { [weak self] insurancesType in
                self?.showSosHealthViewController(
                    insurancesType: insurancesType
                )
            },
            showTypeConnection: { [weak self] phones, voipCalls in
                self?.showSosHealthViewController(
                    phones: phones,
                    voipCalls: voipCalls
                )
            },
            showAlertCall: { [weak viewController] phones in
                guard let viewController = viewController,
                      !phones.isEmpty
                else { return }
                
                self.showCallNumberActionSheet(
                    phones: phones,
                    viewController: viewController
                )
            },
            showAlerVoipCall: { [weak viewController] voipCalls in }
        )
        
        initialViewController.pushViewController(
            viewController,
            animated: false
        )
    }
    
    private func showSosHealthViewController(
        insurancesType: [InsuranceType]
    ) {
        let viewController = SosHealthViewController()
        
        viewController.input = .init(
            scenario: .typeInsurance(insurancesType)
        )
        
        let closeButton = ActionBarButtonItem(
            image: UIImage(named: "icon-close"),
            style: .plain,
            target: nil,
            action: nil
        )
        
        closeButton.actionClosure = { [weak viewController] in
            guard let viewController = viewController
            else { return }
            
            ApplicationFlow.shared.show(item: .tabBar(.home))
        }
        
        viewController.navigationItem.rightBarButtonItem = closeButton
        
        viewController.addBackButton {
            self.initialViewController.popViewController(animated: false)
        }
        
        viewController.output = .init(
            showInsurancesType: nil,
            showTypeConnection: { phones, voipCalls in
                self.showSosHealthViewController(
                    phones: phones,
                    voipCalls: voipCalls
                )
            },
            showAlertCall: { [weak viewController] phones in
                guard let viewController = viewController,
                      !phones.isEmpty
                else { return }
                
                self.showCallNumberActionSheet(
                    phones: phones,
                    viewController: viewController
                )
            },
            showAlerVoipCall: {  [weak viewController] voipCalls in }
        )
        
        initialViewController.pushViewController(
            viewController,
            animated: false
        )
    }
    
    private func showSosHealthViewController(
        phones: [Phone],
        voipCalls: [VoipCall]
    ) {
        let viewController = SosHealthViewController()
        viewController.input = .init(
            scenario: .typeConnection(phones, voipCalls)
        )
        
        let closeButton = ActionBarButtonItem(
            image: UIImage(named: "icon-close"),
            style: .plain,
            target: nil,
            action: nil
        )
        
        closeButton.actionClosure = { [weak viewController] in
            guard let viewController = viewController
            else { return }
            
            ApplicationFlow.shared.show(item: .tabBar(.home))
        }
        
        viewController.navigationItem.rightBarButtonItem = closeButton
        
        viewController.addBackButton {
            self.initialViewController.popViewController(animated: false)
        }
        
        viewController.output = .init(
            showInsurancesType: nil,
            showTypeConnection: nil,
            showAlertCall: { [weak viewController] phones in
                guard let viewController,
                      !phones.isEmpty
                else { return }
                
                self.showCallNumberActionSheet(
                    phones: phones,
                    viewController: viewController
                )
            },
            showAlerVoipCall: { [weak viewController] voipCalls in
                guard let viewController,
                      !voipCalls.isEmpty
                else { return }
                
                self.showVoipCallNumberActionSheet(voipCalls: voipCalls, viewController: viewController)
            }
        )
        
        initialViewController.pushViewController(
            viewController,
            animated: false
        )
    }
    
    private func showVoipCallNumberActionSheet(
        voipCalls: [VoipCall],
        viewController: ViewController
    ) {
        let actionSheet = UIAlertController(
            title: NSLocalizedString("sos_action_sheet_voip_calls_title", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        var actions: [UIAlertAction] = []
        
        voipCalls.forEach { voipCall in
            actions.append(
                createAlertAction(for: voipCall)
            )
        }
        
        let cancel = UIAlertAction(
            title: NSLocalizedString(
                "common_cancel_button",
                comment: ""
            ),
            style: .cancel,
            handler: nil
        )
        
        actions.forEach { action in
            actionSheet.addAction(action)
        }
        actionSheet.addAction(cancel)
        
        viewController.present(
            actionSheet,
            animated: true
        )
    }
    
    private func showCallNumberActionSheet(
        phones: [Phone],
        viewController: ViewController
    ) {
        let actionSheet = UIAlertController(
            title: NSLocalizedString("sos_action_sheet_title", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        var actions: [UIAlertAction] = []
        
        phones.forEach { phone in
            actions.append(
                createAlertAction(
                    title: phone.humanReadable,
                    phoneNumber: phone.plain
                )
            )
        }
        
        let cancel = UIAlertAction(
            title: NSLocalizedString(
                "common_cancel_button",
                comment: ""
            ),
            style: .cancel,
            handler: nil
        )
        
        actions.forEach { action in
            actionSheet.addAction(action)
        }
        actionSheet.addAction(cancel)
        
        viewController.present(
            actionSheet,
            animated: true
        )
    }
    
    private func createAlertAction(title: String, phoneNumber: String) -> UIAlertAction {
        let alertAction = UIAlertAction(
            title: title,
            style: .default
        ) { [weak self] _ in
            
            guard let url = URL(string: "telprompt://" + phoneNumber)
            else { return }

            UIApplication.shared.open(url, completionHandler: nil)
        }
        
        return alertAction
    }
    
    private func createAlertAction(for voipCall: VoipCall) -> UIAlertAction {
        let alertAction = UIAlertAction(
            title: voipCall.title,
            style: .default
        ) { _ in
            self.voipCall(voipCall)
        }
        
        return alertAction
    }
    
    private func showCallNumberActionSheet(
        titlePopup: String,
        phoneNumber: String,
        viewController: ViewController
    ) {
        let actionSheet = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let callNumberAction = UIAlertAction(
            title: titlePopup,
            style: .default
        ) { [weak self] _ in
            
            guard let url = URL(string: "telprompt://" + phoneNumber)
            else { return }

            UIApplication.shared.open(url, completionHandler: nil)
        }
        
        let cancel = UIAlertAction(
            title: NSLocalizedString(
                "common_cancel_button",
                comment: ""
            ),
            style: .cancel,
            handler: nil
        )
        actionSheet.addAction(callNumberAction)
        actionSheet.addAction(cancel)
        
        viewController.present(
            actionSheet,
            animated: true
        )
    }

    private func showSosActivitiesController(
		for sosModel: SosModel,
		checkOsagoBlock: CheckOsagoBlock? = nil
	) {
        let viewController: SosActivitiesViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(
			isDemoMode: self.accountService.isDemo,
            isAuthorized: { self.accountService.isAuthorized },
            sosModel: sosModel,
			checkOsagoBlock: checkOsagoBlock
        )
        viewController.output = .init(
			demo: { [weak viewController] in
				guard let viewController
				else { return }
				
				DemoBottomSheet.presentInfoDemoSheet(from: viewController)
			},
			chat: { [weak viewController] in
				
				guard let viewController
				else { return }
				
				if self.accountService.isDemo
				{
					DemoBottomSheet.presentInfoDemoSheet(from: viewController)
				}
				else
				{
					self.applicationFlow.show(item: .tabBar(.chat))
				}
			},
            instructions: { self.showSosInstructions(sosModel.instructionList) },
            sosActivity: { sosActivity in
				if self.accountService.isDemo
				{
					DemoBottomSheet.presentInfoDemoSheet(from: viewController)
				}
				else if let category = sosModel.insuranceCategory
				{
					self.sosActivityTap(sosActivity, categoryKind: category.type)
				}
            },
			checkRSABottomSheet:
			{
				[weak viewController] checkOsagoBlock in
				
				guard let viewController
				else { return }
				
				CheckRSABottomSheet.showCheckRSABottomSheet(
					from: viewController,
					checkOsagoBlock: checkOsagoBlock,
					openUrl:
					{
						[weak viewController] urlName in
						
						guard let viewController
						else { return }
						
						if let url = URL(string: urlName)
						{
							WebViewer.openDocument(
								url,
								needSharedUrl: true,
								from: viewController
							)
						}
					}
				)
			}
        )
        initialViewController.pushViewController(viewController, animated: true)
    }

    private func showSosPhoneList(for sosActivity: SosActivityModel, categoryKind: InsuranceCategoryMain.CategoryType,
            voipCall: Bool, completion: @escaping (SosPhone) -> Void) {
        let viewController: SosPhoneListViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(
            categoryKind: categoryKind,
            sosActivity: sosActivity,
            voipCall: voipCall
        )
        viewController.output = .init(phone: completion)
        initialViewController.pushViewController(viewController, animated: true)
    }

    private func showCallbackController(
        for insurance: InsuranceShort,
        categoryKind: InsuranceCategoryMain.CategoryType
    ) {
        guard accountService.isAuthorized
        else { return }
        
        let hide = initialViewController.showLoadingIndicator(
            message: NSLocalizedString("common_loading_title",
            comment: "")
        )

        accountService.getAccount(useCache: true) { result in
            hide(nil)

            switch result {
                case .success(let userAccount):
                    let viewController: SosCallBackViewController = self.storyboard.instantiate()
                    self.container?.resolve(viewController)
                    viewController.input = .init(
                        insurance: insurance,
                        userPhone: userAccount.phone,
                        selectedPosition: {
                            LocationInfo(
                                position: self.selectedPosition,
                                address: self.selectedAddress,
                                place: nil
                            )
                        }
                    )
                    viewController.output = .init(
                        pickLocation: { [weak viewController] in
                            guard let controller = viewController else { return }

                            self.showLocationPicker(from: controller)
                        },
                        callback: { [weak viewController] callback in
                            guard let viewController = viewController
                            else { return }

                            let hide = viewController.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
                            self.phoneCallsService.requestCallback(callback) { [weak self] result in
                                guard let self = self else { return }

                                hide(nil)
                                switch result {
                                    case .success(let callbackResponse):
                                        if callbackResponse.success {
                                            switch categoryKind {
                                                case .auto:
                                                    self.analytics.track(event: AnalyticsEvent.SOS.sosAutoCallbackDone)
                                                case .property:
                                                    self.analytics.track(event: AnalyticsEvent.SOS.sosPropertyCallbackDone)
                                                case .travel:
                                                    self.analytics.track(event: AnalyticsEvent.SOS.sosTripCallbackDone)
                                                case .passengers:
                                                    self.analytics.track(event: AnalyticsEvent.SOS.sosPassengersCallbackDone)
                                                case .health, .life, .unsupported:
                                                    break
                                            }

                                            self.initialViewController.dismiss(animated: true, completion: nil)
                                            self.alertPresenter.show(alert: InfoNotificationAlert(text: callbackResponse.message))
                                        } else {
                                            self.alertPresenter.show(alert:
                                                ErrorNotificationAlert(
                                                    error: nil,
                                                    text: callbackResponse.message,
                                                    combined: false,
                                                    action: nil
                                                )
                                            )
                                        }
                                    case .failure(let error):
                                        viewController.processError(error)
                                }
                            }
                        }
                    )
                    self.setupLocationServices()
                    self.locationUpdatedSubscriptions.add(viewController.notify.locationUpdated).disposed(by: viewController.disposeBag)
                    self.initialViewController.pushViewController(viewController, animated: true)
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }
    
    private func createAndShowBuyInsuranceAlert(from: ViewController) {
        let alert = UIAlertController(
            title: NSLocalizedString("sos_buy_insurance_alert_title", comment: ""),
            message: NSLocalizedString("sos_buy_insurance_alert_description", comment: ""),
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: NSLocalizedString("sos_buy_insurance_alert_cancel", comment: ""), style: .cancel)

        let buyAction =
        UIAlertAction(title: NSLocalizedString("sos_buy_insurance_alert_buy", comment: ""), style: .default) { [weak self] _ in
            self?.showBuyInsurance()
        }

        alert.addAction(buyAction)
        alert.addAction(cancelAction)

        from.present(alert, animated: true)
    }

    // swiftlint:disable:next function_body_length
    private func sosActivityTap(
        _ sosActivity: SosActivityModel,
        categoryKind: InsuranceCategoryMain.CategoryType
    ) {
        switch sosActivity.kind {
            case .unsupported:
                break
            case .call:
                let event: String?
                switch categoryKind {
                    case .auto:
                        event = AnalyticsEvent.SOS.sosAutoCall
                    case .health:
                        event = AnalyticsEvent.SOS.sosHealthCall
                    case .property:
                        event = AnalyticsEvent.SOS.sosPropertyCall
                    case .travel:
                        event = AnalyticsEvent.SOS.sosTripCall
                    case .passengers:
                        event = AnalyticsEvent.SOS.sosPassengersCall
                    case .life, .unsupported:
                        event = nil
                }

                if let phone = sosActivity.sosPhoneList.first, sosActivity.sosPhoneList.count == 1 {
                    if let event = event {
                        analytics.track(
                            event: event,
                            properties: [
                                AnalyticsParam.SOS.phoneNumber: phone.phone,
                                AnalyticsParam.SOS.succeed: AnalyticsParam.string(true)
                            ]
                        )
                    }
                    phoneTap(phone)
                } else if !sosActivity.sosPhoneList.isEmpty {
                    if let event = event {
                        analytics.track(event: event, properties: [ AnalyticsParam.SOS.succeed: AnalyticsParam.string(true) ])
                    }
                    showSosPhoneList(for: sosActivity, categoryKind: categoryKind, voipCall: false) { phone in
                        let event: String?
                        switch categoryKind {
                            case .auto:
                                event = AnalyticsEvent.SOS.sosAutoCallChoose
                            case .health:
                                event = AnalyticsEvent.SOS.sosHealthCallChoose
                            case .property:
                                event = AnalyticsEvent.SOS.sosPropertyCallChoose
                            case .travel:
                                event = AnalyticsEvent.SOS.sosTripCallChoose
                            case .passengers:
                                event = AnalyticsEvent.SOS.sosPassengersCallChoose
                            case .life, .unsupported:
                                event = nil
                        }

                        if let event = event {
                            self.analytics.track(event: event, properties: [ AnalyticsParam.SOS.phoneNumber: phone.phone ])
                        }
                        self.phoneTap(phone)
                    }
                } else {
                    if let event = event {
                        analytics.track(event: event, properties: [ AnalyticsParam.SOS.succeed: AnalyticsParam.string(false) ])
                    }
                    showBuyInsurance()
                }
            case .callback:
                guard let fromViewController = initialViewController.topViewController as? ViewController
                else { return }

                let event: String?
                switch categoryKind {
                    case .auto:
                        event = AnalyticsEvent.SOS.sosAutoCallbackOpen
                    case .property:
                        event = AnalyticsEvent.SOS.sosPropertyCallbackOpen
                    case .travel:
                        event = AnalyticsEvent.SOS.sosTripCallbackOpen
                    case .passengers:
                        event = AnalyticsEvent.SOS.sosPassengersCallbackOpen
                    case .health, .life, .unsupported:
                        event = nil
                }
                if !sosActivity.insuranceIdList.isEmpty {
                    if let event = event {
                        analytics.track(event: event, properties: [ AnalyticsParam.SOS.succeed: AnalyticsParam.string(true) ])
                    }
                    let flow = InsurancesFlow()
                    container?.resolve(flow)
                    flow.selectInsurance(
                        ids: sosActivity.insuranceIdList.compactMap { String($0) },
                        from: fromViewController,
                        showMode: .push
                    ) { [weak self] insurance, _, _ in
                        self?.showCallbackController(for: insurance, categoryKind: categoryKind)
                    }
                } else {
                    if let event = event {
                        analytics.track(event: event, properties: [ AnalyticsParam.SOS.succeed: AnalyticsParam.string(false) ])
                    }
                    showBuyInsurance()
                }
                
            case
                .autoInsuranceEvent,
                .doctorAppointment,
                .passengersInsuranceEvent,
                .passengersInsuranceWebEvent,
                .vzrInsuranceEvent,
                .accidentInsuranceEvent,
                .onWebsite,
				.onlinePayment,
				.life,
                .interactiveSupport:

                guard let fromViewController = initialViewController.topViewController as? ViewController
                else { return }

				if sosActivity.insuranceIdList.isEmpty {
                    switch sosActivity.kind {
                        case
                            .passengersInsuranceEvent,
                            .passengersInsuranceWebEvent:
                            
                            showBuyPassengersInsurance()
							return
                        case
                            .unsupported,
                            .call,
                            .callback,
                            .autoInsuranceEvent,
                            .doctorAppointment,
                            .voipCall,
                            .vzrInsuranceEvent,
                            .accidentInsuranceEvent,
                            .onWebsite,
							.life,
                            .interactiveSupport:
                            
                            createAndShowBuyInsuranceAlert(from: fromViewController)
							return
						case .onlinePayment:
							break
                    }
                }


                switch sosActivity.kind {
                    case .autoInsuranceEvent:
                        analytics.track(event: AnalyticsEvent.Auto.reportAutoSOS)
                    case .doctorAppointment:
                        analytics.track(event: AnalyticsEvent.Clinic.appointmentSOS)
                    case .passengersInsuranceEvent,
                            .passengersInsuranceWebEvent:
                        analytics.track(event: AnalyticsEvent.Passenger.reportPassengersSOS)
                    case .vzrInsuranceEvent:
                        analytics.track(event: AnalyticsEvent.Vzr.reportVzrSOS)
                    case
                        .call,
                        .callback,
                        .onlinePayment,
                        .voipCall,
                        .accidentInsuranceEvent,
                        .interactiveSupport,
                        .onWebsite,
						.life,
                        .unsupported:
                        break
                }

                let flow = InsurancesFlow()
                container?.resolve(flow)
                flow.eventInsurance(
                    from: fromViewController,
					sosActivity: sosActivity,
                    showMode: .push,
                    ids: sosActivity.insuranceIdList.compactMap { String($0) }
                )
            case .voipCall:
                let phoneList = sosActivity.sosPhoneList.filter { $0.voipCall != nil }

                if let voipCall = phoneList.first?.voipCall, phoneList.count == 1 {
                    if case .travel = categoryKind {
                        self.analytics.track(
                            event: AnalyticsEvent.SOS.sosTripInternetCall,
                            properties: [ AnalyticsParam.SOS.succeed: AnalyticsParam.string(true) ]
                        )
                    }
                    self.voipCall(voipCall)
                } else if !phoneList.isEmpty {

                    showSosPhoneList(for: sosActivity, categoryKind: categoryKind, voipCall: true) { [weak self] sosPhone in
                        guard let self,
                              let voipCall = sosPhone.voipCall
                        else { return }

                        if case .travel = categoryKind {
                            self.analytics.track(
                                event: AnalyticsEvent.SOS.sosTripInternetCall,
                                properties: [ AnalyticsParam.SOS.succeed: AnalyticsParam.string(true) ]
                            )
                        }
                        self.voipCall(voipCall)
                    }
                } else {
                    if case .travel = categoryKind {
                        self.analytics.track(
                            event: AnalyticsEvent.SOS.sosTripInternetCall,
                            properties: [ AnalyticsParam.SOS.succeed: AnalyticsParam.string(false) ]
                        )
                    }
                    showBuyInsurance()
                }
        }
    }

    private func showSosInstructions(_ instructions: [Instruction]) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Instruction", bundle: nil)
        let viewController: InstructionListViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(instructions: instructions)
        viewController.output = .init(
            details: showDetails
        )
        initialViewController.pushViewController(viewController, animated: true)
    }

    private func showDetails(instruction: Instruction) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Instruction", bundle: nil)
        let viewController: InstructionViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(
            instruction: instruction
        )
        initialViewController.pushViewController(viewController, animated: true)
    }

    private func showLocationPicker(from controller: UIViewController) {
        let viewController = LocationPickerViewController()
        container?.resolve(viewController)
        viewController.addCloseButton { [weak viewController] in
            viewController?.dismiss(animated: true, completion: nil)
        }
        viewController.input = .init(
            point: selectedPosition
        )
        viewController.output = .init(
            selectedPoint: { [weak viewController] point in
                self.selectedPosition = point
                self.reverseGeocodeSelectedPosition()
                viewController?.dismiss(animated: true, completion: nil)
            },
            requestAvailability: { self.geoLocationService.requestAvailability(always: false) }
        )
        let navigationController = RMRNavigationController(rootViewController: viewController)
        navigationController.strongDelegate = RMRNavigationControllerDelegate()
        controller.present(navigationController, animated: true, completion: nil)
    }
    
    private func voipCall(_ voipCall: VoipCall) {
        guard let topViewController = initialViewController.topViewController as? ViewController,
              voipService.availability != .pendingDisconnect
        else { return }
        
        voipService.microphonePermission { result in
            switch result {
                case .success:
                    self.showVoipCall(with: voipCall)
                case .failure(let error):
                    UIHelper.showMicrophoneRequiredAlert(from: topViewController)
            }
        }
    }
    
    private func showVoipCall(with voipCall: VoipCall) {
        let viewController: VoipCallViewController = storyboard.instantiate()
        container?.resolve(viewController)
        
        viewController.output = .init(
            close: {
                self.initialViewController.popViewController(animated: true)
            },
            sendPhoneNumberDigit: { digit in
                self.voipService.send(digit: digit)
            },
            endCall: { [weak viewController] in
                self.voipService.endCall()
                viewController?.notify.updateState(.disconnected)
            },
            muteCall: { mute in
                self.voipService.muteCall(mute)
            },
            startCall: {
                self.voipService.call(voipCall)
            }
        )
        
        voipService.subscribeForAvailability { [weak viewController] voipServiceAvailability in
            guard let viewController
            else { return }
            
            switch voipServiceAvailability {
                case .connected:
                    viewController.notify.updateState(.connected)
                case .disconnected, .pendingDisconnect:
                    viewController.notify.updateState(.disconnected)
                case .speaking:
                    viewController.notify.updateState(.speaking)
            }
        }.disposed(by: viewController.disposeBag)
        
        initialViewController.pushViewController(viewController, animated: true)
    }

    private func showBuyInsurance() {
        guard let controller = initialViewController.topViewController as? ViewController else { return }

        let flow = InsurancesBuyFlow()
        self.container?.resolve(flow)
        flow.start(from: controller)
    }
    
    private func showBuyPassengersInsurance () {
        guard let controller = initialViewController.topViewController as? ViewController
        else { return }
        
        let hide = controller.showLoadingIndicator(message: nil)
        eventReportService.passengersEventReportUrl(nil) { result in
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
    
    // MARK: - GeoLocation

    private var locationUpdatedSubscriptions: Subscriptions<Void> = Subscriptions()
    private var geoLocationAvailabilitySubscription: Subscription?
    private var geoLocationSubscription: Subscription?
    private lazy var selectedPosition: Coordinate = self.geoLocationService.defaultLocation
    private var selectedAddress: String?

    /// Sets up GeoLocationService subscriptions.
    private func setupLocationServices() {
        geoLocationService.requestAvailability(always: false)

        geoLocationAvailabilitySubscription = geoLocationService.subscribeForAvailability { [weak self] availability in
            guard let `self` = self else { return }

            switch availability {
                case .allowedAlways, .allowedWhenInUse:
                    break
                case .denied, .notDetermined:
                    let controller = UIHelper.findTopModal(controller: self.initialViewController)
                    UIHelper.showLocationRequiredAlert(from: controller, locationServicesEnabled: true)
                case .restricted:
                    let controller = UIHelper.findTopModal(controller: self.initialViewController)
                    UIHelper.showLocationRequiredAlert(from: controller, locationServicesEnabled: false)
            }
        }

        geoLocationSubscription = geoLocationService.subscribeForLocation { [weak self] deviceLocation in
            guard let `self` = self else { return }

            self.selectedPosition = deviceLocation
            self.geoLocationSubscription?.unsubscribe()
            self.reverseGeocodeSelectedPosition()
        }

        reverseGeocodeSelectedPosition()
    }

    private func reverseGeocodeSelectedPosition() {
        geoLocationService.reverseGeocode(location: selectedPosition) { [weak self] result in
            guard let self = self else { return }

            if case .success(let address) = result {
                self.selectedAddress = address
            }
            self.locationUpdatedSubscriptions.fire(())
        }
    }

    // MARK: - Data
	private func insuranceMain(useCache: Bool, completion: @escaping (Result< InsuranceMain, AlfastrahError>) -> Void) {
        insurancesService.insurances(useCache: useCache) { completion($0) }
    }
    
    private func getEmergencyHelp(
        viewController: SosViewController,
        sosModel: SosModel
    ) {
        insurancesService.emergencyHelp(
            useCache: false,
            completion: { [weak viewController] result in
                guard let viewController = viewController
                else { return }
            
                viewController.notify.updateWithState(.filled)
                
                switch result {
                    case .success(let sosInsureds):
                        if !sosInsureds.isEmpty {
                            self.definingTransition(
                                viewController: viewController,
                                insureds: sosInsureds
                            )
                        }
                        else if !self.insurancesService.cachedSosInsured().isEmpty {
                            self.definingTransition(
                                viewController: viewController,
                                insureds: self.insurancesService.cachedSosInsured()
                            )
                        }
                        else {
                            self.showSosActivitiesController(for: sosModel)
                        }
                    case .failure:
                        if !self.insurancesService.cachedSosInsured().isEmpty,
                           self.accountService.isAuthorized {
                            self.definingTransition(
                                viewController: viewController,
                                insureds: self.insurancesService.cachedSosInsured()
                            )
                        }
                        else {
                            self.showSosActivitiesController(for: sosModel)
                        }
                }
                viewController.notify.updateViewUserInteractionEnabled()
            }
        )
    }
	
	private func showConfidantViewController(
		viewController: SosViewController,
		mode: ConfidantViewController.Mode
	)
	{
		let confidantViewController = ConfidantViewController()
		container?.resolve(confidantViewController)
		confidantViewController.input = .init(mode: mode)
		confidantViewController.output = .init(
			delete: { [weak confidantViewController, weak viewController] in
				
				guard let confidantViewController,
					  let viewController
				else { return }
				
				self.showRemoveConfidantAlert(
					rootViewController: viewController,
					from: confidantViewController
				)
			}, 
			goToUserContacts: { [weak confidantViewController] contactPickerViewController in
				
				updateColorNavigationBar(isSystemNavBarColor: true)
				confidantViewController?.present(
					contactPickerViewController,
					animated: true,
					completion: nil
				)
			},
			saveOrChangesData: { [weak confidantViewController, weak viewController] name, phone in
				
				guard let viewController,
					  let confidantViewController
				else { return }
				
				let hide = confidantViewController.showLoadingIndicator(message: nil)
				
				self.insurancesService.addConfidant(
					name: name,
					phone: phone,
					completion: { result in

						hide(nil)
						
						switch result {
							case .success(let infoMessage):
							
								viewController.notify.updateConfidant()
							
								switch infoMessage.type {
									case .screen:
										self.showConfidantSuccessStateViewController(
											rootViewController: viewController,
											infoMessage: infoMessage
										)
									
									case .alert:
										self.showSuccessConfidantAlert(
											rootViewController: viewController,
											from: confidantViewController,
											infoMessage: infoMessage
										)
									case .none, .popup:
										return
								}
							
							case .failure(let error):
								switch error {
									case .network(let networkError):
										if networkError.isUnreachableError {
											confidantViewController.notify.updateWithState(.filled)
											showNetworkUnreachableBanner()
										} else {
											confidantViewController.notify.updateWithState(.failure)
										}
									
									case .api, .error, .infoMessage:
										confidantViewController.notify.updateWithState(.failure)
										
								}
						}
					}
				)
			},
			goToSettings: { [weak confidantViewController] in
				guard  let confidantViewController
				else { return }
				
				self.promptToNavigateToAppSettings(
					viewController: confidantViewController
				)
			},
			goToChat: { [weak confidantViewController] in
				
				guard let confidantViewController
				else { return }
				
				let chatFlow = ChatFlow()
				self.container?.resolve(chatFlow)
				chatFlow.show(from: confidantViewController, mode: .fullscreen)
			}
		)
		
		initialViewController.pushViewController(
			confidantViewController,
			animated: true
		)
	}
	
	private func showConfidantSuccessStateViewController(
		rootViewController: SosViewController,
		infoMessage: InfoMessage
	)
	{
		let confidantSuccessStateViewController = ConfidantSuccessStateViewController()
		container?.resolve(confidantSuccessStateViewController)
		confidantSuccessStateViewController.input = .init(infoMessage: infoMessage)
		confidantSuccessStateViewController.output = .init(
			toClose: {
				self.initialViewController.popToViewController(
					rootViewController,
					animated: true
				)
			},
			toChat: { [weak confidantSuccessStateViewController] in
				
				guard let confidantSuccessStateViewController
				else { return }

				let chatFlow = ChatFlow()
				self.container?.resolve(chatFlow)
				chatFlow.show(from: confidantSuccessStateViewController, mode: .fullscreen)
			},
			toRetry: {
				self.initialViewController.popViewController(animated: true)
			}
		)
		
		initialViewController.pushViewController(
			confidantSuccessStateViewController,
			animated: true
		)
	}
	
	private func showSuccessConfidantAlert(
		rootViewController: SosViewController,
		from viewController: ConfidantViewController,
		infoMessage: InfoMessage
	) {
		guard let infoMessageActions = infoMessage.actions
		else { return }
		
		let alert = UIAlertController(
			title: infoMessage.titleText,
			message: infoMessage.desciptionText,
			preferredStyle: .alert
		)
		
		var actions: [UIAlertAction] = []
		
		for action in infoMessageActions {
			actions.append(
				UIAlertAction(
					title: action.titleText,
					style: .default
				) {
					[weak viewController] _ in
					
					guard let viewController
					else { return }
					
					switch action.type {
						case .close:
							self.initialViewController.popToViewController(
								rootViewController,
								animated: true
							)
						
						case .retry:
							self.initialViewController.popViewController(animated: true)
						
						case .toChat:
							let chatFlow = ChatFlow()
							self.container?.resolve(chatFlow)
							chatFlow.show(from: viewController, mode: .fullscreen)
					}
				}
			)
		}
		
		actions.forEach
		{
			alert.addAction($0)
		}
		
		viewController.present(alert, animated: true)
	}
	
	private func promptToNavigateToAppSettings(
		viewController: UIViewController
	)
	{
		let alert = UIAlertController(
			title: NSLocalizedString(
				"sos_confidant_denied_contact_alert_title",
				comment: ""
			),
			message: NSLocalizedString(
				"sos_confidant_denied_contact_alert_description",
				comment: ""
			),
			preferredStyle: .alert
		)
			
		alert.addAction(
			UIAlertAction(
				title: NSLocalizedString("sos_cofidant_denied_contact_settings_button", comment: ""),
				style: .default
			)
		{
			_ in
			
			if let url = URL(string: UIApplication.openSettingsURLString)
			{
				UIApplication.shared.open(url)
			}
		})
			
		alert.addAction(
			UIAlertAction(
				title: NSLocalizedString("common_cancel_button", comment: ""),
				style: .cancel
			)
		)
		
		viewController.present(alert, animated: true)
	}
	
	private func showRemoveConfidantAlert(
		rootViewController: SosViewController,
		from viewController: ConfidantViewController
	) {
		
		let alert = UIAlertController(
			title: NSLocalizedString("sos_confidant_delete_title_alert", comment: ""),
			message: nil,
			preferredStyle: .alert
		)
		
		let yesAction = UIAlertAction(
			title: NSLocalizedString("common_yes_button", comment: ""),
			style: .default
		) { [weak viewController, weak rootViewController, weak self] _ in
			
			guard let rootViewController,
				  let viewController
			else { return }
			
			let hide = viewController.showLoadingIndicator(message: nil)
			
			self?.insurancesService.deleteConfidant(
				completion: { [weak self] result in
					guard let self
					else { return }
					
					hide(nil)
					
					switch result {
						case .success(let infoMessage):
							rootViewController.notify.updateConfidant()
						
							switch infoMessage.type {
								case .screen:
									self.showConfidantSuccessStateViewController(
										rootViewController: rootViewController,
										infoMessage: infoMessage
									)
							
								case .alert:
									self.showSuccessConfidantAlert(
										rootViewController: rootViewController,
										from: viewController,
										infoMessage: infoMessage
									)
								case .none, .popup:
									return
							}
						
						 case .failure(let error):
							switch error {
								case .network(let networkError):
									if networkError.isUnreachableError {
										viewController.notify.updateWithState(.filled)
										showNetworkUnreachableBanner()
									} else {
										viewController.notify.updateWithState(.failure)
									}
							
								case .api, .error, .infoMessage:
									viewController.notify.updateWithState(.failure)
						}
					}
				}
			)
		}
		
		let noAction = UIAlertAction(
			title: NSLocalizedString("common_no_button", comment: ""),
			style: .cancel
		)
		
		alert.addAction(noAction)
		alert.addAction(yesAction)

		viewController.present(alert, animated: true)
	}

    // MARK: - Helpers
     private func phoneTap(_ phone: SosPhone) {
        PhoneHelper.handlePhone(plain: phone.phone, humanReadable: phone.title)
    }

    enum Constants {
        static let aslPaymentUrl = "http://check.aslife.ru/"
    }
}
// swiftlint:enable file_length
