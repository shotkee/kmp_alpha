//
//  RestMobileDeviceTokenService.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 12.11.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

import Legacy

class RestMobileDeviceTokenService: MobileDeviceTokenService {
    private let rest: FullRestClient
    private let applicationSettingsService: ApplicationSettingsService

    private var isDeviceTokenRequestInProgress = false
    private var deviceTokenResponseHandlers: [ ((Result<String, AlfastrahError>) -> Void) ] = []

    init(
        rest: FullRestClient,
        applicationSettingsService: ApplicationSettingsService
    ) {
        self.rest = rest
        self.applicationSettingsService = applicationSettingsService
    }

    // MARK: - MobileDeviceTokenService
    
    func resetDeviceToken() {
        applicationSettingsService.mobileDeviceToken = nil
    }
    
    func getDeviceToken(completion: @escaping (Result<MobileDeviceToken, AlfastrahError>) -> Void) {
        #if DEBUG
        assert(Thread.isMainThread)
        #endif
        if let mobileDeviceToken = applicationSettingsService.mobileDeviceToken {
            completion(.success(mobileDeviceToken))
        } else {
            deviceTokenResponseHandlers.append(completion)

            if !isDeviceTokenRequestInProgress {
                isDeviceTokenRequestInProgress = true

                requestMobileDeviceToken { [weak self] result in
                    guard let self = self else { return }

                    switch result {
                        case .success(let deviceToken):
                            self.applicationSettingsService.mobileDeviceToken = deviceToken

                        case .failure:
                            break
                    }

                    self.deviceTokenResponseHandlers.forEach {
                        $0(result)
                    }
                    self.deviceTokenResponseHandlers.removeAll()

                    self.isDeviceTokenRequestInProgress = false
                }
            }
        }
    }

    private func requestMobileDeviceToken(completion: @escaping (Result<MobileDeviceToken, AlfastrahError>) -> Void) {
        let request = MobileDeviceTokenRequest(
            device: "Apple",
            deviceModel: AppInfoService.deviceModel(),
            operatingSystem: .iOS,
            osVersion: AppInfoService.systemVersion(),
            appVersion: AppInfoService.applicationShortVersion
        )

        rest.create(
            path: "api/device/token",
            id: nil,
            object: request,
            headers: [:],
            requestTransformer: MobileDeviceTokenRequestTransformer(),
            responseTransformer: ResponseTransformer(key: "device_token", transformer: CastTransformer<Any, String>()),
            completion: mapCompletion(completion)
        )
    }
}
