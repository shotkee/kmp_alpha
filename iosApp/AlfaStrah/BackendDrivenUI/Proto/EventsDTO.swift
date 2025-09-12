//
//  EventBackendComponent.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class EventsDTO: ComponentInitializable {
		enum Key: String {
			case onTap = "onTap"
			case onRender = "onRender"
			case onChange = "onChange"
		}
		
		let onRender: ActionDTO?
		let onTap: ActionDTO?
		let onChange: ActionDTO?
		
		var formDataPatchKey: String?
		
		required init(body: [String: Any]) {
			
			self.onTap = ComponentDTO.instantinate(Key.onTap, body)
			self.onRender = ComponentDTO.instantinate(Key.onRender, body)
			self.onChange = ComponentDTO.instantinate(Key.onChange, body)
		}
		
		init(onTap: ActionDTO?, onRender: ActionDTO?, onChange: ActionDTO?, formDataPathcKey: String? = nil) {
			self.onTap = onTap
			self.onRender = onRender
			self.onChange = onChange
			self.formDataPatchKey = formDataPathcKey
		}
	}
		
	class ActionDTO: ComponentDTO {
		enum Key: String {
			case lockBehavior = "lockBehavior"
			case layoutId = "layoutId"
			case screenId = "screenId"
			case sendFormData = "sendFormData"
			case type = "type"
			case appMetrica = "appMetrica"
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
		
		let lockBehavior: ActionLockBehavior?
		let targetLayoutId: String?
		let targetScreenId: String?
		
		let postDataNeedToSend: Bool
		
		let name: String?
		
		var mode: ActionMode?
		
		let analyticEvent: AnalyticsEventComponentDTO?
		
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
			
			self.postDataNeedToSend = body[Key.sendFormData] as? Bool ?? false
			
			if let typeRaw = body[Key.type] as? String {
				self.name = typeRaw
			} else {
				self.name = nil
			}
			
			self.mode = .async
			
			if let appMetricaRaw = body[Key.appMetrica] as? [String: Any] {
				self.analyticEvent = AnalyticsEventComponentDTO(
					body: appMetricaRaw
				)
			} else {
				self.analyticEvent = nil
			}
			
			super.init(body: body)
		}
		
		init(mode: ActionMode = .async, _ type: BackendComponentType) {
			self.mode = mode

			self.postDataNeedToSend = false

			self.name = String(describing: type.rawValue)

			self.targetLayoutId = nil
			self.targetScreenId = nil
			
			self.lockBehavior = nil
			self.analyticEvent = nil
			
			super.init(type: type)
		}
	}
}
