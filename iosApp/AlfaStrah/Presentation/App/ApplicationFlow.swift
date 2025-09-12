//
//  ApplicationFlow
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 04/10/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy
import UserNotifications
import FirebaseMessaging

// swiftlint:disable file_length
final class ApplicationFlow: NSObject,
                             AlertPresenterDependency,
                             AnalyticsServiceDependency,
                             LoggerDependency,
                             ServiceDataManagerDependency,
                             AccountServiceDependency,
                             ApplicationSettingsServiceDependency,
                             SessionServiceDependency,
                             ChatServiceDependency,
                             PushNotificationServiceDependency,
                             NotificationsServiceDependency,
                             MobileDeviceTokenServiceDependency,
                             AttachmentServiceDependency,
                             InsurancesServiceDependency,
                             EventReportLoggerDependency {
    @objc static private(set) var shared: ApplicationFlow!

    var serviceDataManager: ServiceDataManager!
    var analytics: AnalyticsService!
    var alertPresenter: AlertPresenter!
    var logger: TaggedLogger?

    var accountService: AccountService!
    var sessionService: UserSessionService!
    var applicationSettingsService: ApplicationSettingsService!
    var chatService: ChatService!
    var mobileDeviceTokenService: MobileDeviceTokenService!
    var pushNotificationService: PushNotificationService!
    var notificationsService: NotificationsService!
    var attachmentService: AttachmentService!
    var insurancesService: InsurancesService!
    var eventReportLogger: EventReportLoggerService!

    private let disposeBag: DisposeBag = DisposeBag()
    private var authFromOldAppSubscriptions: Subscriptions<Void> = Subscriptions()
    private var accountChangeSubscriptions: Subscriptions<Void> = Subscriptions()
    private var didBecomeReachableSubscriptions: Subscriptions<Bool> = Subscriptions()
    private var willEnterForegroundSubscriptions: Subscriptions<Void> = Subscriptions()
    private var didEnterBackgroundSubscriptions: Subscriptions<Void> = Subscriptions()
        
    struct Notify {
        var didBecomeActive: (UIApplication) -> Void
        var didEnterBackground: () -> Void
        var willEnterForeground: () -> Void
        var willTerminate: () -> Void
        var deepLink: (URL) -> Bool
        var remoteNotificationToken: (Result<Data, Error>) -> Void
        var willPresentNotification: (_ notification: UNNotification,
            _ completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) -> Void
        var processNotification: (_ response: UNNotificationResponse, _ completionHandler: @escaping () -> Void) -> Void
        var userActivityEvent: () -> Void
    }

    private(set) lazy var notify: Notify = Notify(
        didBecomeActive: { [weak self] _ in
            guard let self = self else { return }

            self.startMonitoringReachability()
            self.eventReportLogger.applicationDidBecomeActiveEvent()
        },
        didEnterBackground: { [weak self] in
            guard let self = self else { return }

            self.window.contentHidden = true
            self.eventReportLogger.applicationDidEnterBackgroundEvent()
            self.stopMonitoringReachability()
            self.serviceDataManager.applicationDidEnterBackground()
            
            self.didEnterBackgroundSubscriptions.fire(())
        },
        willEnterForeground: { [weak self] in
            guard let self = self
            else { return }
            
            self.window.contentHidden = false
            
            self.willEnterForegroundSubscriptions.fire(())
            
            // since ios close any network connection at background
            // we need restart chat session
            self.chatService.startNewChatService()
        },
        willTerminate: { [weak self] in
            self?.eventReportLogger.applicationWillTerminateEvent()
            self?.serviceDataManager.applicationWillTerminate()
        },
        deepLink: { [weak self] url in self?.processDeepLink(url: url) ?? false },
        remoteNotificationToken: { [weak self] result in self?.remoteNotificationToken(result: result) },
        willPresentNotification: { [weak self] notification, handler in self?.processIncomingNotification(notification, handler: handler) },
        processNotification: { [weak self] response, handler in self?.processOpenedNotification(response: response, handler: handler) },
        userActivityEvent: { [weak self] in
            self?.authFlow.resetInactivityTimer()
        }
    )

    private lazy var rateAppHelper = RateAppBehavior()
    private lazy var reachability = Reachability(hostname: "https://alfamobile.alfastrah.ru")
    private var isMonitoringReachability: Bool = false
    private let window: UIWindow
	
	var currentApplicationTheme: UIUserInterfaceStyle = .unspecified
	
	let container: DependencyInjectionContainer

    init(window: UIWindow, container: DependencyInjectionContainer) {
        self.window = window
        self.container = container
        mainScreenFlow = MainScreenFlow()
        chatFlow = ChatFlow()
        insuranceBuyFlow = InsurancesBuyFlow()
        profileFlow = ProfileFlow()
        tabBarController = BaseTabBarController()
        authFlow = AuthorizationFlow(rootController: tabBarController)

        super.init()
		
        authFromOldAppSubscriptions.add(authFlow.authFromOldAppListener).disposed(by: authFlow.disposeBag)
        accountChangeSubscriptions.add(profileFlow.notify.accountChange).disposed(by: profileFlow.disposeBag)
        container.resolve(self)
        container.resolve(tabBarController)
        container.resolve(authFlow)
        container.resolve(mainScreenFlow)
        container.resolve(chatFlow)
        container.resolve(profileFlow)
        container.resolve(insuranceBuyFlow)
		
		container.resolve(FilePicker.shared)
		
        ApplicationFlow.shared = self
        configureTabBarController()
        
        if !sessionService.isSessionAuthorized {
            sessionService.removeCookies()
        }
		
		if #available(iOS 13.0, *) {
			let theme = applicationSettingsService.themeWasApplied == .yes
				? applicationSettingsService.applicationTheme
				: .light
						
			apply(applicationTheme: theme)
		}
    }
	
	@available (iOS 13.0, *)
	func apply(applicationTheme: UIUserInterfaceStyle) {
		self.window.overrideUserInterfaceStyle = applicationTheme
		self.currentApplicationTheme = applicationTheme
	}
    
    func start(
        resetMobileDeviceToken: Bool,
        resetPassengersInsurances: Bool
    ) {
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        mainScreenFlow.start()
        chatFlow.start()
        insuranceBuyFlow.start()
        profileFlow.start()
        authFlow.start {
            self.checkAndPerformDelayedActions()
        }
        
        pushNotificationService.registerAppForNotifications()
        
        if resetMobileDeviceToken {
            mobileDeviceTokenService.resetDeviceToken()
        }
        mobileDeviceTokenService.getDeviceToken(completion: { _ in })
        
        if resetPassengersInsurances {
            insurancesService.resetPassengersInsurances()
        }
        
        accountService.subscribeForAccountUpdates { [weak self] _ in
            self?.mobileDeviceTokenService.getDeviceToken { [weak self] result in
                switch result {
                    case .success(let deviceToken):
                        self?.sessionService.sendDeviceData(deviceToken: deviceToken) { [weak self] result in
                            if case .failure(let error) = result {
                                self?.logger?.error(error.debugDisplayValue)
                            }
                        }
                    case .failure(let error):
                        self?.logger?.error(error.debugDisplayValue)
                }
            }
        }.disposed(by: disposeBag)
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        notificationsService.subscribeForUnreadMessageCountUpdates { unreadCount in
            UIApplication.shared.applicationIconBadgeNumber = unreadCount
        }.disposed(by: disposeBag)
    }

    func subscribeForDidBecomeReachable(listener: @escaping (Bool) -> Void) -> Subscription {
        didBecomeReachableSubscriptions.add(listener)
    }
    
    func subscribeForWillEnterForeground(listener: @escaping () -> Void) -> Subscription {
        willEnterForegroundSubscriptions.add(listener)
    }
    
    func subscribeForDidEnterBackground(listener: @escaping () -> Void) -> Subscription {
        didEnterBackgroundSubscriptions.add(listener)
    }

    // MARK: - Delayed actions

    private var delayedActions: [ () -> Void ] = []

    // Perform action after app is done auth flow
    func performDelayedAction(_ action: @escaping () -> Void) {
        delayedActions.append(action)
        checkAndPerformDelayedActions()
    }

    private func checkAndPerformDelayedActions() {
        guard authFlow.initialAuthFinished
        else { return }

        serviceDataManager.performActionsAfterAppIsReady()
        for action in delayedActions {
            action()
        }
        delayedActions = []
    }

    // MARK: - Routing

    private let tabBarController: BaseTabBarController
    private let authFlow: AuthorizationFlow
    private let mainScreenFlow: MainScreenFlow
    private let chatFlow: ChatFlow
    private let insuranceBuyFlow: InsurancesBuyFlow
	let profileFlow: ProfileFlow

    private func configureTabBarController() {
        tabBarController.setViewControllers(
            [
                mainScreenFlow.initialViewController,
                chatFlow.initialViewController,
                FakeSosController(),
                insuranceBuyFlow.initialViewController,
                profileFlow.initialViewController,
            ],
            animated: false
        )
    }

    func hideAllModalViewControllers(animated: Bool, completion: @escaping () -> Void) {
        if tabBarController.presentedViewController != nil {
            tabBarController.dismiss(animated: true, completion: completion)
        } else {
            completion()
        }
    }
	
	func refreshAllTabs() {
		let isNativeRender = applicationSettingsService.isNativeRender == .yes

		mainScreenFlow.setupInitalController(withNativeRender: isNativeRender)
		insuranceBuyFlow.setupInitalController(withNativeRender: isNativeRender)
		profileFlow.setupInitalController(withNativeRender: isNativeRender)
		
		chatFlow.setupInitalController()
	}

    /// This function don't close any current view hierarchy
    func switchTab(to section: TabBarSection) {
        switch section {
            case .home:
                tabBarController.selectedViewController = mainScreenFlow.initialViewController
				
            case .chat:
				if let fromViewController = mainScreenFlow.initialViewController.topViewController as? ViewController,
				   accountService.isDemo
				{
					DemoBottomSheet.presentInfoDemoSheet(from: fromViewController)
				}
				else
				{
					tabBarController.selectedViewController = chatFlow.initialViewController
				}
				
            case .products:
				tabBarController.selectedViewController = insuranceBuyFlow.initialViewController
				
            case .profile:
                tabBarController.selectedViewController = profileFlow.initialViewController
				
        }
    }
	
	func reloadTabs() {
		switch applicationSettingsService.isNativeRender {
			case .yes:
				applicationSettingsService.isNativeRender = .no
				
			case .no, .none:
				applicationSettingsService.isNativeRender = .yes
		}
		
		let isNativeRender = applicationSettingsService.isNativeRender == .yes
		
		reloadHomeTab(withNativeRender: isNativeRender)
		reloadProfileTab(withNativeRender: isNativeRender)
	}
	
	func reloadHomeTab(withNativeRender: Bool) {
		mainScreenFlow.setupInitalController(withNativeRender: withNativeRender)
	}
	
	func reloadProfileTab(withNativeRender: Bool) {
		profileFlow.setupInitalController(withNativeRender: withNativeRender)
	}
	
	func reloadProductsTab(isNativeRender: Bool) {
		insuranceBuyFlow.setupInitalController(withNativeRender: isNativeRender)
	}
	
	func reloadHomeTab() {
		switch applicationSettingsService.isNativeRender {
			case .yes:
				applicationSettingsService.isNativeRender = .no
				
			case .no, .none:
				applicationSettingsService.isNativeRender = .yes
		}
		
		reloadHomeTab(withNativeRender: applicationSettingsService.isNativeRender == .yes)
	}

	func show(item: RoutingItem, completion: (() -> Void)? = nil) {
        hideAllModalViewControllers(animated: true) {
            self.routeMain(item)
			completion?()
        }
    }
    
    func forceLogout() {
        guard accountService.isAuthorized
        else { return }
        
        hideAllModalViewControllers(animated: false) { [weak self] in
            self?.logout()
            self?.routeMain(.login)
        }
    }
	
	func showLogInViewController()
	{
		authFlow.showLogInViewController(hasRootVC: true)
	}
    
    private func routeMain(_ item: RoutingItem) {
        switch item {
            case .tabBar(let section):
                switchTab(to: section)
				
            case .settings:
                UIHelper.openApplicationSettings()
				
            case .sos:
				if let analyticsData = analyticsData(
					from: insurancesService.cachedShortInsurances(forced: true),
					for: .health
				) {
					analytics.track(
						event: AnalyticsEvent.App.openSOS,
						properties: ["authorized": accountService.isAuthorized],
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
				} else {
					analytics.track(
						event: AnalyticsEvent.App.openSOS,
						properties: ["authorized": accountService.isAuthorized]
					)
				}
				
                let sosFlow = SosFlow()
                container.resolve(sosFlow)
                let sosController = sosFlow.start()
                tabBarController.present(sosController, animated: true, completion: nil)
				
            case .login:
                authFlow.showWelcomeController()
			
			case .signIn:
				logout()
				authFlow.showLogInViewController(hasRootVC: false)
			
            case .rateApp:
                rateAppHelper.showSystemReviewUI()
				
            case .logout:
                logout()
				
            case .kaskoProlongation(let insuranceId):
                switchTab(to: .home)
                let flow = InsurancesFlow()
                container.resolve(flow)
                if let fromVC = mainScreenFlow.initialViewController.topViewController as? ViewController {
                    flow.showInsurance(id: insuranceId, from: fromVC, isModal: true)
                }
				
            case .alfaPoints:
                switchTab(to: .profile)
                guard let fromController = profileFlow.initialViewController.topViewController else { return }

                let flow = LoyaltyFlow()
                container.resolve(flow)
                flow.startModally(from: fromController)
				
            case .eventReport(let reportId, let insurance):
				let fromVC = UIHelper.findTopModal(controller: tabBarController)
                let flow = InsuranceEventFlow(insurance: insurance, rootController: fromVC)
                container.resolve(flow)
                flow.startWithEventReport(reportId: reportId, insurance: insurance)
				
            case .vzrOnOffInsurance:
                let flow = InsurancesFlow()
                container.resolve(flow)
                let fromVC = UIHelper.findTopModal(controller: tabBarController) as? ViewController
                fromVC.map(flow.showVzrOnOffInsurance(from:))
				
            case .insurancesList, .telemedecine:
                break
				
            case .buyInsurance:
                switchTab(to: .home)
                guard let fromVC = mainScreenFlow.initialViewController.topViewController as? ViewController else { return }

                self.analytics.track(event: AnalyticsEvent.App.openShop)
                let flow = InsurancesBuyFlow()
                container.resolve(flow)
                flow.start(from: fromVC)
				
            case .notifications(let url):
                switchTab(to: .home)
                guard let topViewController = mainScreenFlow.initialViewController.topViewController as? ViewController else { return }
                
                let flow = NotificationsFlow(rootController: topViewController)
                container.resolve(flow)
                
                flow.showList(mode: .push, animated: false)
                                
                SafariViewController.open(url, from: topViewController)
				
            case .pincode:
                switchTab(to: .home)
                authFlow.showPincode()
				
			case .offices:
				guard let from = UIHelper.findTopModal(controller: tabBarController) as? ViewController
				else { return }
				
				let officesFlow = OfficesFlow()
				container.resolve(officesFlow)
				officesFlow.start(from: from)
				
			case .insuranceBill(let insuranceId, let billId):
				guard let from = UIHelper.findTopModal(controller: tabBarController) as? ViewController
				else { return }
				
				let flow = InsuranceBillsFlow(rootController: from)
				container.resolve(flow)
				
				flow.showInsuranceBill(insuranceId, billId, from: from)
        }
    }
    
	func logout() {
        delayedActions = []
		
        applicationSettingsService.userAuthType = .notDefined
		applicationSettingsService.wasAutorized = false
        /// необходимо сбросить для перекючения accountService.isDemo
        /// обязательно до метода erase, т.к при удалении токена сессии через протокол
        /// должна сброситься сессия чата, которая будет смотреть на это поле

        serviceDataManager.erase(logout: true)
    }

    func switchSession(to userType: AccountType, completion: @escaping (Result<Bool, AlfastrahError>) -> Void) {
        authFlow.switchSession(to: userType, completion: completion)
    }

    // MARK: - Deep link
    private var deepLink: DeepLink?

    private func processDeepLink(url: URL) -> Bool {
        deepLink = DeepLink.from(url: url)
        switch deepLink {
            case .openPolicyList?, .openPolicy?:
                return true
            case .confirmEmail(let code)?:

                accountService.verifyEmail(code: code) { [weak self] result in
                    guard let self = self else { return }

                    switch result {
                        case .success:
                            let alert = BasicNotificationAlert(text: NSLocalizedString("alert_email_changed", comment: ""))
                            self.alertPresenter.show(alert: alert)
                            self.accountChangeSubscriptions.fire(())
                        case .failure(let error):
                            self.show(error: error)
                    }
                }
                return true
            case .auth(let session, let accountType)?:
                if let session = session, let accountType = accountType {
                    sessionService.session = session
                    applicationSettingsService.accountType = accountType
                    authFromOldAppSubscriptions.fire(())
                }
                return true
            case .authRequest?:
                logger?.debug("Deep link not supported. \(url)")
                return false
            case .none:
                return false
        }
    }

    // MARK: - Reachability
    private func startMonitoringReachability() {
        guard !isMonitoringReachability else { return }

        do {
            try reachability?.startNotifier()
            isMonitoringReachability = true
        } catch let error {
            print("Failed to start reachability notification: \(error)")
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChanged(_:)),
            name: .reachabilityChanged, object: reachability
        )
    }

    private func stopMonitoringReachability() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }

    @objc private func reachabilityChanged(_ notification: Notification) {
        guard let reachability = reachability else { return }

        switch reachability.connection {
            case .cellular, .wifi:
                didBecomeReachableSubscriptions.fire(true)
            case .none:
                didBecomeReachableSubscriptions.fire(false)
        }
    }

    // MARK: - Push Notifications
    private func remoteNotificationToken(result: Result<Data, Error>) {
        switch result {
            case .success(let token):
                let apnsToken = token.hexadecimal
                logger?.debug("Remote Notifications: App did receive APNS token: \(apnsToken)")
                
                applicationSettingsService.deviceToken = apnsToken
                
                chatService.updatePushToken(apnsToken)
                
                registerApnsToken()
                
            case .failure(let error):
                logger?.error("Remote Notifications: App did failed to register for remote notifications: \(error)")
                
        }
    }

    private func processIncomingNotification(
        _ notification: UNNotification,
        handler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if let externalId = NotificationMessageKind.externalNotificationId(from: notification) {
            performDelayedAction {
                self.pushNotificationService.reportPushNotificationEvent(
                    .received,
                    externalNotificationId: externalId
                )
            }
        }

        if chatService.isChat(remoteNotification: notification),
           tabBarController.selectedViewController === chatFlow.initialViewController {
            handler([ ])
        } else {
            handler([ .sound, .alert, .badge ])
        }
    }

    private func processOpenedNotification(
        response: UNNotificationResponse,
        handler: @escaping () -> Void
    ) {
        if let externalId = NotificationMessageKind.externalNotificationId(from: response.notification) {
            performDelayedAction {
                self.pushNotificationService.reportPushNotificationEvent(
                    .opened,
                    externalNotificationId: externalId
                )
            }
        }

        if let notificationMessage = NotificationMessageKind(notificationResponse: response) {
            performDelayedAction { self.handleNotificationMessage(notificationMessage) }
        }

        handler()
    }

    private func handleNotificationMessage(_ message: NotificationMessageKind) {
        switch message {
            case .newMessage:
                show(item: .tabBar(.chat))
            case .localNotification(let notificationKind):
                switch notificationKind {
                    case .none, .draftIncompleteVehicle, .draftIncompletePassenger:
                        break
                    case .leftCountry:
                        switch reachability?.connection {
                            case .cellular?, .wifi?:
                                show(item: .vzrOnOffInsurance)
                            case .none?, nil:
                                show(item: .tabBar(.home))
                    }

                }
            case .destination(let deeplinkInfo):
                switch deeplinkInfo.destination {
                    case .insurancesList, .telemedecide, .unsupported:
                        break
                    case .kaskoProlongation:
                        guard let insuranceId = deeplinkInfo.insuranceId else { return }

                        show(item: .kaskoProlongation(insuranceId))
                    case .mainScreen:
                        show(item: .tabBar(.home))
                    case .alfaPoints:
                        show(item: .alfaPoints)
                    case .externalUrl:
                        guard let url = deeplinkInfo.url
                        else { return }
                        
                        if let isMassMailing = deeplinkInfo.isMassMailing, isMassMailing {
                            show(item: .notifications(url))
                            return
                        }
                        
                        let controller = UIHelper.findTopModal(controller: tabBarController)
                        SafariViewController.open(url, from: controller)
                }
        }
    }

    // MARK: - Helpers

    private func show(error: Error?) {
        ErrorHelper.show(error: error, alertPresenter: alertPresenter)
    }

    func registerApnsToken() {
        guard let apnsToken = applicationSettingsService.deviceToken else { return }

        mobileDeviceTokenService.getDeviceToken { [weak self] result in
            switch result {
                case .success(let deviceToken):
                    self?.registerApnsToken(
                        apnsToken: apnsToken,
                        deviceToken: deviceToken
                    )

                case .failure(let error):
                    self?.logger?.error(error.displayValue ?? "Couldn't get device token while registering for remote notifications")
            }
        }
    }

    private func registerApnsToken(
        apnsToken: String,
        deviceToken: String
    ) {
        pushNotificationService.register(
            apnsToken: apnsToken,
            deviceToken: deviceToken
        ) { [weak self] result in
            switch result {
                case .success(let success):
                    if success {
                        self?.logger?.debug("Remote Notifications: Server successfully registered APNS token: \(apnsToken)")
                    } else {
                        self?.logger?.debug("Remote Notifications: Server failed to register APNS token: \(apnsToken)")
                    }
                case .failure(let error):
                    self?.logger?.error("Remote Notifications: Server did fail to register for remote notifications: \(error)")
            }
        }
    }
}
// swiftlint:enable file_length
