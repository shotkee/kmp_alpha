//
// ServiceDataManagerDefault
// AlfaStrah
//
// Created by Eugene Egorov on 23 November 2018.
// Copyright (c) 2018 Redmadrobot. All rights reserved.
//

import Foundation
import Legacy

class ServiceDataManagerDefault: ServiceDataManager {
    private let logger: TaggedLogger?
    private let accountService: AccountService
    private let analyticsService: AnalyticsService
    private let services: [Updatable]
    private var servicesUpdateSubscriptions: Subscriptions<Void> = Subscriptions()

    func subscribeForServicesUpdates(listener: @escaping () -> Void) -> Subscription {
        servicesUpdateSubscriptions.add(listener)
    }

    init(
        logger: TaggedLogger?,
        accountService: AccountService,
        analyticsService: AnalyticsService,
        services: [Updatable]
    ) {
        self.logger = logger
        self.accountService = accountService
        self.analyticsService = analyticsService
        self.services = services
    }

    func update(progressHandler: @escaping (Double) -> Void, completion: @escaping () -> Void) {
        // Update services one by one
        DispatchQueue.global(qos: .userInitiated).async {
            let dispatchGroup = DispatchGroup()
            self.services.enumerated().forEach { index, service in
                DispatchQueue.global(qos: .userInitiated).sync {
                    dispatchGroup.enter()
                    self.logger?.debug("Update started", tag: String(describing: service))
                    service.updateService(isUserAuthorized: self.accountService.isAuthorized) { [weak self] result in
                        guard let self = self else { return }

                        switch result {
                            case .success:
                                self.logger?.debug("Update success.", tag: String(describing: service))
                                self.remoteLogMessage("Update success: \(String(describing: service))")
                            case .failure(let error):
                                self.logger?.debug("Update failure. \(error.displayValue ?? "")", tag: String(describing: service))
                                self.remoteLogError(error, service: String(describing: service))
                        }

                        let progress = Double(index + 1) / Double(self.services.count)
                        self.remoteLogMessage("Progress: \(progress * 100)%")
                        
                        DispatchQueue.main.async {
                            progressHandler(progress * 100)
                        }
                        
                        dispatchGroup.leave()
                    }
                    dispatchGroup.wait()
                }
            }

            dispatchGroup.notify(queue: .main) {
                completion()
                self.servicesUpdateSubscriptions.fire(())
            }
        }
    }

    private var silentUpdateNeeded = true

    func performActionsAfterAppIsReady() {
        guard silentUpdateNeeded else { return }

        silentUpdateNeeded = false
        // Update services one by one
        DispatchQueue.global(qos: .userInitiated).async {
            let dispatchGroup = DispatchGroup()
            self.services.forEach { service in
                DispatchQueue.global(qos: .userInitiated).sync {
                    dispatchGroup.enter()
                    self.logger?.debug("Silent update started", tag: String(describing: service))
                    service.performActionAfterAppIsReady(isUserAuthorized: self.accountService.isAuthorized) { [weak self] result in
                        guard let self = self else { return }

                        switch result {
                            case .success:
                                self.logger?.debug("Silent update success.", tag: String(describing: service))
                            case .failure(let error):
                                self.logger?.debug("Silent update failure. \(error.displayValue ?? "")", tag: String(describing: service))
                        }
                        dispatchGroup.leave()
                    }
                    dispatchGroup.wait()
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.logger?.debug("All services silent update finished.", tag: String(describing: self))
                if self.shouldSendRemoteLog {
                    self.sendRemoteLog(message: "Data preload errors", errorDescription: "See log", identifier: .dataPreloadError)
                }
            }
        }
    }

    func erase(logout: Bool) {
        dataPreloadLogHistory = ""
        shouldSendRemoteLog = false
        services.forEach { service in
            logger?.debug("Erased", tag: String(describing: service))
            service.erase(logout: logout)
        }
        silentUpdateNeeded = true

        servicesUpdateSubscriptions.fire(())
    }

    // MARK: - Remote error logger

    private var dataPreloadLogHistory: String = "Started"
    private var shouldSendRemoteLog: Bool = false

    private func remoteLogMessage(_ log: String) {
        dataPreloadLogHistory += "\n\(log). (\(dateString));"
    }

    private func remoteLogError(_ error: ServiceUpdateError, service: String) {
        switch error {
            case .authNeeded, .notImplemented:
                break
            case .error(let error):
                let errorDescription = error.displayValue ?? error.debugDisplayValue
                dataPreloadLogHistory += "\nUpdate failure: \(service), \(errorDescription). (\(dateString));"
                shouldSendRemoteLog = true
        }
    }

    private var dateString: String {
        ServiceDataManagerDefault.dateTimeFormatter.string(from: Date())
    }

    private static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM yyyy, HH:mm:ss"
        return formatter
    }()

    private func sendRemoteLog(message: String, errorDescription: String, identifier: ErrorLogIdentifier) {
        var parameters: [String: String] = [:]
        parameters["isAuthorized"] = accountService.isAuthorized ? "yes" : "no"
        parameters["isDemo"] = accountService.isDemo ? "yes" : "no"
        parameters["logHistory"] = dataPreloadLogHistory
        parameters["error"] = errorDescription
        parameters["applicationVersion"] = AppInfoService.applicationVersion()

        analyticsService.logError(identifier: identifier, message: message, parameters: parameters)

        dataPreloadLogHistory = ""
        shouldSendRemoteLog = true
    }

    func applicationDidEnterBackground() {
        remoteLogMessage("Application did enter background")
        if shouldSendRemoteLog {
            sendRemoteLog(message: "Data preload errors", errorDescription: "Fatal UX, user closed app. See log",
                identifier: .dataPreloadFatalError)
        }
    }

    func applicationWillTerminate() {
        remoteLogMessage("Application will terminate")
        if shouldSendRemoteLog {
            sendRemoteLog(message: "Data preload errors", errorDescription: "Fatal UX, user closed app. See log",
                identifier: .dataPreloadFatalError)
        }
    }
}
