//
//  RestMobileGuidService.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 06.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Legacy

class RestMobileGuidService: MobileGuidService {
    var mobileGuid: String? {
        guard
            let currentIdentifier = currentDeviceIdentifier,
            let savedIdentifier = applicationSettingsService.deviceIdentifier,
            currentIdentifier == savedIdentifier
        else {
            return nil
        }

        return applicationSettingsService.mobileGuid
    }

    private var currentDeviceIdentifier: String? {
        UIDevice.current.identifierForVendor?.uuidString
    }

    private let rest: FullRestClient
    private let applicationSettingsService: ApplicationSettingsService

    init(
        rest: FullRestClient,
        applicationSettingsService: ApplicationSettingsService
    ) {
        self.rest = rest
        self.applicationSettingsService = applicationSettingsService
    }

    func updateMobileGuid(completion: @escaping (Result<String, AlfastrahError>) -> Void) {
        rest.read(
            path: "api/security/mobile_guid",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "mobile_guid", transformer: CastTransformer<Any, String>()),
            completion: mapCompletion { [weak self] result in
                guard let self = self else { return }

                if case .success(let mobileGuid) = result {
                    self.applicationSettingsService.deviceIdentifier = self.currentDeviceIdentifier
                    self.applicationSettingsService.mobileGuid = mobileGuid
                }
                completion(result)
            }
        )
    }

    // MARK: - Updatable

    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        guard isUserAuthorized, mobileGuid == nil else { return completion(.failure(.authNeeded)) }

        updateMobileGuid { _ in }
    }

    func erase(logout: Bool) { }
}
