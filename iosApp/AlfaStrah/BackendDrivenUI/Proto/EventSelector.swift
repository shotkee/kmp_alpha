//
//  EventBackendComponent.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class EventSelector: ComponentInitializable {
		enum Key: String {
			case onTap = "onTap"
			case onRender = "onRender"
			case onChange = "onChange"
		}
		
		let onRender: Action?
		let onTap: Action?
		let onChange: Action?
		
		var formDataPatchKey: String?
		
		required init(body: [String: Any]) {
			if let tapActionBodyRaw = body[Key.onTap] as? [String: Any] {
				self.onTap = Action(body: tapActionBodyRaw)
			} else {
				self.onTap = nil
			}
			
			if let renderActionBodyRaw = body[Key.onRender] as? [String: Any] {
				self.onRender = Action(body: renderActionBodyRaw)
				print("render event \(self.onRender?.name)")
			} else {
				self.onRender = nil
			}
			
			if let changeActionBodyRaw = body[Key.onChange] as? [String: Any] {
				self.onChange = Action(body: changeActionBodyRaw)
				print("change event \(self.onChange?.name)")
			} else {
				self.onChange = nil
			}
		}
		
		init(onTap: Action?, onRender: Action?, onChange: Action?, formDataPathcKey: String? = nil) {
			self.onTap = onTap
			self.onRender = onRender
			self.onChange = onChange
			self.formDataPatchKey = formDataPathcKey
		}
	}
	
	enum ClinicType: String {
		case online = "ONLINE"
		case avis = "AVIS"
	}
	
	class Action: ComponentInitializable {
		enum Key: String {
			case appointmentId = "appointmentId"
			case categoryId = "insuranceCategoryId"
			case preselectedClinicFilter = "preselectedClinicFilter"
			case insuranceId = "insuranceId"
			case fileUrl = "fileUrl"
			case phone = "phone"
			case screen = "screen"
			case screenId = "screenId"
			case source = "source"
			case actions = "actions"
			case layoutId = "layoutId"
			case content = "content"
			case type = "type"
			case tag = "tag"
			case questionId = "questionId"
			case mode = "mode"
			case action = "action"
			case sendFormData = "sendFormData"
			case appMetrica = "appMetrica"
			case billId = "billId"
			case billIds = "billsId"
			case draftId = "draftId"
			case name = "name"
			case internetCall = "internetCall"
			case layout = "layout"
			case lockBehavior = "lockBehavior"
			case accountType = "sessionType"
		}
		
		enum ActionLockBehavior: String {
			case disableElement = "disableElement"
			case disableScreen = "disableScreen"
			case screenLoader = "screenLoader"
		}
		
		enum ActionMode: String {
			case sync = "sync"
			case async = "async"
		}
		
		var mode: ActionMode?
		let method: ActionMethod?
		let lockBehavior: ActionLockBehavior?
		
		let postDataNeedToSend: Bool
		
		let name: String?
		
		let analyticEvent: AnalyticsEventComponentDTO?
		
		let targetLayoutId: String?
		let targetScreenId: String?
		
		let onSendAnalyticEvent: (AnalyticsService, AnalyticsEventComponentDTO?) -> Void = { analytics, event in
			guard let analyticEvent = event,
				  let eventName = event?.eventName,
				  let profileDetails = event?.profileDetails
			else { return }
			
			func dictionary(array: [AnalyticsDetailComponentDTO]) -> [String: String] {
				var dict: [String: String] = [:]
				
				array.forEach { item in
					if let title = item.title,
					   let value = item.value,
					   !title.isEmpty {
						dict[title] = value
					}
				}
				
				return dict
			}
			
			var eventDetailsDict: [String: String] = [:]
			let profileDetailsDict = dictionary(array: profileDetails)
			
			if let eventDetails = event?.eventDetails {
				eventDetailsDict = dictionary(array: eventDetails)
			}
			
			analytics.track(
				event: eventName,
				properties: eventDetailsDict,
				userProfileProperties: profileDetailsDict
			)
		}
		
		required init(body: [String: Any]) {
			if let lockBehaviorRaw = body[Key.lockBehavior] as? String {
				self.lockBehavior = ActionLockBehavior(rawValue: lockBehaviorRaw)
			} else {
				self.lockBehavior = nil
			}
			
			self.targetLayoutId = body[Key.layoutId] as? String
			self.targetScreenId = body[Key.screenId] as? String
			
			if let typeRaw = body[Key.type] as? String,
			   let type = BackendComponentType(rawValue: typeRaw) {
				self.method = Self.actionMethod(type, body)
				
				self.postDataNeedToSend = body[Key.sendFormData] as? Bool ?? false
				
				if let appMetricaRaw = body[Key.appMetrica] as? [String: Any] {
					self.analyticEvent = AnalyticsEventComponentDTO(
						body: appMetricaRaw
					)
				} else {
					self.analyticEvent = nil
				}
				
				self.name = typeRaw
			} else {
				self.method = nil
				self.name = nil
				self.postDataNeedToSend = false
				self.analyticEvent = nil
			}
		}
		
		init(mode: ActionMode = .sync, _ method: ActionMethod?) {
			self.mode = mode
			self.method = method
			
			self.postDataNeedToSend = false
			
			self.lockBehavior = nil
			self.analyticEvent = nil
			
			self.name = String(describing: method)
			
			self.targetLayoutId = nil
			self.targetScreenId = nil
		}
		
		enum ActionMethod {
			case actionFlowChat
			case actionFlowBills(_ insuranceId: String)
			case actionFlowClinics(_ insuranceId: String, _ filterId: String?)
			case actionFlowGaranteeLetters(_ insuranceId: String)
			case actionFlowDoctorAppointments(_ insuranceId: String)
			case actionFlowDoctorAppointment(_ insuranceId: String, _ appointmentId: Int64, _ source: ClinicType)
			case actionFlowInstruction(_ insuranceId: String, _ categoryId: String)
			case actionFlowMedicalFileStorage
			case actionBasicScreenRender(_ screen: () -> ScreenComponentDTO?)
			case actionModalScreenRender(_ screen: () -> ScreenComponentDTO?)
			case actionPhone(_ phone: PhoneComponentDTO)
			case actionFlowTelemed(_ insuranceId: String)
			case actionFlowVirtualAssistant(_ insuranceId: String)
			case actionFlowFranchise(_ insuranceId: String)
			case actionFlowHelpBlocks(_ insuranceId: String, url: URL?)
			case actionFlowCompensation(_ insuranceId: String)
			case actionWebView(_ webViewEvent: WebViewEventComponentDTO)
			case actionNotificationsList
			case actionMultipleActions(_ actions: [Action])
			case actionLayoutReplace(_ screenId: String?, _ layoutId: String?, _ layoutDto: () -> LayoutDTO?)
			case actionLayoutReplaceAsync(_ screenId: String?, _ layoutId: String?, _ request: RequestComponentDTO)
			case actionLayoutFilter(_ screenId: String?, _ layoutId: String?, _ tag: String?)
			case actionFlowLoyalty
			case actionNavigateBackTo(_ screenId: String?)
			case actionNavigateBack
			case localActionStories(
				_ selectedStory: (
					selectedStoryIndex: Int,
					stories: [Story],
					viewedStoriesPage: [Int64: Int],
					completion: (Int64, Int) -> Void
				)
			)
			case actionScreenRequest(_ request: RequestComponentDTO)
			case actionFlowInsurance(_ insuranceId: String)
			case actionFlowBillsPay(_ insuranceId: String, _ billIds: [Int])
			case actionFlowBill(_ insuranceId: String, _ billId: Int)
			case actionFlowActivation
			case actionFlowFindInsurance
			case actionActionRequest(_ request: RequestComponentDTO)
			case actionFlowDraftCalculations
			case actionFlowQuestion(_ questionId: Int64)
			case actionFlowQuestions
			case actionMainPageToNativeRender
			case actionFlowOffices
			case actionFlowProducts
			case actionDeleteDraft(_ id: Int)
			case actionFlowEventReportNS(_ insuranceId: String, _ name: String?)
			case actionFlowEventReportOsago(_ insuranceId: String)
			case actionFlowEventReportKasko(_ insuranceId: String)
			case actionFlowEuroprotocolOsago(_ insuranceId: String)
			case actionFlowInternetCall(_ voipCall: VoipCall)
			case actionFlowProlongationOsago(_ insuranceId: String)
			case actionFlowProlongationKasko(_ insuranceId: String)
			case actionFlowProlongationAlfaRepair(_ insuranceId: String)
			case actionFlowProlongationKindNeighbors(_ insuranceId: String)
			case actionFlowDoctorHomeRequest(_ doctorCall: DoctorCallBDUI)
			case actionNothing
			case actionAlert(_ alert: AlertComponentDTO)
			case actionEditProfile
			case actionFlowChangeSessionType(_ accountType: AccountType)
			case actionFlowExit
			case actionFlowAboutApp
			case actionFlowAppSettings
			case actionFlowTheme
			case actionFlowViewEventReportsAuto
			case actionScreenReplace(_ screenId: String?, _ screen: () -> ScreenComponentDTO?)
			case actionFlowOsagoPhotoUpload(_ picker: OsagoPhotoUploadPickerComponentDTO?)
			case actionFlowOsagoSchemeAuto(_ picker: OsagoSchemeAutoPickerComponentDTO?)
		}
		
		// swiftlint:disable:next cyclomatic_complexity function_body_length
		private static func actionMethod(_ type: BackendComponentType, _ body: [String: Any]) -> Action.ActionMethod? {
			switch type {
				case .actionFlowChat:
					return .actionFlowChat
					
				case .actionFlowClinics:
					guard let insuranceId = body[Key.insuranceId] as? Int64
					else { return nil }
					
					var clinicTypeFilterIdString: String?
					
					if let clinicTypeFilterId = body[Key.preselectedClinicFilter] as? Int64 {
						clinicTypeFilterIdString = String(clinicTypeFilterId)
					}
					
					return .actionFlowClinics(String(insuranceId), clinicTypeFilterIdString)
					
				case .actionFlowDoctorAppointment:
					guard let insuranceId = body[Key.insuranceId] as? Int64,
						  let appointmentId = body[Key.appointmentId] as? Int64,
						  let source = body[Key.source] as? String,
						  let clinicType = ClinicType(rawValue: source)
					else { return nil }
					
					return .actionFlowDoctorAppointment(
						String(insuranceId),
						appointmentId,
						clinicType
					)
					
				case .actionFlowDoctorAppointments:
					guard let insuranceId = body[Key.insuranceId] as? Int64
					else { return nil }
					
					return .actionFlowDoctorAppointments(String(insuranceId))
					
				case .actionWebView:
					return .actionWebView(WebViewEventComponentDTO(body: body))
					
				case .actionFlowGaranteeLetters:
					guard let insuranceId = body[Key.insuranceId] as? Int64
					else { return nil }
					
					return .actionFlowGaranteeLetters(String(insuranceId))
					
				case .actionScreenRender:
					func screenRenderAction(body: [String: Any], screenType: String) -> ActionMethod? {
						if BackendComponentType.screenBottomToolbar.rawValue == screenType
							|| BackendComponentType.screenBasic.rawValue == screenType {
							let calculateOnAction = {
								return ScreenComponentDTO(body: body)
							}
							
							return .actionBasicScreenRender(calculateOnAction)
						}
						
						if BackendComponentType.screenModal.rawValue == screenType {
							let calculateOnAction = {
								return ScreenComponentDTO(body: body)
							}
							
							return .actionModalScreenRender(calculateOnAction)
						}
						
						return nil
					}
					
					if let body = body[Key.screen] as? [String: Any] {
						guard let screenType = body[ComponentDTO.Key.type] as? String
						else { return nil }
						
						return screenRenderAction(body: body, screenType: screenType)
					} else if let screenType = body[ComponentDTO.Key.type] as? String {
						return screenRenderAction(body: body, screenType: screenType)
					}
					
					return nil
					
				case .actionPhone:
					guard let body = body[Key.phone] as? [String: Any]
					else { return nil }
					
					return .actionPhone(PhoneComponentDTO(body: body))
					
				case .actionFlowBills:
					guard let insuranceId = body[Key.insuranceId] as? Int
					else { return nil }
					
					return .actionFlowBills(String(insuranceId))
					
				case .actionFlowMedicalFileStorage:
					return .actionFlowMedicalFileStorage
					
				case .actionFlowInstruction:
					guard let insuranceId = body[Key.insuranceId] as? Int64,
						  let categoryId = body[Key.categoryId] as? Int64
					else { return nil }
					
					return .actionFlowInstruction(String(insuranceId), String(categoryId))
					
				case .actionFLowTelemed:
					guard let insuranceId = body[Key.insuranceId] as? Int64
					else { return nil }
					
					return .actionFlowTelemed(String(insuranceId))
					
				case .actionFlowVirtualAssistant:
					guard let insuranceId = body[Key.insuranceId] as? Int64
					else { return nil }
					
					return .actionFlowVirtualAssistant(String(insuranceId))
					
				case .actionFlowFranchise:
					guard let insuranceId = body[Key.insuranceId] as? Int64
					else { return nil }
					
					return .actionFlowFranchise(String(insuranceId))
					
				case .actionFlowHelpBlocks:
					guard let insuranceId = body[Key.insuranceId] as? Int64
					else { return nil }
					
					guard let urlPath = body[Key.fileUrl] as? String
					else {
						return .actionFlowHelpBlocks(String(insuranceId), url: nil)
					}
					
					let url = URL(string: urlPath)
					
					return .actionFlowHelpBlocks(String(insuranceId), url: url)
					
				case .actionFlowCompensation:
					guard let insuranceId = body[Key.insuranceId] as? Int64
					else { return nil }
					
					return .actionFlowCompensation(String(insuranceId))
					
				case .actionFlowNotifications:
					return .actionNotificationsList
					
				case .actionMulti:
					if let actionBodiesArray = body[Key.actions] as? [Any] {
						let actions: [Action] = actionBodiesArray.compactMap {
							if let item = $0 as? [String: Any] {
								let mode = ActionMode(rawValue: item[Key.mode] as? String ?? "sync") ?? .sync
								
								if let actionRaw = item[Key.action] as? [String: Any] {
									let action = Action(body: actionRaw)
									action.mode = mode
									
									return action
								} else {
									return nil
								}
							} else {
								return nil
							}
						}
						
						return .actionMultipleActions(actions)
					}
					
					return nil
					
				case .actionLayoutReplace:
					if let content = body[Key.content] as? [String: Any] {
						let calculateOnAction = {
							return BDUI.ComponentDTO.mapData(body: content) as? LayoutDTO
						}
						
						return .actionLayoutReplace(
							body[Key.screenId] as? String,
							body[Key.layoutId] as? String,
							calculateOnAction
						)
					}
					
					return nil
					
				case .actionLayoutReplaceAsync:
					if let content = body[Key.content] as? [String: Any] {
						return .actionLayoutReplaceAsync(
							body[Key.screenId] as? String,
							body[Key.layoutId] as? String,
							RequestComponentDTO(body: content)
						)
					} else {
						return nil
					}
					
				case .actionLayoutFilter:
					return .actionLayoutFilter(
						body[Key.screenId] as? String,
						body[Key.layoutId] as? String,
						body[Key.tag] as? String
					)
					
				case .actionFlowLoyalty:
					return .actionFlowLoyalty
					
				case .actionScreenRequest:
					return .actionScreenRequest(RequestComponentDTO(body: body))
					
				case .actionNavigateBack:
					return .actionNavigateBackTo(body[Key.screenId] as? String)
					
				case .actionFlowInsurance:
					guard let insuranceId = body[Key.insuranceId] as? Int64
					else { return nil }
					
					return .actionFlowInsurance(String(insuranceId))
					
				case .actionFlowBillsPay:
					guard let insuranceId = body[Key.insuranceId] as? Int64,
						  let billIds = body[Key.billIds] as? [Int]
					else { return nil }
					
					return .actionFlowBillsPay(String(insuranceId), billIds)
					
				case .actionFlowBill:
					guard let insuranceId = body[Key.insuranceId] as? Int64,
						  let billId = body[Key.billId] as? Int
					else { return nil }
					
					return .actionFlowBill(String(insuranceId), billId)
					
				case .actionFlowActivation:
					return .actionFlowActivation
					
				case .actionFlowFindInsurance:
					return .actionFlowFindInsurance
					
				case .actionActionRequest:
					if let body = body[Key.action] as? [String: Any] {
						return .actionActionRequest(RequestComponentDTO(body: body))
					} else {
						return .actionActionRequest(RequestComponentDTO(body: body))
					}
					
				case .actionFlowDraftCalculations:
					return .actionFlowDraftCalculations
					
				case .actionFlowQuestion:
					guard let questionId = body[Key.questionId] as? Int64
					else { return nil }
					
					return .actionFlowQuestion(questionId)
					
				case .actionFlowQuestions:
					return .actionFlowQuestions
					
				case .actionMainPageToNativeRender:
					return .actionMainPageToNativeRender
					
				case .actionFlowOffices:
					return .actionFlowOffices
					
				case .actionFlowProducts:
					return .actionFlowProducts
					
				case .actionDraftDelete:
					guard let draftId = body[Key.draftId] as? Int
					else { return nil }
					
					return .actionDeleteDraft(draftId)
					
				case .actionFlowEventReportNS:
					guard let insuranceId = body[Key.insuranceId] as? Int64
					else { return nil }
					
					return .actionFlowEventReportNS(String(insuranceId), body[Key.name] as? String)
					
				case .actionFlowEventReportOsago:
					guard let insuranceId = body[Key.insuranceId] as? Int64
					else { return nil }
					
					return .actionFlowEventReportOsago(String(insuranceId))
					
				case .actionFlowEventReportKasko:
					guard let insuranceId = body[Key.insuranceId] as? Int64
					else { return nil }
					
					return .actionFlowEventReportKasko(String(insuranceId))
					
				case .actionFlowEuroprotocolOsago:
					guard let insuranceId = body[Key.insuranceId] as? Int64
					else { return nil }
					
					return .actionFlowEuroprotocolOsago(String(insuranceId))
					
				case .actionFlowInternetCall:
					guard let raw = body[Key.internetCall] as? [String: Any],
						  let voipCall = VoipCallTransformer().transform(source: raw).value
					else { return nil }
					
					return .actionFlowInternetCall(voipCall)
					
				case .actionFlowProlongationOsago:
					guard let insuranceId = body[Key.insuranceId] as? Int64
					else { return nil }
					
					return .actionFlowProlongationOsago(String(insuranceId))
					
				case .actionFlowProlongationKasko:
					guard let insuranceId = body[Key.insuranceId] as? Int64
					else { return nil }
					
					return .actionFlowProlongationKasko(String(insuranceId))
					
				case .actionFlowProlongationAlfaRepair:
					guard let insuranceId = body[Key.insuranceId] as? Int64
					else { return nil }
					
					return .actionFlowProlongationAlfaRepair(String(insuranceId))
					
				case .actionFlowProlongationKindNeighbors:
					guard let insuranceId = body[Key.insuranceId] as? Int64
					else { return nil }
					
					return .actionFlowProlongationKindNeighbors(String(insuranceId))
					
				case .actionFlowDoctorHomeRequest:
					if let doctorCall = DoctorCallBDUITransformer().transform(source: body).value {
						return .actionFlowDoctorHomeRequest(doctorCall)
					}
					return nil
					
				case .actionNothing:
					return .actionNothing
					
				case .actionAlert:
					return .actionAlert(AlertComponentDTO(body: body))
					
				case .actionEditProfile:
					return .actionEditProfile
					
				case .actionFlowChangeSessionType:
					guard let accountTypeRaw = body[Key.accountType] as? Int,
						  let accountType = AccountType(rawValue: accountTypeRaw)
					else { return nil }
					
					return .actionFlowChangeSessionType(accountType)
					
				case .actionFlowExit:
					return .actionFlowExit
					
				case .actionFlowAboutApp:
					return .actionFlowAboutApp
					
				case .actionFlowAppSettings:
					return .actionFlowAppSettings
					
				case .actionFlowTheme:
					return .actionFlowTheme
					
				case .actionFlowViewEventReportsAuto:
					return .actionFlowViewEventReportsAuto
					
				case .actionScreenReplace:
					func screenReplaceAction(body: [String: Any]) -> ActionMethod? {
						let calculateOnAction = {
							return ScreenComponentDTO(body: body)
						}
						
						return .actionScreenReplace(body[Key.screenId] as? String, calculateOnAction)
					}
					
					if let body = body[Key.screen] as? [String: Any] {
						return screenReplaceAction(body: body)
					} else {
						return screenReplaceAction(body: body)
					}
					
				case .actionFlowOsagoPhotoUpload:
					return .actionFlowOsagoPhotoUpload(OsagoPhotoUploadPickerComponentDTO(body: body))
					
				case .actionFlowOsagoSchemeAuto:
					return .actionFlowOsagoSchemeAuto(OsagoSchemeAutoPickerComponentDTO(body: body))
					
				default:
					return nil
					
			}
		}
	}
}
