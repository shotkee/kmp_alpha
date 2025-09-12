//
//  InteractiveSupportFlow.swift
//  AlfaStrah
//
//  Created by vit on 07.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class InteractiveSupportFlow: BaseFlow,
                              InteractiveSupportServiceDependency,
                              GeocodeServiceDependency,
                              InsurancesServiceDependency,
							  DoctorAppointmentServiceDependency,
							  AccountServiceDependency {
    var interactiveSupportService: InteractiveSupportService!
    var geocodeService: GeocodeService!
    var insurancesService: InsurancesService!
    var doctorAppointmentService: DoctorAppointmentService!
	var accountService: AccountService!
    
    private var needShowWelcomeScreen: Bool = true
    
    private var insurance: InsuranceShort?
    private var shortInsurance: InsuranceShort?
    
    private var questionsResponse: InteractiveSupportQuestionsResponse?
    private var resultInfoScreens: [InteractiveSupportResultInfoViewController]?
    
    enum FlowStartScreenPresentationType {
        case fromSheet
        case fullScreen
    }
    
    func start(
        for insurance: InsuranceShort,
        with onboardingData: InteractiveSupportData,
        flowStartScreenPresentationType: FlowStartScreenPresentationType
    ) {
        logger?.debug("")
        
        self.insurance = insurance
        
        self.needShowWelcomeScreen = interactiveSupportService.showOnboarding(insuranceId: insurance.id)
        
        if needShowWelcomeScreen {
            showWelcomeScreen(for: insurance, with: onboardingData, flowStartScreenPresentationType: flowStartScreenPresentationType)
        } else {
            guard let navigationController = fromViewController?.navigationController
            else { return }

            self.navigationController = navigationController
            
            showQuestionare(flowStartScreenPresentationType: flowStartScreenPresentationType)
        }
        
        // non-blocking update for v3 insurance if needed
        insurancesService.insurance(useCache: true, id: insurance.id) { _ in }
    }
        
    private func showWelcomeScreen(
        for insurance: InsuranceShort,
        with onboardingData: InteractiveSupportData,
        flowStartScreenPresentationType: FlowStartScreenPresentationType
    ) {
        switch flowStartScreenPresentationType {
            case .fromSheet:
                guard let navigationController = fromViewController?.navigationController
                else { return }
                
                self.navigationController = navigationController
                
                let welcomeController = createInteractiveSupportWelcomeViewController(
                    with: onboardingData,
                    flowStartScreenPresentationType: .fromSheet
                ) {}
                
                let actionSheetViewController = ActionSheetViewController(with: welcomeController)
                actionSheetViewController.enableDrag = true
                actionSheetViewController.enableTapDismiss = false
                
                fromViewController?.present(actionSheetViewController, animated: true)
                
            case .fullScreen:
                guard let navigationController = fromViewController?.navigationController
                else { return }
                
                self.navigationController = navigationController
                
                let welcomeController = createInteractiveSupportWelcomeViewController(
                    with: onboardingData,
                    flowStartScreenPresentationType: FlowStartScreenPresentationType.fullScreen
                ) {}
                
                welcomeController.modalPresentationStyle = .fullScreen
                
                fromViewController?.present(welcomeController, animated: true)
                
        }
        
        interactiveSupportService.onboardingWasShownForInsurance(with: insurance.id)
    }
    
    private func createInteractiveSupportWelcomeViewController(
        with onboardingData: InteractiveSupportData,
        flowStartScreenPresentationType: FlowStartScreenPresentationType,
        completion: @escaping () -> Void
    ) -> ActionSheetContentViewController {
        let viewController = InteractiveSupportWelcomeViewController()
        container?.resolve(viewController)
                
        viewController.input = .init(
            onboardingStartScreenData: onboardingData.startScreenData,
            flowStartScreenPresentationType: flowStartScreenPresentationType,
            appear: {}
        )
        
        viewController.output = .init(
            action: { [weak viewController] in
                viewController?.dismiss(animated: true) {
                    self.showQuestionare(flowStartScreenPresentationType: .fromSheet)
                }
            },
            close: { [weak viewController] in
                viewController?.dismiss(animated: true) {
                    completion()
                }
            }
        )
        
        return viewController
    }
    
    private func showQuestionare(flowStartScreenPresentationType: FlowStartScreenPresentationType) {
        guard let insuranceId = self.insurance?.id,
              let topViewController = navigationController?.topViewController as? ViewController
        else { return }
        
        let hide = topViewController.showLoadingIndicator(
            message: NSLocalizedString("common_load", comment: "")
        )
        
        interactiveSupportService.questions(insuranceId: insuranceId) { result in
            hide(nil)
            
            switch result {
                case .success(let response):
                    self.questionsResponse = response
                    
                    guard let questionData = response.questions.first(where: {
                        response.firstQuestionId == $0.id
                    }) else { return }
                    
                    let viewController = self.createInteractiveSupportQuestionareStepViewController(
                        isQuestionareStart: true,
                        with: questionData,
                        flowStartScreenPresentationType: flowStartScreenPresentationType
                    )
                               
                    let navigationController = TranslucentNavigationController()
                    navigationController.strongDelegate = TranslucentNavigationControllerDelegate()
                    self.navigationController = navigationController
                    
                    switch flowStartScreenPresentationType {
                        case .fromSheet:
                            self.fromViewController.navigationController?.present(
                                navigationController,
                                animated: false
                            ) {
                                self.navigationController?.pushViewController(viewController, animated: true)
                            }
                            
                        case .fullScreen:
                            navigationController.viewControllers = [viewController]
                            
                            self.fromViewController.navigationController?.present(
                                navigationController,
                                animated: true
                            )
                    }
                    
                case .failure(let error):
                    topViewController.processError(error)
                    
            }
        }
    }
    
    private func createInteractiveSupportQuestionareStepViewController(
        isQuestionareStart: Bool,
        with questionData: InteractiveSupportQuestion,
        flowStartScreenPresentationType: FlowStartScreenPresentationType
    ) -> InteractiveSupportQuestionareStepViewController {
        let viewController = InteractiveSupportQuestionareStepViewController()
        container?.resolve(viewController)
        
        viewController.input = .init(
            title: questionData.title,
            items: questionData.answers.map {
                return InteractiveSupportQuestionareStepViewController.Item(
                    value: $0.title,
                    tapHandler: { answerIndex in
                        if let selectedAnswer = questionData.answers[safe: answerIndex] {
                            switch selectedAnswer.nextStepType {
                                case .result:
                                    self.applyQuestionareResult(
										with: selectedAnswer,
										flowStartScreenPresentationType: flowStartScreenPresentationType
									)
                                case .nextStep:
                                    guard let questionsResponse = self.questionsResponse,
                                          let nextQuestion = questionsResponse.questions.first(
                                            where: { $0.id == selectedAnswer.nextQuestionId }
                                          )
                                    else { return }
                                    
                                    let nextQuestionViewController = self.createInteractiveSupportQuestionareStepViewController(
                                        isQuestionareStart: false,
                                        with: nextQuestion,
                                        flowStartScreenPresentationType: flowStartScreenPresentationType
                                    )
                                    
                                    self.navigationController?.pushViewController(nextQuestionViewController, animated: true)
                            }
                        }
                    }
                )
            }
        )
        
        if isQuestionareStart {
            viewController.addCloseButton(position: .right) {
                ApplicationFlow.shared.show(item: .tabBar(.home))
            }
            
            viewController.addBackButton { [weak viewController] in
                viewController?.dismiss(animated: true)
            }
        } else {
            viewController.addCloseButton(position: .right) { [weak viewController] in
                guard let viewController
                else { return }
                
                self.handleNavigationOnFlowExit(from: viewController)
            }
        }
        
        return viewController
    }
    
    private func applyQuestionareResult(
		with answer: InteractiveSupportAnswer,
		flowStartScreenPresentationType: FlowStartScreenPresentationType
	) {
        guard let insuranceId = self.insurance?.id,
              let resultKey = answer.key,
              let topViewController = navigationController?.topViewController as? ViewController
        else { return }
        
        let hide = topViewController.showLoadingIndicator(
            message: NSLocalizedString("common_load", comment: "")
        )
        
        interactiveSupportService.applyResult(insuranceId: insuranceId, onboardingResultKey: resultKey) { result in
            hide(nil)
            
            switch result {
                case .success(let response):
                    self.handlQuestionareApplication(with: response, flowStartScreenPresentationType: flowStartScreenPresentationType)
                    
                case .failure(let error):
                    ErrorHelper.show(
                        error: error,
                        alertPresenter: self.alertPresenter
                    )
                    
            }
        }
    }
    
    private func handlQuestionareApplication(
        with response: [InteractiveSupportQuestionnaireResult],
        flowStartScreenPresentationType: FlowStartScreenPresentationType
    ) {
        let phoneCalls = response.filter {
            switch $0.type {
                case .phoneCall:
                    return true
                default:
                    return false
            }
        }
        
        if let phone = phoneCalls.first?.phone {
            self.phoneCall(phone)
            return
        }
        
        let screens = response.filter {
            switch $0.type {
                case .showScreen:
                    return true
                default:
                    return false
            }
        }
        
        if !screens.isEmpty,
           let navigationController = self.navigationController {
            var resultInfoScreens: [InteractiveSupportResultInfoViewController] = []
            
            for (index, screen) in screens.enumerated() {
                let isLastResult = index == screens.endIndex - 1
                
                let viewController = createResultInfo(
                    for: screen,
                    isLastResult: isLastResult,
                    flowStartScreenPresentationType: flowStartScreenPresentationType
                ) {}
                
                resultInfoScreens.append(viewController)
            }
            
            self.resultInfoScreens = resultInfoScreens
            
            if let firstResultInfoScreen = self.resultInfoScreens?.first {
                navigationController.pushViewController(firstResultInfoScreen, animated: true)
            }
        }
    }
        
    private func handleNavigationOnFlowExit(from viewController: ViewController) {
        ApplicationFlow.shared.show(item: .tabBar(.home))
    }
    
    private func onResultInfoSkip(from viewController: ViewController) {
        guard let currentViewControllerIndex = self.resultInfoScreens?.firstIndex(where: { viewController === $0 }),
              let nextResultInfoViewController = self.resultInfoScreens?[safe: currentViewControllerIndex + 1],
              let navigationController = self.navigationController
        else { return }
        
        navigationController.pushViewController(nextResultInfoViewController, animated: true)
    }
    
    private func createResultInfo(
        for result: InteractiveSupportQuestionnaireResult,
        isLastResult: Bool,
        flowStartScreenPresentationType: FlowStartScreenPresentationType,
        completion: @escaping () -> Void
    ) -> InteractiveSupportResultInfoViewController{
        
        let viewController = InteractiveSupportResultInfoViewController()
        
        viewController.input = .init(
            isLastResult: isLastResult,
            result: result
        )
        
        viewController.output = .init(
            primaryAction: {
                guard let action = result.button?.action
                else { return }
                
                self.handleBackendAction(action, flowStartScreenPresentationType: flowStartScreenPresentationType)
            },
            navigationAction: { [weak viewController] in
                guard let viewController
                else { return }

                if isLastResult {
                    self.handleNavigationOnFlowExit(from: viewController)
                } else {
                    self.onResultInfoSkip(from: viewController)
                }
            }
        )
        
        return viewController
    }
    
    private func phoneCall(_ phone: Phone) {
        guard let topViewController = navigationController?.topViewController as? ViewController
        else { return }
        
        showCallNumberActionSheet(phone: phone, viewController: topViewController)
    }
    
    private func showTelemedicine(by insuranceid: String) {
        guard let topViewController = navigationController?.topViewController as? ViewController
        else { return }
        
        let hide = topViewController.showLoadingIndicator(message: NSLocalizedString("common_load", comment: ""))

        insurancesService.telemedicineUrl(insuranceId: insuranceid) { result in
            hide(nil)
            switch result {
                case .success(let url):
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                case .failure(let error):
                    ErrorHelper.show(
                        error: error,
                        alertPresenter: self.alertPresenter
                    )
            }
        }
    }
    
    private func openClinics(with insuranceId: String) {
        guard let topViewController = navigationController?.topViewController as? ViewController
        else { return }
        
        let flow = ClinicAppointmentFlow(rootController: topViewController)
        container?.resolve(flow)
        flow.start(insuranceId: insuranceId, mode: .modal, showLoading: true)
    }
    
    private func handleBackendAction(_ actionInfo: BackendAction, flowStartScreenPresentationType: FlowStartScreenPresentationType) {
        switch actionInfo.type {
            case .doctorCall(insuranceId: let insuranceId, data: let doctorCalldata):
                self.showDoctorCallQuestionnaire(
                    insuranceId: insuranceId,
                    doctorCall: doctorCalldata,
                    flowStartScreenPresentationType: flowStartScreenPresentationType
                )
            case .telemedicine(insuranceId: let insuranceId):
                showTelemedicine(by: insuranceId)
            case .clinicAppointment(insuranceId: let insuranceId):
                openClinics(with: insuranceId)
            case
                .path,
                .insurance,
                .kaskoReport,
                .loyalty,
                .onlineAppointment,
                .offlineAppointment,
                .osagoReport,
                .propertyProlongation,
                .none:
                break
        }
    }
    
    private func showCallNumberActionSheet(
        phone: Phone,
        viewController: ViewController
    ) {
        let actionSheet = UIAlertController(
            title: phone.humanReadable,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let callNumberAction = UIAlertAction(
            title: NSLocalizedString("common_call", comment: ""),
            style: .default
        ) { _ in
            
            guard let url = URL(string: "telprompt://" + phone.plain)
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
    
    private func showDoctorCallQuestionnaire(
        insuranceId: String,
        doctorCall: BackendDoctorCall,
        flowStartScreenPresentationType: FlowStartScreenPresentationType
    ) {
        let questionnaireViewController = QuestionnaireViewController()
        container?.resolve(questionnaireViewController)
        
        questionnaireViewController.input = .init(
            insuranceId: insuranceId,
            doctorCall: doctorCall
        )
        
        questionnaireViewController.output = .init(
            showNotificationChildrenQuestionnaire: { [weak questionnaireViewController] childDoctorBanner in
                guard let questionnaireViewController = questionnaireViewController
                else { return }
                
                self.showNotificationChildrenQuestionnaireBottomSheet(
                    from: questionnaireViewController,
                    childDoctorBanner: childDoctorBanner
                )
            },
            close: { [weak questionnaireViewController] in
                guard let questionnaireViewController = questionnaireViewController
                else { return }
                
                self.showCancelQuestionnaireAlert(
                    from: questionnaireViewController
                )
            },
            selectedDate: { [weak questionnaireViewController] selectedIndex, dates, completion in
                guard let questionnaireViewController = questionnaireViewController
                else { return }
                
                self.presentQuestionnaireBottomSheet(
					title: NSLocalizedString("questionnaire_bottom_sheet_visit_date_title", comment: ""),
                    from: questionnaireViewController,
                    selectedIndex: selectedIndex,
                    for: dates,
                    completion: completion
                )
            },
            updatePhone: { [weak questionnaireViewController] phone, completion in
                guard let questionnaireViewController = questionnaireViewController
                else { return }
                
                self.openRewritePhoneBottomViewController(
                    from: questionnaireViewController,
                    phone: phone,
                    completion: completion
                )
            },
            updateSymptoms: { [weak questionnaireViewController] symptoms, completion in
                guard let questionnaireViewController = questionnaireViewController
                else { return }
                self.openUpdateSymptomsInputBottomView(
                    from: questionnaireViewController,
                    data: symptoms,
                    completion: completion
                )
            },
            updateAddress: { [weak questionnaireViewController]  address, completion in
                guard let questionnaireViewController = questionnaireViewController
                else { return }
                
                self.showUpdateAddressInputViewController(
                    from: questionnaireViewController,
                    currentAddress: address,
                    completion: completion
                )
            },
            sendQuestionnaire: { [weak self] doctorAppointmentRequest in
                self?.showSuccessfullQuennaireViewController(
                    doctorAppointmentRequest: doctorAppointmentRequest
                )
            }
        )
        
        self.navigationController?.pushViewController(questionnaireViewController, animated: true)
    }
	
	func showDoctorCallQuestionnaireBDUI(
		doctorCall: DoctorCallBDUI
	) {
		let questionnaireViewController = QuestionnaireBDUIViewController()
		container?.resolve(questionnaireViewController)
		
		questionnaireViewController.input = .init(
			doctorCall: doctorCall
		)
		
		questionnaireViewController.output = .init(
			showNotificationChildrenQuestionnaire: { [weak questionnaireViewController] in
				guard let questionnaireViewController,
					  let bannerData = doctorCall.childDoctorBanner
				else { return }
				
				self.showNotificationChildrenQuestionnaireBottomSheetBDUI(
					from: questionnaireViewController,
					childDoctorBanner: bannerData
				)
			},
			close: { [weak questionnaireViewController] in
				guard let questionnaireViewController
				else { return }
				
				self.showCancelQuestionnaireAlert(
					from: questionnaireViewController
				)
			},
			selectedDate: { [weak questionnaireViewController] selectedIndex, dates, completion in
				guard let questionnaireViewController
				else { return }
				
				self.presentQuestionnaireBottomSheet(
					title: NSLocalizedString("questionnaire_bottom_sheet_visit_date_title", comment: ""),
					from: questionnaireViewController,
					selectedIndex: selectedIndex,
					for: dates,
					completion: completion
				)
			},
			updatePhone: { [weak questionnaireViewController] phone, completion in
				guard let questionnaireViewController = questionnaireViewController
				else { return }
				
				self.openRewritePhoneBottomViewController(
					from: questionnaireViewController,
					phone: phone,
					completion: completion
				)
			},
			updateSymptoms: { [weak questionnaireViewController] symptoms, completion in
				guard let questionnaireViewController = questionnaireViewController
				else { return }
				self.openUpdateSymptomsInputBottomView(
					from: questionnaireViewController,
					data: symptoms,
					completion: completion
				)
			},
			updateAddress: { [weak questionnaireViewController]  address, completion in
				guard let questionnaireViewController = questionnaireViewController
				else { return }
				
				self.showUpdateAddressInputViewController(
					from: questionnaireViewController,
					currentAddress: address,
					completion: completion
				)
			},
			updateDistanceType: { [weak questionnaireViewController] selectedIndex, distanceType, completion in
				guard let questionnaireViewController = questionnaireViewController
				else { return }
				
				self.presentQuestionnaireBottomSheet(
					title: NSLocalizedString("questionnaire_location_title", comment: ""),
					from: questionnaireViewController,
					selectedIndex: selectedIndex,
					for: distanceType,
					completion: completion
				)
			},
			updateMedicalLeaveAnswer: { [weak questionnaireViewController] selectedIndex, medicalLeaveAnswers, completion in
				guard let questionnaireViewController = questionnaireViewController
				else { return }
				
				self.presentQuestionnaireBottomSheet(
					title: NSLocalizedString("questionnaire_sick_list_title", comment: ""),
					from: questionnaireViewController,
					selectedIndex: selectedIndex,
					for: medicalLeaveAnswers,
					completion: completion
				)
			},
			sendQuestionnaire: { [weak self] doctorAppointmentRequest in
				self?.showSuccessfullQuennaireViewController(
					doctorAppointmentRequest: doctorAppointmentRequest
				)
			}
		)
		
		let navigationController = RMRNavigationController(rootViewController: questionnaireViewController)
		navigationController.strongDelegate = RMRNavigationControllerDelegate()
		self.navigationController = navigationController
		
		fromViewController.present(navigationController, animated: true)
	}
	
	private func showNotificationChildrenQuestionnaireBottomSheetBDUI(
		from viewController: ViewController,
		childDoctorBanner: BannerDataBDUI
	){
		func descriptionLabel(_ text: String) -> UILabel {
			let description = UILabel()
			description <~ Style.Label.primaryText
			description.numberOfLines = 0
			description.text = text
			return description
		}
		
		QuestionnaireBottomSheet.present(
			from: viewController,
			title: childDoctorBanner.title,
			buttonTitle: childDoctorBanner.buttonTitle,
			additionalViews: [
				descriptionLabel(childDoctorBanner.text),
				spacer(12)
			]
		)
	}
	
    private func showNotificationChildrenQuestionnaireBottomSheet(
        from viewController: ViewController,
        childDoctorBanner: BackendBannerData
    ){
        func descriptionLabel(_ text: String) -> UILabel {
            let description = UILabel()
            description <~ Style.Label.primaryText
            description.numberOfLines = 0
            description.text = text
            return description
        }
        
        QuestionnaireBottomSheet.present(
            from: viewController,
            title: childDoctorBanner.title,
            buttonTitle: childDoctorBanner.buttonTitle,
            additionalViews: [
                descriptionLabel(childDoctorBanner.text),
                spacer(12)
            ]
        )
    }
    
    private func presentQuestionnaireBottomSheet(
		title: String,
        from viewController: ViewController,
        selectedIndex: Int,
        for dates: [String],
        completion: @escaping (Int) -> Void
    ) {
        let multipleValuePickerBottomViewController: MultipleValuePickerBottomViewController = .init()
        container?.resolve(multipleValuePickerBottomViewController)
        
        var selectables: [SelectableItem] = []
        
        for index in 0 ..< dates.count {
            selectables.append(
                QuestionnaireDateSelectable(
                    id: dates[index],
                    title: dates[index],
                    isSelected: index == selectedIndex,
                    activateUserInput: false
                )
            )
        }

        multipleValuePickerBottomViewController.input = .init(
            title: title,
            dataSource: selectables,
            isMultiSelectAllowed: false,
            footerStyle: .actions(
                primaryButtonTitle: NSLocalizedString(
                    "questionnaire_bottom_sheet_visit_date_button",
                    comment: ""
                ),
                secondaryButtonTitle: nil
            ),
            tintColor: Style.Color.Palette.red
        )

        multipleValuePickerBottomViewController.output = .init(
            close: { [weak viewController] in
                viewController?.dismiss(animated: true)
            },
            done: { [weak viewController] selectedTypes in
                viewController?.dismiss(animated: true)
                
                if let selectedIndex = selectables.firstIndex(
                    where: { $0.title == selectedTypes.first?.title }
                ) {
                    completion(selectedIndex)
                }
            }
        )
        
        viewController.showBottomSheet(contentViewController: multipleValuePickerBottomViewController)
    }
    
    private func openUpdateSymptomsInputBottomView(
        from viewController: UIViewController,
        data: String?,
        completion: @escaping (String) -> Void
    ) {
        let controller: TextNoteInputBottomViewController = .init()
        container?.resolve(controller)

        controller.input = .init(
            title: NSLocalizedString("questionnaire_bottom_sheet_symptoms_title", comment: ""),
            description: nil,
            textInputTitle: nil,
            textInputPlaceholder: NSLocalizedString("questionnaire_bottom_sheet_symptoms_title", comment: ""),
            initialText: data,
            showSeparator: true,
            validationRules: [],
            keyboardType: .default,
            textInputMinHeight: 18,
            charsLimited: .limited(250),
            tintColor: Style.Color.Palette.red,
            isVisibleCharsCount: true,
            scenario: .interactiveSupport
        )

        controller.output = .init(
            close: { [weak viewController] in
                viewController?.dismiss(animated: true)
            },
            text: { [weak viewController] text in
                viewController?.dismiss(animated: true)
                completion(text)
            }
        )

        viewController.showBottomSheet(contentViewController: controller)
    }
    
    private func showCancelQuestionnaireAlert(
        from: ViewController
    ) {
        let alert = UIAlertController(
            title: NSLocalizedString("questionnaire_alert_title", comment: ""),
            message: NSLocalizedString("questionnaire_alert_description", comment: ""),
            preferredStyle: .alert
        )

        let saveAction = UIAlertAction(
            title: NSLocalizedString("questionnaire_alert_button_continue", comment: ""),
            style: .default
        )

        let cancelAction = UIAlertAction(
            title: NSLocalizedString("questionnaire_alert_button_cancel", comment: ""),
            style: .cancel
        ){  _ in
            self.handleNavigationOnFlowExit(from: from)
        }

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        from.present(alert, animated: true)
    }
    
    private func openRewritePhoneBottomViewController(
        from viewController: UIViewController,
        phone: String?,
        autocapitalizationType: UITextAutocapitalizationType = .none,
        completion: @escaping (String) -> Void
    ) {
        let controller = PhoneInputBottomViewController()

        controller.input = .init(
            title: NSLocalizedString("disagreement_with_services_phone_number", comment: ""),
            placeholder: NSLocalizedString("disagreement_with_services_phone_number_prompt", comment: ""),
            initialPhoneText: phone
        )
        controller.output = .init(
			completion: { [weak viewController] _, humanReadable in
                viewController?.dismiss(animated: true)
                completion(humanReadable)
			}
		)
        
        viewController.showBottomSheet(contentViewController: controller)
    }
    
    private func showUpdateAddressInputViewController(
        from viewController: ViewController,
        currentAddress: String?,
        completion: @escaping (String) -> Void
    ) {
        let controller: AddressInputViewController = UIStoryboard(
            name: "CreateAutoEvent", bundle: nil
        ).instantiate()
        container?.resolve(controller)
        controller.input = .init(
			isDemo: accountService.isDemo,
            scenario: .interactiveSupportEvent,
            currentAddress: currentAddress
        )
        controller.output = .init(
            enterAddress: geocodeService.searchLocation,
            selectAddress: { [weak viewController] place in
                viewController?.dismiss(animated: false)
                completion(place.fullTitle)
            },
            showMap: {},
            saveAddress: { [weak viewController] address in
                viewController?.dismiss(animated: false)
                completion(address)
            }
        )
        controller.addCloseButton {
            viewController.dismiss(animated: false)
        }
        
        let navigationController = RMRNavigationController(rootViewController: controller)
        navigationController.strongDelegate = RMRNavigationControllerDelegate()
        viewController.present(navigationController, animated: true)
    }
    
    private func showSuccessfullQuennaireViewController(
        doctorAppointmentRequest: DoctorAppointmentRequest
    ) {
        let controller = SuccessfullQuennaireViewController()
        container?.resolve(controller)
        
        controller.input = .init(
            createAppointment: { [weak self, weak controller] in
                self?.doctorAppointmentService.createAppointment(
                    doctorAppointmentRequest: doctorAppointmentRequest,
                    completion: { result in
                        switch result {
                            case .success(let doctorAppointmentInfoMessage):
                                controller?.notify.updateWithState(
                                    .filled(doctorAppointmentInfoMessage)
                                )
                            case .failure:
                                controller?.notify.updateWithState(.failure)
                        }
                    }
                )
            }
        )
        
        controller.output = .init(
            close: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            showToMain: { [weak self] in
                ApplicationFlow.shared.show(item: .tabBar(.home))
            },
            goToChat: { [weak self] in
                ApplicationFlow.shared.show(item: .tabBar(.chat))
            }
        )
        
        self.navigationController?.pushViewController(
            controller,
            animated: true
        )
    }
}
