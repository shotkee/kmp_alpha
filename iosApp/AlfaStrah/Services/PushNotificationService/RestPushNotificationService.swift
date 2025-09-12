//
//  RestPushNotificationService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 05/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy
import UserNotifications
import FirebaseCore
import FirebaseMessaging

class RestPushNotificationService: PushNotificationService {
    private let rest: FullRestClient

    init(rest: FullRestClient) {
        self.rest = rest
        setupNotifications()
    }

    func register(
        apnsToken: String,
        deviceToken: String,
        completion: @escaping (Result<Bool, AlfastrahError>) -> Void
    ) {
        let isTest: Int
        switch environment {
            case .appStore:
                isTest = 0
            case .testAdHoc, .stageAdHoc, .prodAdHoc:
                isTest = 2
            case .test, .stage, .prod:
                isTest = 1
        }

        rest.create(
            path: "/token/ios",
            id: nil,
            object: [
                "token": apnsToken,
                "device_token": deviceToken,
                "is_test": "\(isTest)"
            ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: ResponseTransformer(key: "success", transformer: CastTransformer<Any, Bool>()),
            completion: mapCompletion(completion)
        )
    }

    func reportPushNotificationEvent(
        _ event: PushNotificationEvent,
        externalNotificationId: String
    ) {
        rest.create(
            path: "/api/push/register_event",
            id: nil,
            object: ReportPushNotificationEventRequest(
                event: event,
                externalNotificationId: externalNotificationId
            ),
            headers: [:],
            requestTransformer: ReportPushNotificationEventRequestTransformer(),
            responseTransformer: VoidTransformer(),
            completion: { _ in }
        )
    }

    private func setupNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate
    }

    func registerAppForNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings: UNNotificationSettings) in
            guard settings.authorizationStatus == .notDetermined else { return }

            center.requestAuthorization(options: [ .sound, .alert, .badge ]) { _, _ in }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }

    private func unregisterAppForNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }

    // MARK: - Updatable

    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        DispatchQueue.main.async {
            self.registerAppForNotifications()
        }
        completion(.success(()))
    }

    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func erase(logout: Bool) {
        if logout {
            // To prevent push for logout user (There is pushes for unauthorized users)
            registerAppForNotifications()
        }
    }
}
