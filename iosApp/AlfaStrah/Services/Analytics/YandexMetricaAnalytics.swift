//
// YandexMetricaAnalytics
// AlfaStrah
//
// Created by Eugene Egorov on 17 October 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import YandexMobileMetrica

#if DEBUG
import CocoaDebug
#endif

class YandexMetricaAnalytics: AnalyticsService {
	private enum LogMessageType {
		case normal
		case error
		case userUpdate
	}
	
	private func messageColor(for messageType: LogMessageType) -> UIColor {
		switch messageType {
			case .normal:
				return UIColor.white
			case .error:
				return UIColor.red
			case .userUpdate:
				return UIColor.yellow
		}
	}
	
	private let profile = YMMMutableUserProfile()
	
	private var userProfileProperties: [String: String] = [:]
	
    let disposeBag = DisposeBag()

    private static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy, HH:mm:ss"
        return formatter
    }()

    init(apiKey: String, settingsService: ApplicationSettingsService, accountService: AccountService) {
        let configuration = YMMYandexMetricaConfiguration(apiKey: apiKey)
        configuration?.crashReporting = true
        configuration?.locationTracking = true
        // Do not track app update as new users
        configuration?.handleFirstActivationAsUpdate = settingsService.wasOndoarding

        switch environment {
            case .appStore:
                break
            case .testAdHoc, .stageAdHoc, .prodAdHoc, .test, .stage, .prod:
                configuration?.logs = true
        }

        if let configuration = configuration {
            YMMYandexMetrica.activate(with: configuration)
        }
		
		updateUserProfile(with:
			[AnalyticsParam.Profile.authorized: AnalyticsParam.string(accountService.isUserAccountDataLoaded)]
		)

        accountService.subscribeForAccountUpdates { userAccount in
			self.resetUserProfile()
			
			let isAuthorized = userAccount != nil
			
			if isAuthorized {
				self.updateUserProfile(with:
					[AnalyticsParam.Profile.authorized: AnalyticsParam.string(accountService.isUserAccountDataLoaded)]
				)
			}
			
        }.disposed(by: disposeBag)
    }

    func track(event: String) {
		logMetricsEventSend(event: event)
		
		YMMYandexMetrica.reportEvent(event) { error in
			self.logError(error)
		}
    }

    func track(event: String, properties: [String: Any?]) {
		logMetricsEventSend(event: event, properties: properties)
		
		YMMYandexMetrica.reportEvent(event, parameters: properties as [AnyHashable: Any]) { error in
			self.logError(error)
		}
    }
	
	private func logError(_ error: Error) {
		let message = "\nYandexMetrica Error\n: \(error.localizedDescription)\n}"
		
#if DEBUG
		_SwiftLogHelper.shared.handleLog(
			file: nil,
			function: nil,
			line: nil,
			message: message,
			color: messageColor(for: .error)
		)
#endif
	}
	
	private func sanitize(_ string: String) -> String {
		return string.replacingOccurrences(of: ".", with: "_")
	}

	private func sanitizeValue(_ value: Any) -> Any {
		if let date = value as? Date {
			return date.toString()
		}
		return value
	}
	
	private func logMetricsEventSend(
		event: String,
		properties: [String: Any?]? = nil
	) {
		let sanitizedProperties = properties?.mapKeyAndValuesRecursive(
			transformKey: sanitize,
			transformValue: sanitizeValue
		)
		
#if DEBUG
		_SwiftLogHelper.shared.handleLog(
			file: nil,
			function: nil,
			line: nil,
			message: "\nYandexMetrica event send\nevent: \(event),\nparams:\n{\n\(self.convertParamstoString(params: sanitizedProperties))\n}",
			color: messageColor(for: .normal)
		)
#endif
	}
	
	private func logUserProfileUpdate(_ userProperties: [String: Any?]) {
		let sanitizedProperties = userProperties.mapKeyAndValuesRecursive(
			transformKey: sanitize,
			transformValue: sanitizeValue
		)
		
		let message = userProperties.isEmpty
			? "\nYandexMetrica user profile custom attributes are reset\n"
			: "\nYandexMetrica user profile update\nwith properties:\n{\n\(self.convertParamstoString(params: sanitizedProperties))\n}"
#if DEBUG
		_SwiftLogHelper.shared.handleLog(
			file: nil,
			function: nil,
			line: nil,
			message: message,
			color: messageColor(for: .userUpdate)
		)
#endif
	}

    func logError(
        identifier: ErrorLogIdentifier,
        message: String,
        parameters: [String: String]
    ) {
        var parameters = parameters
        parameters["time"] = YandexMetricaAnalytics.dateTimeFormatter.string(from: Date())
        let error = YMMError(
            identifier: identifier.rawValue,
            message: message,
            parameters: parameters,
            backtrace: Thread.callStackReturnAddresses,
            underlyingError: nil
        )

		YMMYandexMetrica.report(error: error) { error in
			self.logError(error)
		}
    }
	
	private func updateUserProfile(with properties: [String: String]) {
		var propertiesToUpdate: [String: String] = [:]
		
		for property in properties {
			if self.userProfileProperties[property.key] == nil { // attribute not exist
				propertiesToUpdate[property.key] = property.value
			} else {
				if self.userProfileProperties[property.key] != property.value { // attribute exist but value need to update
					propertiesToUpdate[property.key] = property.value
				}
			}
		}
		
		for property in propertiesToUpdate {
			profile.apply(
				YMMProfileAttribute
					.customString(property.key)
					.withValue(property.value)
			)
			
			self.userProfileProperties[property.key] = property.value
		}
		
		if !propertiesToUpdate.isEmpty {
			logUserProfileUpdate(propertiesToUpdate)
			
			YMMYandexMetrica.report(profile) { error in
				self.logError(error)
			}
		}
	}
	
	private func resetUserProfile() {
		for property in self.userProfileProperties {
			profile.apply(
				YMMProfileAttribute
					.customString(property.key)
					.withValueReset()
			)
			
			self.userProfileProperties[property.key] = nil
		}
		
		logUserProfileUpdate([:])
		
		YMMYandexMetrica.report(profile) { error in
			self.logError(error)
		}
	}
	
	func track(event: String, properties: [String: Any?], userProfileProperties: [String: String]) {
		if !userProfileProperties.isEmpty {
			updateUserProfile(with: userProfileProperties)
		}
		
		return track(event: event, properties: properties)
	}
	
	func track(event: String, userProfileProperties: [String: String]) {
		if !userProfileProperties.isEmpty {
			updateUserProfile(with: userProfileProperties)
		}
		
		return track(event: event)
	}
	
	func track(navigationSource: AnalyticsParam.NavigationSource, insuranceId: String, event: String, userProfileProperties: [String: String]) {
		let properties: [String: String] = [
			AnalyticsParam.Key.navigationSource: navigationSource.rawValue,
			AnalyticsParam.Key.insuranceId: insuranceId
		]
		
		if !userProfileProperties.isEmpty {
			updateUserProfile(with: userProfileProperties)
		}
		
		return track(event: event, properties: properties)
	}
	
	func track(insuranceId: String, event: String, userProfileProperties: [String: String]) {
		let properties: [String: String] = [
			AnalyticsParam.Key.insuranceId: insuranceId
		]
		
		if !userProfileProperties.isEmpty {
			updateUserProfile(with: userProfileProperties)
		}
		
		return track(event: event, properties: properties)
	}
	
	func track(
		navigationSource: AnalyticsParam.NavigationSource,
		insuranceId: String,
		isAuthorized: Bool,
		event: String,
		userProfileProperties: [String: String]
	) {
		let properties: [String: Any] = [
			AnalyticsParam.Key.navigationSource: navigationSource.rawValue,
			AnalyticsParam.Key.insuranceId: insuranceId,
			AnalyticsParam.Key.authorized: isAuthorized
		]
		
		if !userProfileProperties.isEmpty {
			updateUserProfile(with: userProfileProperties)
		}
		
		return track(event: event, properties: properties)
	}
	
	private func convertParamstoString(
		params: [String: Any]?
	) -> String {
		guard let params = params
		else { return "\t parameters are empty"}
		
		return params.compactMap(
		 {
			 (key, value) -> String in
					
			 return "\t\(key): \(value)"
		 }
		).joined(separator: ";\n")
	}
}
