//
// UserAgent
// AlfaStrah
//
// Created by Eugene Egorov on 21 November 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import Legacy

enum UserAgent {
    static let main: String = {
        let info = DeviceInfo.main
        let name = Bundle.main.object(forInfoDictionaryKey: kCFBundleExecutableKey as String) as? String ?? info.bundleIdentifier
        let version = info.bundleVersion
        let build = info.bundleBuild
        let model = UIDevice.current.model
        let device = info.machineName
        let system = info.system
        let systemVersion = info.systemVersion
        let scale = String(format: "%0.2f", UIScreen.main.scale)
        // AlfaStrah/1.60 (iPhone; iPhone10,6; iOS 12.1; Scale/2.00; Build/310)
        return "\(name)/\(version) (\(model); \(device); \(system) \(systemVersion); Scale/\(scale); Build/\(build))"
    }()
	
	static let headers: [String: String] = [
		"User-Os": "ios",
		"User-Store": "appstore",
		"User-Application": "alfastrah",
		"User-App-Version": DeviceInfo.main.bundleVersion,
		"Timezone": AppLocale.currentTimezoneISO8601()
	]

	static func themeHeader() -> [String: String] {
		var value: String = "light"
		
		if #available(iOS 13.0, *) {
			switch ApplicationFlow.shared.currentApplicationTheme {
				case .dark:
					value = "dark"
					
				case .light:
					value = "light"
					
				case .unspecified:
					switch UIScreen.main.traitCollection.userInterfaceStyle {
						case .dark:
							value = "auto-dark"
							
						case .light, .unspecified:
							value = "auto-light"
							
						@unknown default:
							value = "auto-light"
					}
					
				@unknown default:
					value = "light"
					
			}
		}
		
		return ["Mobile-Theme": value]
	}
}
