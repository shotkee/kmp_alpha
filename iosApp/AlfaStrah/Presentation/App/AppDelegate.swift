//
//  AppDelegate.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 04/10/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import shared

import UIKit
import UserNotifications
import Legacy
import CoreLocation
import AppTrackingTransparency
import Firebase
import IQKeyboardManagerSwift
import FirebaseMessaging

enum Environment: String {
    case appStore   = "appStore"
    case prod       = "prod"
    case prodAdHoc  = "prodAdHoc"
    case stage      = "stage"
    case stageAdHoc = "stageAdHoc"
    case test       = "test"
    case testAdHoc  = "testAdHoc"
}

var environment: Environment {
    #if APP_STORE
        return .appStore
    #elseif PROD_AD_HOC
        return .prodAdHoc
    #elseif STAGE_AD_HOC
        return .stageAdHoc
    #elseif TEST_AD_HOC
        return .testAdHoc
    #elseif PROD
        return .prod
    #elseif STAGE
        return .stage
    #elseif TEST
        return .test
    #else
        return .prod
    #endif
}

private let secretKeyBytes: [UInt8] = [
    0x64, 0x65, 0x77, 0x70, 0x23, 0x57, 0x6a, 0x24, 0x70, 0x4c, 0x7b,
    0x49, 0x73, 0x66, 0x35, 0x61, 0x25, 0x65, 0x7e, 0x52, 0x32, 0x62,
    0x7b, 0x48, 0x69, 0x73, 0x58, 0x77, 0x4b, 0x34, 0x43, 0x33, 0x4d,
    0x37, 0x68, 0x33, 0x42, 0x47, 0x35, 0x4f, 0x56, 0x74, 0x69, 0x6d,
    0x56, 0x41, 0x44, 0x76, 0x51, 0x33,
]

private var secretKey: String {
    return getString(from: secretKeyBytes)
}

@UIApplicationMain
class AppDelegate: UIResponder,
                   UIApplicationDelegate,
                   UNUserNotificationCenterDelegate,
                   LoggerDependency,
                   TransferManagerDependency,
                   ApplicationSettingsServiceDependency,
                   ActivityDelegate,
				   MessagingDelegate {
	var logger: TaggedLogger?
	var window: UIWindow?
	private var applicationFlow: ApplicationFlow!
	var transferManager: TransferManager!
	var applicationSettingsService: ApplicationSettingsService!
	
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		let window = Window(frame: UIScreen.main.bounds)
		window.delegate = self
		
		self.window = window
		
		setupAppearance()
		
		setupIQKeyboardManager()
		
		FirebaseApp.configure()
		setupFirebaseMessaging()
		
		let configurator: RestConfigurator
		switch environment {
			case .appStore:
				configurator = RestConfigurator(
					baseUrl: "https://alfamobile.alfastrah.ru",
					yandexMapsApiKey: "59bd8716-b711-4501-9a13-95c5b092e1b9",
					yandexMetricaApiKey: "8363dba7-06b3-40a6-bd0a-e0c1c63146d9",
					secretKey: secretKey,
					useProdEuroprotocolEnvironment: true
				)
			case .prodAdHoc:
				configurator = RestConfigurator(
					baseUrl: "https://alfamobile.alfastrah.ru",
					yandexMapsApiKey: "59bd8716-b711-4501-9a13-95c5b092e1b9",
					yandexMetricaApiKey: "498359d9-d0b3-4de8-b1ae-c1e130cfcd21",
					secretKey: secretKey,
					useProdEuroprotocolEnvironment: true
				)
			case .prod:
				configurator = RestConfigurator(
					baseUrl: "https://alfamobile.alfastrah.ru",
					yandexMapsApiKey: "59bd8716-b711-4501-9a13-95c5b092e1b9",
					yandexMetricaApiKey: "498359d9-d0b3-4de8-b1ae-c1e130cfcd21",
					secretKey: secretKey,
					useProdEuroprotocolEnvironment: true
				)
			case .stageAdHoc:
				configurator = RestConfigurator(
					baseUrl: "https://alfa-stage.entelis.team",
					yandexMapsApiKey: "f984b85e-314b-4e3d-a0d9-442955b343e1",
					yandexMetricaApiKey: "498359d9-d0b3-4de8-b1ae-c1e130cfcd21",
					secretKey: secretKey,
					useProdEuroprotocolEnvironment: false
				)
			case .stage:
				configurator = RestConfigurator(
					baseUrl: "https://alfa-stage.entelis.team",
					yandexMapsApiKey: "f984b85e-314b-4e3d-a0d9-442955b343e1",
					yandexMetricaApiKey: "498359d9-d0b3-4de8-b1ae-c1e130cfcd21",
					secretKey: secretKey,
					useProdEuroprotocolEnvironment: false
				)
			case .testAdHoc:
				configurator = RestConfigurator(
					baseUrl: "https://alfa-test.entelis.team",
					yandexMapsApiKey: "f984b85e-314b-4e3d-a0d9-442955b343e1",
					yandexMetricaApiKey: "498359d9-d0b3-4de8-b1ae-c1e130cfcd21",
					secretKey: secretKey,
					useProdEuroprotocolEnvironment: false
				)
			case .test:
				configurator = RestConfigurator(
					baseUrl: "https://alfa-test.entelis.team",
					yandexMapsApiKey: "f984b85e-314b-4e3d-a0d9-442955b343e1",
					yandexMetricaApiKey: "498359d9-d0b3-4de8-b1ae-c1e130cfcd21",
					secretKey: secretKey,
					useProdEuroprotocolEnvironment: false
				)
		}
		
		let container = configurator.create()
		container.resolve(self)
		
		container.resolve(BDUI.CommonActionHandlers.shared)
		
		let lastUsedEnvironment = applicationSettingsService.lastUsedEnvironmentIdentifier
			.map { Environment(rawValue: $0) }
		let appVersion = AppInfoService.applicationShortVersion
		let lastKnownAppVersion = applicationSettingsService.lastKnownAppVersion
		
		applicationFlow = ApplicationFlow(window: window, container: container)
		applicationFlow.start(
			resetMobileDeviceToken: environment != lastUsedEnvironment,
			resetPassengersInsurances: appVersion != lastKnownAppVersion
		)
		
		applicationSettingsService.lastUsedEnvironmentIdentifier = environment.rawValue
		applicationSettingsService.lastKnownAppVersion = appVersion
		
		if #available(iOS 13.0, *) {
			showDebugMenuIfNeeded(environment)
		}
		
		setupKmp()
		
		return true
	}
	
	private func setupKmp() {
		InitKoinKt.doInitKoinOnce()
	}
	    
    func applicationDidBecomeActive(_ application: UIApplication) {
        applicationFlow.notify.didBecomeActive(application)
        requestTrackingAuthorization()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        applicationFlow.notify.didEnterBackground()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        applicationFlow.notify.willEnterForeground()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        applicationFlow.notify.willTerminate()
    }
    
    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        transferManager.reconnectWithBackgroundSession(identifier: identifier, completion: completionHandler)
    }
    
    // MARK: - Appearance
    private func setupAppearance() {
        window?.backgroundColor = .Background.background
        window?.tintColor = .Icons.iconAccentThemed
        
        // MARK: - Gloabal Tab Bar appearance
        UITabBar.appearance().backgroundColor = .Background.backgroundContent
        UITabBarItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.foregroundColor: UIColor.Text.textAccent,
                NSAttributedString.Key.font: Style.Font.caption2
            ],
            for: .selected
        )
        UITabBarItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.foregroundColor: UIColor.Text.textPrimary,
                NSAttributedString.Key.font: Style.Font.caption2
            ],
            for: .normal
        )
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        }

		UITabBar.appearance().tintColor = .Icons.iconAccent
		UITabBar.appearance().unselectedItemTintColor = .Icons.iconPrimary
		UITabBar.appearance(whenContainedInInstancesOf: [ UIDocumentBrowserViewController.self ]).tintColor = nil
		UITabBar.appearance(whenContainedInInstancesOf: [ UIDocumentBrowserViewController.self ]).backgroundColor = nil

		// MARK: - Global Navigation Bar appearance
		updateColorNavigationBar(isSystemNavBarColor: false)
		UINavigationBar.appearance(whenContainedInInstancesOf: [ RMRNavigationController.self ]).tintColor = .Icons.iconAccentThemed
		UINavigationBar.appearance(whenContainedInInstancesOf: [ TranslucentNavigationController.self ]).tintColor = .Icons.iconAccentThemed
		UINavigationBar.appearance(whenContainedInInstancesOf: [ RMRNavigationController.self ]).backgroundColor = .Background.backgroundContent
		UINavigationBar.appearance(whenContainedInInstancesOf: [ UIDocumentBrowserViewController.self ]).backgroundColor = nil
		UINavigationBar.appearance(whenContainedInInstancesOf: [ UIDocumentBrowserViewController.self ]).tintColor = nil
		
		let titleAttributes = [NSAttributedString.Key.font: Style.Font.headline1]
		let buttonsAttributes = [NSAttributedString.Key.font: Style.Font.text]
		
		if #available(iOS 13, *) {
			let appearance = UINavigationBarAppearance()
			appearance.configureWithOpaqueBackground()
			appearance.shadowColor = .clear
			appearance.backgroundColor = .Background.backgroundContent
			appearance.buttonAppearance.normal.titleTextAttributes = buttonsAttributes
			appearance.titleTextAttributes = titleAttributes
			
			UINavigationBar.appearance().standardAppearance = appearance
			UINavigationBar.appearance().scrollEdgeAppearance = appearance
		} else {
			UINavigationBar.appearance().titleTextAttributes = titleAttributes
		}
		
		BackBarButtonItem.appearance(whenContainedInInstancesOf: [ UINavigationController.self ]).tintColor = .Icons.iconAccent
		
		// MARK: - Global Search Bar appearance
		UIBarButtonItem.appearance(
			whenContainedInInstancesOf: [UISearchBar.self]
		).title = NSLocalizedString("common_cancel_button", comment: "")
		
		let normalSearchBarButtonAttributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Icons.iconAccentThemed,
			.font: Style.Font.text
		]
		UIBarButtonItem.appearance(
			whenContainedInInstancesOf: [UISearchBar.self]
		).setTitleTextAttributes(normalSearchBarButtonAttributes, for: .normal)
		
		let highlightedAttributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.Icons.iconAccentThemed,
			.font: Style.Font.text
		]
		UIBarButtonItem.appearance(
			whenContainedInInstancesOf: [UISearchBar.self]
		).setTitleTextAttributes(highlightedAttributes, for: .highlighted)
		
		// Search bar text style
		UITextField.appearance(
			whenContainedInInstancesOf: [UISearchBar.self]
		).defaultTextAttributes = [
			.font: Style.Font.text,
			.foregroundColor: UIColor.Text.textPrimary
		]
		
		UITextField.appearance(
			whenContainedInInstancesOf: [UISearchBar.self]
		).attributedPlaceholder = NSAttributedString(
			string: NSLocalizedString("common_search", comment: ""),
			attributes: [
				.font: Style.Font.text,
				.foregroundColor: UIColor.Text.textSecondary
			]
		)
	}
    
    // MARK: - Notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        applicationFlow.notify.remoteNotificationToken(.success(deviceToken))
        
        Messaging.messaging().apnsToken = deviceToken
    }
    
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Swift.Error) {
        applicationFlow.notify.remoteNotificationToken(.failure(error))
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        applicationFlow.notify.willPresentNotification(notification, completionHandler)
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        switch response.actionIdentifier {
            case UNNotificationDismissActionIdentifier:
                return completionHandler()
            case UNNotificationDefaultActionIdentifier:
                applicationFlow.notify.processNotification(response, completionHandler)
            default:
                completionHandler()
        }
    }
    
    // MARK: - Universal Links
    func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        userActivityType == NSUserActivityTypeBrowsingWeb
    }
    
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
            return applicationFlow.notify.deepLink(url)
        }
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        applicationFlow.notify.deepLink(url)
    }
    
    // MARK: - IQKeyboardManagerSwift
    func setupIQKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = NSLocalizedString("common_done_button", comment: "")
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 25

        let disabedIqKeyboardManagerClasses = [
            SmsCodeViewController.self,
			SignInSMSCodeViewController.self,
            AddressInputViewController.self,
            BaseBottomSheetViewController.self,
            ChatViewController.self,
			AutoEventPlacePickerViewController.self
        ]
        
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = disabedIqKeyboardManagerClasses
        IQKeyboardManager.shared.disabledToolbarClasses = disabedIqKeyboardManagerClasses
    }
    
    // MARK: - ActivityDelegate
    func activities(for window: Window, with event: UIEvent) {
        applicationFlow.notify.userActivityEvent()
    }
    
    // MARK: - Firebase Messaging delegate
    private func setupFirebaseMessaging() {
        let messaging = Messaging.messaging()
        messaging.delegate = UIApplication.shared.delegate as? MessagingDelegate
    }
    
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let fcmToken = fcmToken
        else { return }
        
        let tokenDict = ["token": fcmToken ]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: tokenDict
        )
    }
    
    // MARK: - Debug Menu
    @available(iOS 13.0, *)
    private func showDebugMenuIfNeeded(_ environment: Environment) {
        switch environment {
            case .prod, .prodAdHoc, .stage, .stageAdHoc, .test, .testAdHoc:
				DebugMenu.shared.rootWindow = window
				DebugMenu.shared.addMenuButton(iconSystemName: "lightbulb.circle.fill", action: { [weak self] _ in
					guard let window = self?.window,
						  let overlay = DebugMenu.shared.debugMenuControlWindow
					else { return }
					
					let style: UIUserInterfaceStyle = window.overrideUserInterfaceStyle == .dark ? .light : .dark
					
					overlay.overrideUserInterfaceStyle = style
					window.overrideUserInterfaceStyle = style
				})
				
				DebugMenu.shared.addMenuButton(iconSystemName: "square.circle.fill", action: { sender in					
					DebugMenu.shared.debugBDUI = !DebugMenu.shared.debugBDUI
					
					sender.setBackgroundColor(
						DebugMenu.shared.debugBDUI ? .Icons.iconAccent.withAlphaComponent(0.8) : .clear,
						forState: .normal
					)
				})
				
				DebugMenu.shared.addMenuButton(iconSystemName: "house.circle.fill", action: { sender in
					DebugMenu.shared.homeBDUI = !DebugMenu.shared.homeBDUI
					
					ApplicationFlow.shared.reloadTabs()
					
					sender.setBackgroundColor(
						DebugMenu.shared.homeBDUI ? .Icons.iconAccent.withAlphaComponent(0.8) : .clear,
						forState: .normal
					)
				})
				
            case .appStore:
                break
				
        }
    }
}

// MARK: - Tools and services
private extension AppDelegate {
    func requestTrackingAuthorization() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }
}

// MARK: - Autologout
public protocol ActivityDelegate: AnyObject {
    func activities(for window: Window, with event: UIEvent)
}

public class Window: UIWindow {
    public weak var delegate: ActivityDelegate?
    
    public override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
        if nil != event.allTouches?.first(where: { $0.phase == .began }) {
            delegate?.activities(for: self, with: event)
        }
    }
}
