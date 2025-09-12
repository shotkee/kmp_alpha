//
//  ActionHandlerFlow.swift
//  AlfaStrah
//
//  Created by vit on 05.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import SDWebImage

// swiftlint:disable file_length
extension BDUI {
	class ActionHandlerFlow: AccountServiceDependency,
									AlertPresenterDependency,
									AnalyticsServiceDependency,
									ApiStatusServiceDependency,
									ApplicationSettingsServiceDependency,
									AttachmentServiceDependency,
									BackendDrivenServiceDependency,
									BonusPointsServiceDependency,
									CampaignServiceDependency,
									DependencyContainerDependency,
									DraftsCalculationsServiceDependency,
									EventReportServiceDependency,
									FlatOnOffServiceDependency,
									InsurancesProductCategoryServiceDependency,
									InsurancesServiceDependency,
									InteractiveSupportServiceDependency,
									KaskoExtensionServiceDependency,
									LoggerDependency,
									LoyaltyServiceDependency,
									MarksWebServiceDependency,
									MedicalCardServiceDependency,
									NotificationsServiceDependency,
									PassbookServiceDependency,
									PolicyServiceDependency,
									QuestionServiceDependency,
									ServiceDataManagerDependency,
									SessionServiceDependency,
									StoriesServiceDependency,
									UserSessionServiceDependency,
									VoipServiceDependency,
									VzrOnOffServiceDependency {
		var accountService: AccountService!
		var alertPresenter: AlertPresenter!
		var analytics: AnalyticsService!
		var apiStatusService: ApiStatusService!
		var applicationSettingsService: ApplicationSettingsService!
		var attachmentService: AttachmentService!
		var backendDrivenService: BackendDrivenService!
		var bonusPointsService: BonusPointsService!
		var campaignService: CampaignService!
		var draftsCalculationsService: DraftsCalculationsService!
		var eventReportService: EventReportService!
		var flatOnOffService: FlatOnOffService!
		var interactiveSupportService: InteractiveSupportService!
		var insuranceAlfaLifeService: InsuranceLifeService!
		var insurancesProductCategoryService: InsurancesProductCategoryService!
		var insurancesService: InsurancesService!
		var kaskoExtensionService: KaskoExtensionService!
		var logger: TaggedLogger?
		var loyaltyService: LoyaltyService!
		var marksWebService: MarksWebService!
		var medicalCardService: MedicalCardService!
		var notificationsService: NotificationsService!
		var passbookService: PassbookService!
		var policyService: PolicyService!
		var questionService: QuestionService!
		var serviceDataManager: ServiceDataManager!
		var sessionService: UserSessionService!
		var storiesService: StoriesService!
		var userSessionService: UserSessionService!
		var voipService: VoipService!
		var vzrOnOffService: VzrOnOffService!
		
		var container: DependencyInjectionContainer?
		
		var initialViewController: UINavigationController
		
		private let disposeBag: DisposeBag = DisposeBag()
		
		private var voipServiceAvailability: VoipServiceAvailability?
		
		init() {
			let navigationController = RMRNavigationController()
			navigationController.strongDelegate = RMRNavigationControllerDelegate()
			initialViewController = navigationController
		}
		
		typealias LockCompletionEntry = (
			action: BDUI.ActionDTO,
			lockCompletion: BDUI.CommonActionHandlers.LockCompletion?
		)
		
		private var lockCompletions: [LockCompletionEntry] = [] {
			didSet {
#if DEBUG
				print("bdui action lock completions \(lockCompletions.count)")
#endif
			}
		}
		
		@discardableResult private func handleLockCompletion(
			for action: BDUI.ActionDTO,
			completion: (() -> Void)? = nil
		) -> Bool {
			if let entryIndex = lockCompletions.firstIndex(where: { $0.action === action}) {
				lockCompletions[entryIndex].lockCompletion?(completion)
#if DEBUG
				print("bdui action \(action.name) lock completion - removed")
#endif
				lockCompletions.remove(at: entryIndex)
				return true
			}
#if DEBUG
			print("bdui action \(action.name) lock completion - not exist!")
#endif
			return false
		}
		
		// swiftlint:disable:next function_body_length
		func handleBackendAction(
			_ events: EventsDTO,
			on viewController: ViewController,
			with screenId: String?,
			isModal: Bool,
			syncCompletion: (() -> Void)?
		) {
			// swiftlint:disable:next function_body_length cyclomatic_complexity
			func handle(_ action: BDUI.ActionDTO, on viewController: ViewController, syncCompletion: (() -> Void)?) {
				if let lockCompletion = BDUI.CommonActionHandlers.shared.handleLockBehavior(for: action) {
					lockCompletions.append((action, lockCompletion))
				}
				
#if DEBUG
				print("bdui action \(action.name) execute")
#endif
				
				switch action.type {
					case .actionFlowFranchise:
						if let action = action as? FranchiseFlowActionDTO,
						   let insuranceId = action.insuranceId {
							insurance(by: insuranceId, from: viewController) { [weak viewController] insurance in
								guard let viewController
								else { return }
								
								self.showFranchiseTransition(insurance: insurance, from: viewController)
								
								self.handleLockCompletion(for: action)
								syncCompletion?()
							}
						}
						
					case .actionFlowHelpBlocks:
						if let action = action as? HelpBlocksFlowActionDTO,
						   let insuranceId = action.insuranceId {
							insurance(by: insuranceId, from: viewController) { [weak viewController] insurance in
								guard let viewController
								else {
									self.handleLockCompletion(for: action)
									syncCompletion?()
									return
								}
								
								self.showInsuranceProgram(insurance: insurance, from: viewController, insuranceHelpUrl: action.url)
								
								self.handleLockCompletion(for: action)
								syncCompletion?()
							}
						}
						
					case .actionFlowCompensation:
						if let action = action as? CompensationFlowActionDTO,
						   let insuranceId = action.insuranceId {
							insurance(by: insuranceId, from: viewController) { [weak viewController] insurance in
								guard let viewController
								else {
									self.handleLockCompletion(for: action)
									syncCompletion?()
									return
								}
								
								self.showDmsCostRecovery(insurance: insurance, from: viewController)
								
								self.handleLockCompletion(for: action)
								syncCompletion?()
							}
						}
						
					case .actionFlowVirtualAssistant:
						if let action = action as? VirtualAssistantFlowActionDTO,
						   let insuranceId = action.insuranceId {
							let hide = viewController.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
							insurancesService.insurances(useCache: true) { result in
								switch result {
									case .success(let response):
										let insuranceShort = response.insuranceGroupList
											.flatMap { $0.insuranceGroupCategoryList }
											.flatMap { $0.insuranceList }
											.filter { $0.id == insuranceId }.first
										
										if let insuranceShort {
											self.showInteractiveSupport(insurance: insuranceShort, from: viewController) {
												hide(nil)
											}
										}
										
									case .failure(let error):
										hide(nil)
										ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
										
								}
								
								self.handleLockCompletion(for: action)
								syncCompletion?()
							}
						}
						
					case .actionFlowMedicalFileStorage:
						if let action = action as? MedicalFileStorageFlowActionDTO {
							showMedicalCard(from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}
						
					case .actionFLowTelemed:
						if let action = action as? TelemedFlowActionDTO,
						   let insuranceId = action.insuranceId {
							insurance(by: insuranceId, from: viewController) { insurance in
								self.showTelemedicineInfo(insurance: insurance, from: viewController)
								
								self.handleLockCompletion(for: action)
								syncCompletion?()
							}
						}
						
					case .actionFlowClinics:
						if let action = action as? ClinicsFlowActionDTO,
						   let insuranceId = action.insuranceId {
							let flow = ClinicAppointmentFlow(rootController: viewController)
							container?.resolve(flow)
							
							if let filterId = action.filterId {
								insurancesService.insurance(useCache: true, id: insuranceId) { [weak viewController] result in
									guard let viewController
									else {
										
										self.handleLockCompletion(for: action)
										syncCompletion?()
										return
									}
									
									switch result {
										case .success(let insurance):
											flow.showClinicsWithFilterId(filterId, for: insurance, mode: .push)
											
										case .failure(let error):
											ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
											
									}
									
									self.handleLockCompletion(for: action)
									syncCompletion?()
								}
							} else {
								flow.start(insuranceId: insuranceId, mode: .push)
								
								self.handleLockCompletion(for: action)
								syncCompletion?()
							}
						}
						
					case .actionFlowGaranteeLetters:
						if let action = action as? GaranteeLettersActionDTO,
						   let insuranceId = action.insuranceId {
							insurancesService.insurance(useCache: true, id: insuranceId) { [weak viewController] result in
								guard let viewController
								else {
									
									self.handleLockCompletion(for: action)
									syncCompletion?()
									return
								}
								
								switch result {
									case .success(let insurance):
										let guaranteeLettersFlow = GuaranteeLettersFlow(rootController: viewController)
										self.container?.resolve(guaranteeLettersFlow)
										
										guaranteeLettersFlow.createGuaranteeLetters(
											insurance: insurance,
											from: viewController
										) { result in
											switch result {
												case .success(let guaranteLEttersController):
													viewController.navigationController?.pushViewController(guaranteLEttersController, animated: true)
												case .failure:
													break
											}
											
											self.handleLockCompletion(for: action)
											syncCompletion?()
										}
										
									case .failure(let error):
										ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
										
										self.handleLockCompletion(for: action)
										syncCompletion?()
								}
							}
						}
						
					case .actionFlowDoctorAppointments:
						if let action = action as? DoctorAppointmentsFlowActionDTO,
						   let insuranceId = action.insuranceId {
							
							showDoctorApointments(for: insuranceId, from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}
						
					case .actionFlowChat:
						if let action = action as? ChatFlowActionDTO {
							openChatFullscreen(from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}
						
					case .actionFlowNotifications:
						if let action = action as? NotificationsListActionDTO {
							showNotificationsScreen()
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}
						
					case .actionScreenRender:
						if let action = action as? ScreenRenderActionDTO {
							guard let screen = action.screen?()
							else {
								self.handleLockCompletion(for: action)
								syncCompletion?()
								return
							}
							
							if BackendComponentType.screenBottomToolbar == screen.type
								|| BackendComponentType.screenBasic == screen.type  {
								
								let screenViewController = BDUI.ViewControllerUtils.createBasicBackendDrivenViewController(
									with: screen,
									use: backendDrivenService,
									use: analytics,
									backendActionSelectorHandler: { events, viewController in
										guard let viewController
										else { return }
										
										self.handleBackendAction(
											events,
											on: viewController,
											with: screen.screenId,
											isModal: screen.showType == .vertical,
											syncCompletion: {
												self.handleLockCompletion(for: action)
												syncCompletion?()
											}
										)
									},
									syncCompletion: {
										self.handleLockCompletion(for: action)
										syncCompletion?()
									}	// sync completion for screen call calling from didAppear
								)
								
								self.show(screenViewController, isModal: screen.showType == .vertical, from: viewController)
							} else {
								let screenViewController = BDUI.ViewControllerUtils.createModalBackendDrivenViewController(
									with: screen,
									backendActionSelectorHandler: { events, viewController in
										guard let viewController
										else { return }
										
										self.handleBackendAction(
											events,
											on: viewController,
											with: screen.screenId,
											isModal: true,
											syncCompletion: {
												self.handleLockCompletion(for: action)
												syncCompletion?()
											}
										)
									},
									syncCompletion: {
										self.handleLockCompletion(for: action)
										syncCompletion?()
									}	// sync completion for screen call calling from didAppear
								) as? ActionSheetContentViewController
								
								if let screenViewController{
									let actionSheetViewController = ActionSheetViewController(with: screenViewController)
									actionSheetViewController.enableDrag = true
									actionSheetViewController.enableTapDismiss = false
									viewController.present(actionSheetViewController, animated: true)
								}
							}
						}
						
					case .actionMulti:
						if let multiAction = action as? MultipleActionsActionDTO,
						   let actions = multiAction.actions {
							/// recursevly handle actions
							for (index, action) in actions.enumerated() {
								if let mode = action.mode {
									switch action.type {
										case .actionLayoutReplaceAsync, .actionLayoutReplace, .actionLayoutFilter:
											break
											
										default:
											BDUI.ActionExecutionSynchronization.proceed(
												priority: index,
												with: mode,
												actionName: action.name ?? "undefined",
												action: { syncCompletion in
													if let topViewController = BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.viewController as? ViewController {
														handle(action, on: topViewController, syncCompletion: syncCompletion)
													} else {
														ErrorHelper.show(error: AlfastrahError.unknownError, alertPresenter: self.alertPresenter)
													}
												}
											)
									}
									
								}
								
								switch action.type {
									case .actionLayoutReplaceAsync, .actionLayoutReplace, .actionLayoutFilter:
										break
										
									default:
										if index == actions.endIndex - 1 {
											BDUI.ActionExecutionSynchronization.startActions {
												self.handleLockCompletion(for: multiAction)
												syncCompletion?()
											}
										}
								}
							}
						}
						
					case .actionActionRequest:
						if let action = action as? BDUI.ActionRequestActionDTO,
						   let request = action.request {
							BDUI.CommonActionHandlers.shared.handleActionRequest(
								action,
								request,
								handleEvent: { events in
									self.handleBackendAction(
										events,
										on: viewController,
										with: nil,
										isModal: isModal,
										syncCompletion: {
											self.handleLockCompletion(for: action)
											syncCompletion?()
										}
									)
								}
							)
						}
						
						// NB! sync action request will only complete when the nested action completes
						
					case .actionLayoutReplaceAsync, .actionLayoutReplace, .actionLayoutFilter:
						// NB! Do not handle actions here except actions for navigation or screen render
						break
						
					case .actionWebView:
						if let action = action as? WebViewActionDTO,
						   let event = action.event {
							if let url = event.url {
								WebViewer.openDocument(
									url,
									withAuthorization: false,	// NB!  not use default headers from global authorizer
									showShareButton: event.publicUrl != nil ? true : false,
									urlShareable: event.publicUrl,
									from: viewController,
									customHeaders: event.headers
								)
							}
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}
						
					case .actionFlowLoyalty:
						if let action = action as? LoyaltyFlowActionDTO {
							ApplicationFlow.shared.show(item: .alfaPoints)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}
						
					case .actionFlowDoctorAppointment:
						if let action = action as? DoctorAppointmentFlowActionDTO,
						   let insuranceId = action.insuranceId,
						   let appointmentId = action.appointmentId	{
							insurance(
								by: insuranceId,
								from: viewController
							) { [weak viewController] insurance in
								guard let viewController
								else {
									self.handleLockCompletion(for: action)
									syncCompletion?()
									return
								}
								
								let flow = CommonClinicAppointmentFlow(rootController: viewController)
								self.container?.resolve(flow)
								flow.start(futureDoctorVisitId: String(appointmentId), insurance: insurance, mode: .modal)
								
								self.handleLockCompletion(for: action)
								syncCompletion?()
							}
						}
						
					case .actionNavigateBack:
						if let action = action as? NavigateBackToActionDTO,
						   let screenId = action.screenId {
							BDUI.CommonActionHandlers.shared.navigateBack(to: screenId) {
								self.handleLockCompletion(for: action)
								syncCompletion?()
							}
							
						} else {
							// NB: For sync naviagation-back operations only - we can be sure that the operation has completed synchronously
							// only when the current viewController has been disposed
							
							if let bduiViewController = viewController as? ScreenBasicViewController {
								bduiViewController.destructCallback = {
									self.handleLockCompletion(for: action)
									syncCompletion?()
								}
							}
							
							if isModal {
								viewController.dismiss(animated: true) {
									self.handleLockCompletion(for: action)
									syncCompletion?()
								}
							} else {
								if let navigationController = viewController.navigationController {
									if navigationController.viewControllers.count == 1 {
										viewController.dismiss(animated: true) {
											self.handleLockCompletion(for: action)
											syncCompletion?()
										}
									} else {
										navigationController.popViewController(animated: true)
										self.handleLockCompletion(for: action)
										syncCompletion?()
									}
								}
							}
						}

					case  .localActionStories:
						if let action = action as? LocalStoriesActionDTO,
						   let selectedStory = action.selectedStory {
							let storiesFlow = StoriesFlow(rootController: viewController)
							self.container?.resolve(storiesFlow)
							storiesFlow.start(
								selectedStoryIndex: selectedStory.0,
								stories: selectedStory.1,
								viewedStoriesPage: selectedStory.2,
								completion: selectedStory.3
							)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionPhone:
						if let action = action as? PhoneActionDTO,
						   let phone = action.phone {
							showCallNumberActionSheet(phone: phone, viewController: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionScreenRequest:
						if let action = action as? ScreenRequestActionDTO,
						   let request = action.request {
							guard request.url != nil
							else {
								self.handleLockCompletion(for: action)
								syncCompletion?()
								
								ErrorHelper.show(error: AlfastrahError.unknownError, alertPresenter: self.alertPresenter)
								return
							}
							
							showRequestBackendDrivenViewController(
								action: action,
								from: viewController,
								request: request,
								syncCompletion: syncCompletion
							)
						}

					case .actionFlowInsurance:
						if let action = action as? InsuranceFlowActionDTO,
						   let insuranceId = action.insuranceId {
							showInsurance(with: insuranceId, from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionFlowBills:
						if let action = action as? BillsFlowActionDTO,
						   let insuranceId = action.insuranceId {
							insurance(by: insuranceId, from: viewController) { [weak viewController] insurance in
								guard let viewController
								else { return }
								
								self.showInsuranceBills(insurance: insurance, from: viewController)
								
								self.handleLockCompletion(for: action)
								syncCompletion?()
							}
						}

					case .actionFlowInstruction:
						if let action = action as? InstructionFlowActionDTO,
						   let categoryId = action.categoryId {
							let hide = viewController.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
							
							self.insurancesService.insurances(useCache: true) { [weak viewController] result in
								hide(nil)
								
								guard let viewController
								else {
									self.handleLockCompletion(for: action)
									syncCompletion?()
									return
								}
								
								switch result {
									case .success(let response):
										let instructions = response.sosList.flatMap {
											$0.instructionList.filter { $0.insuranceCategoryId == categoryId }
										}
										self.showInstructionsList(instructions: instructions, fromVC: viewController)
										
									case .failure(let error):
										ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
										
								}
								
								self.handleLockCompletion(for: action)
								syncCompletion?()
							}
						}

					case .actionFlowBillsPay:
						if let action = action as? BillsPayFlowActionDTO,
						   let insuranceId = action.insuranceId,
						   let billIds = action.billIds {
							insurance(by: insuranceId, from: viewController) { [weak viewController] insurance in
								guard let viewController
								else {
									self.handleLockCompletion(for: action)
									syncCompletion?()
									return
								}
								
								let insuranceBillsFlow = InsuranceBillsFlow(rootController: viewController)
								self.container?.resolve(insuranceBillsFlow)
								
								insuranceBillsFlow.showPaymentBills(for: insurance, with: billIds, from: viewController)
								
								self.handleLockCompletion(for: action)
								syncCompletion?()
							}
						}

					case .actionFlowBill:
						if let action = action as? BillFlowActionDTO,
						   let insuranceId = action.insuranceId,
						   let billId = action.billId {
							ApplicationFlow.shared.show(item: .insuranceBill(insuranceId, billId))
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionFlowActivation:
						if let action = action as? ActivationFlowActionDTO {
							openActivateInsurance(from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionFlowFindInsurance:
						if let action = action as? FindInsuranceFlowActionDTO {
							searchInsuranceModal(from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}
						
					case .actionFlowProducts:
						if let action = action as? ProductsFlowActionDTO {
							ApplicationFlow.shared.show(item: .tabBar(.products))
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}
						
					case .actionFlowDraftCalculations:
						if let action = action as? DraftCalculationsActionDTO {
							let draftFlow = DraftsCalculationsFlow(rootController: viewController)
							self.container?.resolve(draftFlow)
							draftFlow.start()
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionFlowQuestions:
						if let action = action as? QuestionsFlowActionDTO {
							openFaq()
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionFlowQuestion:
						if let action = action as? QuestionFlowActionDTO,
						   let questionId = action.questionId {
							openQuestion(by: questionId, from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionMainPageToNativeRender:
						if let action = action as? MainPageToNativeRenderActionDTO {
							ApplicationFlow.shared.reloadHomeTab()
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionFlowOffices:
						if let action = action as? OfficesFlowActionDTO {
							showOffices(from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionDraftDelete:
						if let action = action as? DeleteDraftActionDTO,
						   let id = action.id {
							self.deleteDraft(with: id, on: viewController) {}
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionFlowEventReportNS:
						if let action = action as? EventReportNsFlowActionDTO,
						   let insuranceId = action.insuranceId {
							showAccidentEventReport(for: insuranceId, from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionFlowEventReportOsago:
						if let action = action as? EventReportOsagoFlowActionDTO,
						   let insuranceId = action.insuranceId {
							showAutoEvent(for: insuranceId, from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionFlowEventReportKasko:
						if let action = action as? EventReportKaskoFlowActionDTO,
						   let insuranceId = action.insuranceId {
							showAutoEvent(for: insuranceId, from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionFlowEuroprotocolOsago:
						if let action = action as? EuroprotocolOsagoFlowActionDTO,
						   let insuranceId = action.insuranceId {
							showEuroProtocol(for: insuranceId, from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}
						
					case .actionFlowInternetCall:
						if let action = action as? InternetCallActionDTO,
						   let voipCall = action.voipCall {
							showVoipCall(with: voipCall, from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}
					case
						.actionFlowProlongationKasko,
						.actionFlowProlongationOsago,
						.actionFlowProlongationAlfaRepair,
						.actionFlowProlongationKindNeighbors:
						
						var insuranceId: String?
						
						if let action = action as? ProlongationKaskoFlowActionDTO {
							insuranceId = action.insuranceId
						} else if let action = action as? ProlongationOsagoFlowActionDTO {
							insuranceId = action.insuranceId
						} else if let action = action as? ProlongationAlfaRepairFlowActionDTO {
							insuranceId = action.insuranceId
						} else if let action = action as? ProlongationKindNeighborsFlowActionDTO {
							insuranceId = action.insuranceId
						}
								
						if let insuranceId {
							prolongForInsurance(with: insuranceId, from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}
							
					case .actionFlowDoctorHomeRequest:
						if let action = action as? DoctorHomeRequestFlowActionDTO,
						   let doctorCall = action.doctorCall {
							let interactiveSupportFLow = InteractiveSupportFlow(rootController: viewController)
							self.container?.resolve(interactiveSupportFLow)
							
							interactiveSupportFLow.showDoctorCallQuestionnaireBDUI(doctorCall: doctorCall)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionAlert:
						if let action = action as? AlertActionDTO,
						   let alert = action.alert {
							self.showAlert(alert, from: viewController, completion: { action in
								handle(action, on: viewController, syncCompletion: nil)
							})
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionEditProfile:
						if let action = action as? EditProfileActionDTO {
							editProfile(from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}
						
					case .actionFlowChangeSessionType:
						if let action = action as? ChangeSessionTypeFlowActionDTO,
						   let accountType = action.accountType {
							switchAccountType(to: accountType, from: viewController) {
								self.self.handleLockCompletion(for: action)
								syncCompletion?()
							}
						}

					case .actionFlowExit:
						if let action = action as? ExitFlowActionDTO {
							userLogout(from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionFlowAboutApp:
						if let action = action as? AboutAppFlowActionDTO {
							aboutApp()
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionFlowAppSettings:
						if let action = action as? AppSettingsFlowActionDTO {
							appSettings()
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}
						
					case .actionFlowTheme:
						if let action = action as? ThemeFlowActionDTO {
							switchTheme(from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionFlowViewEventReportsAuto:
						if let action = action as? ViewEventReportsAutoFlowActionDTO {
							showAutoEvents(from: viewController)
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionScreenReplace:
						if let action = action as? ScreenReplaceActionDTO,
						   let screenId = action.screenId,
						   let screen = action.screen {
							self.handleLockCompletion(for: action)
							syncCompletion?()
							
							BDUI.CommonActionHandlers.shared.replace(
								screen: screen,
								forScreenId: screenId,
								logger: logger
							)
						}

					case .actionFlowOsagoPhotoUpload:
						if let action = action as? OsagoPhotoUploadFlowActionDTO,
						   let picker = action.picker {
							resetOsagoPhotoPickerForNewAction()
							
							showAutoEventPhotosSheet(picker: picker, from: viewController) { [ weak viewController ] in
								guard let viewController
								else { return }
								
								FormDataOperations.replaceFormData(
									for: events,
									with: self.pickedFileIds,
									action: { [weak viewController] events in
										guard let viewController,
											  let action = events.onTap
										else { return }
										
										handle(action, on: viewController, syncCompletion: syncCompletion)
									}
								)
								
								self.resetOsagoPhotoPickerForNewAction()
							}
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}

					case .actionFlowOsagoSchemeAuto:
						if let action = action as? OsagoSchemeAutoFlowActionDTO,
						   let picker = action.picker {
							showAutoEventDamagedPartsSheet(
								picker: picker,
								from: viewController
							) { [ weak viewController ] ids in
								guard let viewController
								else { return }
								
								FormDataOperations.replaceFormData(
									for: events,
									with: ids,
									action: { [weak viewController] events in
										guard let viewController,
											  let action = events.onTap
										else { return }
										
										handle(action, on: viewController, syncCompletion: syncCompletion)
									}
								)
							}
							
							self.handleLockCompletion(for: action)
							syncCompletion?()
						}
						
					default:
						self.handleLockCompletion(for: action)
						syncCompletion?()
						
				}
			}
			
			container?.resolve(viewController)
			
			if let tapAction = events.onTap {
				print("action lock behaviour \(events.onTap?.lockBehavior?.rawValue) in method \(events.onTap?.type.rawValue)")
				
				handle(tapAction, on: viewController, syncCompletion: syncCompletion)
			}
			
			if let renderAction = events.onRender {
				print("action lock behaviour \(events.onRender?.lockBehavior?.rawValue) in method \(events.onRender?.type.rawValue)")
				
				handle(renderAction, on: viewController, syncCompletion: syncCompletion)
			}
		}
		
		// MARK: - Osago Auto Event
		private func showAutoEventDamagedPartsSheet(
			picker: OsagoSchemeAutoPickerComponentDTO?,
			from: ViewController,
			completion: @escaping ([Int]) -> Void
		) {
			let viewController = AutoEventDetailsPickerViewController()
			container?.resolve(viewController)
			
			viewController.input = .init(
				picker: picker
			)
			
			viewController.output = .init(
				partsSelected: { [weak viewController] selectedParts in
					let partsIds = selectedParts.compactMap { $0.id }
					
					viewController?.dismiss(animated: true) {
						completion(partsIds)
					}
				}
			)
			
			let navigationController = RMRNavigationController(rootViewController: viewController)
			navigationController.strongDelegate = RMRNavigationControllerDelegate()
			
			viewController.addCloseButton(position: .right) { [weak viewController] in
				viewController?.dismiss(animated: true)
			}
			
			from.present(
				navigationController,
				animated: true
			)
		}
		
		// MARK: - Osago Photo Picker
		private func showAutoEventPhotosSheet(
			picker: OsagoPhotoUploadPickerComponentDTO?,
			from: ViewController,
			completion: @escaping () -> Void
		) {
			inputEntryFiles(picker?.input)
			
			let viewController = AutoEventPhotosPickerViewController()
			ApplicationFlow.shared.container.resolve(viewController)
			
			viewController.input = .init(
				picker: picker,
				fileEntries: {
					return self.osagoFilePickerEntries
				}
			)
			
			viewController.output = .init(
				addPhoto: { [weak viewController, weak from] in
					viewController?.dismiss(animated: true) { [weak from] in
						guard let from
						else { return }
						
						self.filePicker(picker: picker, from: from, completion: completion)
					}
				},
				showPhoto: {
					
				},
				deletePhoto: { attachment in
					if let entryIndex = self.osagoFilePickerEntries.firstIndex(where: {
						$0.attachment?.id == attachment.id
					}) {
						self.osagoFilePickerEntries.remove(at: entryIndex)
					}
				},
				close: { [weak viewController] in
					viewController?.dismiss(animated: true) {
						self.resetOsagoPhotoPickerForNewAction()
					}
				},
				save: { [weak viewController] in
					viewController?.dismiss(animated: true) {
						completion()
					}
				}
			)
			
			from.present(viewController, animated: false)
		}
		
		private func filePicker(
			picker: OsagoPhotoUploadPickerComponentDTO?,
			from: ViewController,
			completion: @escaping () -> Void
		) {
			if picker?.canSelectFromSavedPhotos ?? false {
				self.showFilePickerSourceSelectionAlert(from: from) { [weak from] source in
					guard let from
					else { return }
					
					switch source {
						case .camera:
							if self.insructionForOsagoPhotoPickerWasShown {
								self.showCameraPicker(from: from) { [weak from] in
									guard let from
									else { return }
									
									if self.currentFilePickerFileEntry != nil {
										self.showOsagoPhotoUploadConfirm(for: picker?.uploadUrl, from: from) { [weak from] in
											guard let from
											else { return }
											
											if let currentFilePickerFileEntry = self.currentFilePickerFileEntry {
												self.osagoFilePickerEntries.append(currentFilePickerFileEntry)
												
												self.uploadPhoto(to: picker?.uploadUrl, from: currentFilePickerFileEntry)
											}
											
											self.showAutoEventPhotosSheet(picker: picker, from: from, completion: completion)
										}
									}
								}
							} else {
								self.showPhotoInstruction(picker: picker, from: from) { [weak from] in
									guard let from
									else { return }
									
									self.insructionForOsagoPhotoPickerWasShown = true
									self.showAutoEventPhotosSheet(picker: picker, from: from, completion: completion)
								}
							}
						case .gallery:
							self.showGalleryPicker(from: from) { [weak from] in
								guard let from,
									  !self.galleryFilePickerFileEntries.isEmpty
								else { return }
								
								self.osagoFilePickerEntries.append(contentsOf: self.galleryFilePickerFileEntries)
								
								for entry in self.osagoFilePickerEntries {
									self.uploadPhoto(to: picker?.uploadUrl, from: entry)
								}
								
								self.showAutoEventPhotosSheet(picker: picker, from: from, completion: completion)
							}
							
						default:
							break
					}
				}
			} else {
				if self.insructionForOsagoPhotoPickerWasShown {
					self.showCameraPicker(from: from) { [weak from] in
						guard let from
						else { return }
						
						if self.currentFilePickerFileEntry != nil {
							self.showOsagoPhotoUploadConfirm(for: picker?.uploadUrl, from: from) { [weak from] in
								guard let from
								else { return }
								
								if let currentFilePickerFileEntry = self.currentFilePickerFileEntry {
									self.osagoFilePickerEntries.append(currentFilePickerFileEntry)
									
									self.uploadPhoto(to: picker?.uploadUrl, from: currentFilePickerFileEntry)
								}
								
								self.showAutoEventPhotosSheet(picker: picker, from: from, completion: completion)
							}
						}
					}
				} else {
					self.showPhotoInstruction(picker: picker, from: from) { [weak from] in
						guard let from
						else { return }
						
						if let currentFilePickerFileEntry = self.currentFilePickerFileEntry {
							self.osagoFilePickerEntries.append(currentFilePickerFileEntry)
							
							self.uploadPhoto(to: picker?.uploadUrl, from: currentFilePickerFileEntry)
						}
						
						self.insructionForOsagoPhotoPickerWasShown = true
						self.showAutoEventPhotosSheet(picker: picker, from: from, completion: completion)
					}
				}
			}
		}
		
		private func inputEntryFiles(_ inputEntries: [InputEntryOsagoUploadPickerComponentDTO]?) {
			guard let inputEntries
			else { return }
			
			for entry in inputEntries {
				var attachment: FileAttachment?
				
				if let url = entry.url {
					attachment = FileAttachment(
						originalName: url.filename,
						filename: url.filename,
						url: url
					)
				}
				
				let fileEntry = FilePickerFileEntry(state: .processing(previewUrl: entry.url, attachment: attachment, type: .downloading))
				
				SDWebImageManager.shared.loadImage(
					with: entry.url,
					options: .highPriority,
					progress: nil,
					completed: { _, _, error, _, _, _ in
						fileEntry.state = error == nil
						? .ready(previewUrl: entry.url, attachment: attachment)
						: .error(previewUrl: entry.url, attachment: attachment, type: .downloading)
					}
				)
				
				osagoFilePickerEntries.append(fileEntry)
			}
		}
		
		private var osagoFilePickerEntries: [FilePickerFileEntry] = []
		private var pickedFileIds: [Int] = []
		private var currentFilePickerFileEntry: FilePickerFileEntry?
		private var galleryFilePickerFileEntries: [FilePickerFileEntry] = []
		private var insructionForOsagoPhotoPickerWasShown: Bool = false
		
		private func resetOsagoPhotoPickerForNewAction() {
			insructionForOsagoPhotoPickerWasShown = false
			currentFilePickerFileEntry = nil
			osagoFilePickerEntries.removeAll()
			pickedFileIds.removeAll()
		}
		
		private func showPhotoInstruction(
			picker: OsagoPhotoUploadPickerComponentDTO?,
			from: ViewController,
			completion: @escaping () -> Void
		) {
			let viewController = AutoEventPhotoAttachmentInstructionsViewController()
			
			viewController.input = .init(
				picker: picker
			)
			
			viewController.output = .init(
				createPhoto: {
					self.showCameraPicker(from: viewController) { [weak viewController] in
						guard let viewController
						else { return }
						
						if self.currentFilePickerFileEntry != nil {
							self.showOsagoPhotoUploadConfirm(
								for: picker?.uploadUrl,
								from: viewController
							) { [weak viewController] in
								viewController?.navigationController?.dismiss(animated: true) {
									completion()
								}
							}
						}
					}
				}
			)
			
			viewController.addCloseButton(position: .right) { [weak viewController] in
				viewController?.navigationController?.dismiss(animated: true) {
					completion()
				}
			}
			
			let navigationController = RMRNavigationController()
			navigationController.strongDelegate = RMRNavigationControllerDelegate()
			
			navigationController.setViewControllers([ viewController ], animated: true)
			from.present(navigationController, animated: true, completion: nil)
		}
		
		private func showCameraPicker(
			from: ViewController,
			completion: @escaping () -> Void
		) {
			Permissions.camera { [weak from] granted in
				guard granted, let from
				else { return }
				
				let configuration = FilePicker.Configuration(
					compressionTargetSize: 5 * 1024 * 1024,
					maxFilesCount: 1,
					compressionRatio: 0.3,
					maxFileSize: 25 * 1024 * 1024
				)
				
				if let picker = FilePicker.shared.pick(
					from: .camera,
					with: configuration,
					filesSelected: { [weak from] entries in
						guard let from
						else { return }
						
						self.currentFilePickerFileEntry = entries.last
						
						if self.insructionForOsagoPhotoPickerWasShown {
							from.presentedViewController?.dismiss(animated: true) {
								completion()
							}
						} else {
							completion()
						}
					},
					dismissCompletion: { [weak from] in
						guard let from
						else { return }
					},
					on: from
				) {
					from.present(picker, animated: true)
				}
			}
		}
		
		private func showGalleryPicker(
			from: ViewController,
			completion: @escaping () -> Void
		) {
			func galleryPicker(from: ViewController, completion: @escaping () -> Void) {
				let configuration = FilePicker.Configuration(
					compressionTargetSize: 5 * 1024 * 1024,
					maxFilesCount: 20,
					compressionRatio: 0.3,
					maxFileSize: 25 * 1024 * 1024
				)
				
				if let picker = FilePicker.shared.pick(
					from: .gallery,
					with: configuration,
					filesSelected: { [weak from] entries in
						guard let from
						else { return }
						
						self.galleryFilePickerFileEntries.append(contentsOf: entries)
					},
					dismissCompletion: { [weak from] in
						guard let from
						else { return }
						
						completion()
					},
					on: from
				) {
					from.present(picker, animated: true)
				}
			}
			
			if #available(iOS 14.0, *) {
				Permissions.photoLibrary(for: .readWrite) { [weak from] granted in
					guard granted, let from
					else { return }
					
					galleryPicker(from: from, completion: completion)
				}
			} else {
				galleryPicker(from: from, completion: completion)
			}
		}
		
		private func showOsagoPhotoUploadConfirm(for uploadUrl: URL?, from: ViewController, completion: @escaping () -> Void) {
			guard let currentFilePickerFileEntry,
				  let uploadUrl
			else { return }
			
			let viewController = AutoEventPhotoAttachmentConfirmationViewController()
			
			viewController.input = .init(
				lastTakedPhotoEntry: currentFilePickerFileEntry
			)
			
			viewController.output = .init(
				retakePhoto: { [weak from, weak viewController] in
					guard let from,
						  let viewController
					else { return }
					
					self.showCameraPicker(
						from: from
					) { [weak viewController] in
						viewController?.notify.reload(self.currentFilePickerFileEntry)
					}
				},
				savePhoto: { [weak viewController] in
					if self.insructionForOsagoPhotoPickerWasShown {
						viewController?.dismiss(animated: true) {
							completion()
						}
					} else {
						completion()
					}
				}
			)
			
			if self.insructionForOsagoPhotoPickerWasShown {
				viewController.addBackButton { [weak viewController] in
					viewController?.navigationController?.dismiss(animated: true) {
						completion()
					}
				}
				
				viewController.addCloseButton(position: .right) { [weak viewController] in
					viewController?.navigationController?.dismiss(animated: true) {
						completion()
					}
				}
				
				let navigationController = RMRNavigationController()
				navigationController.strongDelegate = RMRNavigationControllerDelegate()
				
				navigationController.setViewControllers([ viewController ], animated: true)
				from.present(navigationController, animated: true)
			} else {
				from.navigationController?.pushViewController(viewController, animated: true)
			}
		}
		
		private func uploadPhoto(to uploadUrl: URL?, from fileEntry: FilePickerFileEntry) {
			if let uploadUrl {
				self.backendDrivenService.upload(
					fileEntry: fileEntry,
					to: uploadUrl
				) { result in
					switch result {
						case .success(let fileId):
							self.pickedFileIds.append(fileId)
							
						case .failure(let error):
							ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
							
					}
				}
			}
		}
		
		private func showInsurance(with id: String, from: ViewController) {
			let flow = InsurancesFlow()
			container?.resolve(flow)
			
			let hide = from.showLoadingIndicator(
				message: NSLocalizedString("common_load", comment: "")
			)
			
			insurancesService.insurance(useCache: true, id: id) { result in
				hide(nil)
				switch result {
					case .success(let insurance):
						flow.showInsurance(id: id, from: from, isModal: true, kind: insurance.type)
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
				}
			}
		}
		
		private func showDoctorApointments(for insuranceId: String, from: ViewController) {
			let flow = InsurancesFlow()
			container?.resolve(flow)
			flow.fromViewController = from
			flow.showDoctorAppointments(for: insuranceId, from: from)
		}
		
		private func showNotificationsScreen() {
			guard let controller = initialViewController.topViewController
			else { return }
			
			guard !accountService.isDemo else {
				DemoAlertHelper().showDemoAlert(from: controller)
				return
			}
			
			let flow = NotificationsFlow(rootController: controller)
			container?.resolve(flow)
			flow.showList(mode: .modal)
		}
		
		private func insurance(
			by insuranceId: String,
			from: ViewController,
			completion: @escaping (Insurance) -> Void
		) {
			let hide = from.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
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
		
		private func showAlert(
			_ alert: AlertComponentDTO,
			from: ViewController,
			completion: @escaping (ActionDTO) -> Void
		) {
			let actionSheet = UIAlertController(
				title: alert.title,
				message: alert.description,
				preferredStyle: .alert
			)
			
			if let buttons = alert.buttons {
				buttons.forEach { alertButton in
					actionSheet.addAction(
						UIAlertAction(
							title: alertButton.title,
							style: {
								switch $0.style {
									case .`default`, .none:
										return .default
										
									case .destructive:
										return .destructive
										
									case .cancel:
										return .cancel
										
								}
							} (alertButton),
							handler: { _ in
								guard let action = alertButton.action
								else { return }
								
								completion(action)
							}
						)
					)
				}
			}
			
			from.present(
				actionSheet,
				animated: true
			)
		}
		
		private func showCallNumberActionSheet(
			phone: PhoneComponentDTO,
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
		
		private func showFilePickerSourceSelectionAlert(
			from: ViewController,
			completion: @escaping (FilePickerSource) -> Void
		) {
			let actionSheet = UIAlertController(
				title: nil,
				message: nil,
				preferredStyle: .actionSheet
			)
			
			let cameraPickerAction = UIAlertAction(
				title: NSLocalizedString("bdui_osago_alert_filesource_camera", comment: ""),
				style: .default
			) { _ in
				
				completion(.camera)
			}
			actionSheet.addAction(cameraPickerAction)
			
			let galleryPickerAction = UIAlertAction(
				title: NSLocalizedString("bdui_osago_alert_filesource_gallery", comment: ""),
				style: .default,
				handler: { _ in
					completion(.gallery)
				}
			)
			
			actionSheet.addAction(galleryPickerAction)
			
			let cancel = UIAlertAction(
				title: NSLocalizedString(
					"common_cancel_button",
					comment: ""
				),
				style: .cancel,
				handler: nil
			)
			
			actionSheet.addAction(cancel)
			
			from.present(
				actionSheet,
				animated: true
			)
		}
		
		func show(_ viewController: ViewController, isModal: Bool, from: ViewController) {
			func showModally() {
				let navigationController = RMRNavigationController()
				navigationController.strongDelegate = RMRNavigationControllerDelegate()
				
				navigationController.setViewControllers([ viewController ], animated: true)
				from.present(navigationController, animated: true, completion: nil)
			}
			
			if isModal {
				showModally()
			} else {
				if initialViewController == from.navigationController { // over tabbar
					showModally()
				} else {
					from.navigationController?.pushViewController(viewController, animated: true)
				}
			}
		}
		
		private func showRequestBackendDrivenViewController(
			action: BDUI.ActionDTO,
			from: ViewController,
			request: RequestComponentDTO,
			syncCompletion: (() -> Void)?
		) {
			func createController(with result: Result<ContentWithInfoMessage, AlfastrahError>, from: ViewController) {
				switch result {
					case .success(let data):
						if let infoMessage = data.infoMessage {
							BDUI.ViewControllerUtils.showInfoMessageViewController(
								with: infoMessage,
								from: from,
								retryOperationCallback: {
									self.backendDrivenService.bduiObject(
										needPostData: false,
										addTimezoneParameter: false,
										formData: nil,
										for: request,
										completion: { [weak from] result in
											guard let from
											else { return }
											
											createController(with: result, from: from)
										}
									)
								}
							)
						} else {
							let screen = ScreenComponentDTO(body: data.content)
							
							switch screen.showType {
								case .horizontal, .vertical, .none:
									let viewController = BDUI.ViewControllerUtils.createBasicBackendDrivenViewController(
										with: screen,
										use: backendDrivenService,
										use: analytics,
										backendActionSelectorHandler: { events, viewController in
											guard let viewController
											else { return }
											
											self.handleBackendAction(
												events,
												on: viewController,
												with: screen.screenId,
												isModal: screen.showType == .vertical,
												syncCompletion: syncCompletion
											)
										},
										syncCompletion: syncCompletion
									)
									
									show(viewController, isModal: screen.showType ?? .vertical == .vertical, from: from)
								case .modal:
									let screenViewController = BDUI.ViewControllerUtils.createModalBackendDrivenViewController(
										with: screen,
										backendActionSelectorHandler: { events, viewController in
											guard let viewController
											else { return }
											
											self.handleBackendAction(
												events,
												on: viewController,
												with: screen.screenId,
												isModal: true,
												syncCompletion: syncCompletion
											)
										},
										syncCompletion: syncCompletion	// sync completion for screen call calling from didAppear
									) as? ActionSheetContentViewController
									
									if let screenViewController{
										let actionSheetViewController = ActionSheetViewController(with: screenViewController)
										actionSheetViewController.enableDrag = true
										actionSheetViewController.enableTapDismiss = false
										from.present(actionSheetViewController, animated: true)
									}
							}
						}
						
					case .failure(let error):
						switch error {
							case .api, .network, .error:
								ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
								
							case .infoMessage(let infoMessage):
								BDUI.ViewControllerUtils.showInfoMessageViewController(
									with: infoMessage,
									from: from,
									retryOperationCallback: {
										self.backendDrivenService.bduiObject(
											needPostData: false,
											addTimezoneParameter: false,
											formData: nil,
											for: request,
											completion: { [weak from] result in
												guard let from
												else { return }
												
												createController(with: result, from: from)
											}
										)
									}
								)
						}
				}
			}
			
			self.backendDrivenService.bduiObject(
				needPostData: action.postDataNeedToSend,
				addTimezoneParameter: false,
				formData: nil,
				for: request,
				completion: { result in
					func handleResult(from: ViewController) {
						if !self.handleLockCompletion(
							for: action,
							completion: {
								createController(with: result, from: from)
							}
						) {
							createController(with: result, from: from)
						}
					}
					
					if let topViewController = BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.viewController as? ViewController {
						handleResult(from: topViewController)
					} else {
						ErrorHelper.show(error: AlfastrahError.unknownError, alertPresenter: self.alertPresenter)
					}
				}
			)
		}
		
		private func openFaq() {
			guard let controller = initialViewController.topViewController as? ViewController
			else { return }
			
			let flow = QAFlow(rootController: controller)
			container?.resolve(flow)
			flow.startModaly()
		}
		
		private func openQuestion(by questionId: Int, from viewController: ViewController) {
			self.questionService.questionList(useCache: true) { [weak viewController] result in
				guard let viewController
				else { return }
				
				switch result {
					case .success(let categories):
						let questionList = categories.flatMap {
							$0.questionGroupList.flatMap {
								$0.questionList
							}
						}
						
						if let question = questionList.first(where: { $0.id == String(questionId) }) {
							let flow = QAFlow(rootController: viewController)
							self.container?.resolve(flow)
							flow.showQuestion(question, from: viewController)
						} else {
							ErrorHelper.show(error: AlfastrahError.unknownError, alertPresenter: self.alertPresenter)
						}
						
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
				}
			}
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
		
		private func showMedicalCard(
			from: UIViewController
		) {
			let medicalCardFlow = MedicalCardFlow(rootController: from)
			self.container?.resolve(medicalCardFlow)
			medicalCardFlow.start()
		}
		
		private func showTelemedicineInfo(insurance: Insurance, from: ViewController) {
			let viewController: TelemedicineInfoViewController =  UIStoryboard(name: "Insurances", bundle: nil).instantiate()
			container?.resolve(viewController)
			// swiftlint:disable:next trailing_closure
			viewController.output = TelemedicineInfoViewController.Output(
				telemedicine: { [weak viewController] in
					guard let controller = viewController else { return }
					
					self.showTelemedicine(insurance: insurance, from: controller)
				}
			)
			from.navigationController?.pushViewController(viewController, animated: true)
		}
		
		private func showTelemedicine(insurance: Insurance, from controller: ViewController) {
			let hide = controller.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
			
			insurancesService.telemedicineUrl(insuranceId: insurance.id) { result in
				hide(nil)
				switch result {
					case .success(let url):
						UIApplication.shared.open(url, options: [:], completionHandler: nil)
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: controller.alertPresenter)
				}
			}
		}
		
		private func openActivateInsurance(from: ViewController) {
			let flow = ActivateProductFlow()
			container?.resolve(flow)
			flow.startModally(from: from)
		}
		
		private func openChatFullscreen(from: ViewController) {
			let chatFlow = ChatFlow()
			container?.resolve(chatFlow)
			chatFlow.show(from: from, mode: .fullscreen)
		}
		
		private func showInsuranceBills(insurance: Insurance, from: ViewController) {
			let insuranceBillsFlow = InsuranceBillsFlow(rootController: from)
			self.container?.resolve(insuranceBillsFlow)
			insuranceBillsFlow.showBills(insurance: insurance, from: from)
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
		
		private func searchInsuranceModal(from: UIViewController) {
			let storyboard = UIStoryboard(name: "InsuranceSearchRequest", bundle: nil)
			let viewController: CreateInsuranceSearchRequestViewController = storyboard.instantiateInitial()
			container?.resolve(viewController)
			
			viewController.addCloseButton { [weak viewController] in
				viewController?.dismiss(animated: true, completion: nil)
			}
			
			let navigationController = RMRNavigationController(rootViewController: viewController)
			navigationController.strongDelegate = RMRNavigationControllerDelegate()
			
			from.present(navigationController, animated: true, completion: nil)
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
		
		private func showAccidentEventReport(for insuranceId: String, from: ViewController) {
			insurancesService.insurance(useCache: true, id: insuranceId) { result in
				switch result {
					case .success(let insurance):
						let accidentFlow = AccidentEventFlow(rootController: from)
						self.container?.resolve(accidentFlow)
						accidentFlow.start(
							insuranceId: insuranceId,
							flowMode: AccidentEventFlow.FlowMode.createNewEvent,
							showMode: ViewControllerShowMode.push
						)
						
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
						
				}
			}
		}
		
		private func showAutoEvent(for insuranceId: String, from: ViewController) {
			let hide = from.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
			insurancesService.insurance(useCache: true, id: insuranceId) { result in
				hide(nil)
				switch result {
					case .success:
						let createAutoEventFlow = CreateAutoEventFlow()
						self.container?.resolve(createAutoEventFlow)
						createAutoEventFlow.start(with: insuranceId, from: from, draft: nil)
						
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
				}
			}
		}
		
		private func showEuroProtocol(for insuranceId: String, from: ViewController) {
			insurancesService.insurance(useCache: true, id: insuranceId) { result in
				switch result {
					case .success(let insurance):
						let createAutoEventFlow = CreateAutoEventFlow()
						self.container?.resolve(createAutoEventFlow)
						
						let draftKind = self.eventReportService
							.autoEventDrafts()
							.first { $0.insuranceId == insuranceId }
							.map(InsuranceEventFlow.DraftKind.autoDraft)
						
						if case .autoDraft(let draft) = draftKind {
							createAutoEventFlow.showEuroProtocol(with: insuranceId, from: from, draft: draft, isModal: true)
						} else {
							createAutoEventFlow.showEuroProtocol(with: insuranceId, from: from, draft: nil, isModal: true)
						}
						
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
				}
			}
		}
		
		private func showAutoEvents(from: ViewController) {
			insurancesService.insurances(useCache: true) { result in
				switch result {
					case .success(let shortInsurances):
						if let category = shortInsurances.insuranceGroupList.flatMap({ $0.insuranceGroupCategoryList })
							.first(where: { $0.insuranceCategory.type == .auto }) {
							let eventFlow = InsuranceEventFlow(rootController: from)
							self.container?.resolve(eventFlow)
							eventFlow.showActiveEvents(for: category, from: from)
						} else {
							ErrorHelper.show(error: AlfastrahError.unknownError, alertPresenter: self.alertPresenter)
						}
						
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
						
				}
			}
		}
		
		private func voipCall(_ voipCall: VoipCall, from: ViewController) {
			voipService.microphonePermission { result in
				switch result {
					case .success:
						self.showVoipCall(with: voipCall, from: from)
					case .failure:
						UIHelper.showMicrophoneRequiredAlert(from: from)
				}
			}
		}
		
		private let sosStoryboard: UIStoryboard = UIStoryboard(name: "Sos", bundle: nil)
		
		private func showVoipCall(with voipCall: VoipCall, from: ViewController) {
			if let voipServiceAvailability {
				if self.voipServiceAvailability != .disconnected {
					ErrorHelper.show(error: nil, alertPresenter: self.alertPresenter)
					return
				}
			} else {
				self.voipServiceAvailability = .disconnected
				
				voipService.subscribeForAvailability { voipServiceAvailability in
					self.voipServiceAvailability = voipServiceAvailability
				}.disposed(by: disposeBag)
			}
			
			let viewController: VoipCallViewController = sosStoryboard.instantiate()
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
			
			viewController.hidesBottomBarWhenPushed = true
			
			from.navigationController?.pushViewController(viewController, animated: true)
		}
		
		private func prolongForInsurance(with insuranceId: String, from: ViewController) {
			guard let insuranceShort = self.insurancesService.cachedShortInsurance(by: insuranceId)
			else { return }
			
			let flow = InsurancesFlow()
			container?.resolve(flow)
			
			flow.showRenew(
				insuranceId: insuranceShort.id,
				renewalType: insuranceShort.renewType,
				from: from
			)
		}
		
		private func showOffices(from: ViewController) {
			let officesFlow = OfficesFlow()
			container?.resolve(officesFlow)
			officesFlow.start(from: from)
		}
		
		private func editProfile(from: ViewController) {
			ApplicationFlow.shared.profileFlow.showAccountInfo(from: from)
		}
		
		private func switchTheme(from: ViewController) {
			ApplicationFlow.shared.profileFlow.showApplicationTheme(from: from)
		}
		
		private func appSettings() {
			ApplicationFlow.shared.profileFlow.showSettings()
		}
		
		private func aboutApp() {
			ApplicationFlow.shared.profileFlow.showAbout()
		}
		
		private func userLogout(from: ViewController) {
			ApplicationFlow.shared.profileFlow.showLogout(from: from) {
				BDUI.CommonActionHandlers.shared.reset()
			}
		}
		
		private func switchAccountType(to accountType: AccountType, from: ViewController, completion: @escaping () -> Void) {
			let resultAccountType: AccountType
			
			switch accountType {
				case .alfaLife:
					resultAccountType = .alfaStrah
				case .alfaStrah:
					resultAccountType = .alfaLife
			}
			
			self.applicationSettingsService.accountType = resultAccountType
			
			ApplicationFlow.shared.profileFlow.changeAccountType(
				withIndicator: false,
				from: from,
				completion
			)
		}
	}
}
// swiftlint:enable file_length
