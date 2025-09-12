//
// Analytics
// AlfaStrah
//
// Created by Eugene Egorov on 17 October 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

enum ErrorLogIdentifier: String {
    case chatSdkError = "chat_sdk_error"
    case chatNetworkError = "chat_network_error"
    case chatJSONError = "chat_json_error"
    case dataPreloadError = "data_preload_error"
    case dataPreloadFatalError = "data_preload_fatal_error"
}

protocol AnalyticsService {	
	func logError(
		identifier: ErrorLogIdentifier,
		message: String,
		parameters: [String: String]
	)
	
    func track(event: String)
    func track(event: String, properties: [String: Any?])	
	func track(event: String, userProfileProperties: [String: String])
	func track(event: String, properties: [String: Any?], userProfileProperties: [String: String])
	func track(insuranceId: String, event: String, userProfileProperties: [String: String])
	func track(navigationSource: AnalyticsParam.NavigationSource, insuranceId: String, event: String, userProfileProperties: [String: String])
	func track(
		navigationSource: AnalyticsParam.NavigationSource,
		insuranceId: String,
		isAuthorized: Bool,
		event: String,
		userProfileProperties: [String: String]
	)
}
