//
//  RestLoyaltyService.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 28/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//
import Legacy

class RestLoyaltyService: LoyaltyService {
    private let rest: FullRestClient
    private let applicationSettingsService: ApplicationSettingsService
    private let store: Store

    init(rest: FullRestClient, store: Store, applicationSettingsService: ApplicationSettingsService) {
        self.rest = rest
        self.store = store
        self.applicationSettingsService = applicationSettingsService
    }

    private func cachedModel() -> LoyaltyModel? {
        var model: [LoyaltyModel] = []
        try? store.read { transaction in
            model = try transaction.select()
        }
        return model.first
    }

    func cachedLoyalty(forced: Bool) -> LoyaltyModel? {
        guard let insurances = cachedModel() else { return nil }

        if forced {
            return insurances
        } else {
            if let expDate = applicationSettingsService.loyaltyCacheExpDate, expDate > Date() {
                return insurances
            } else {
                return nil
            }
        }
    }

    func loyalty(useCache: Bool, completion: @escaping (Result<LoyaltyModel, AlfastrahError>) -> Void) {
        if useCache, let model = cachedLoyalty(forced: false) {
            completion(.success(model))
        } else {
            rest.read(
                path: "loyalty",
                id: nil,
                parameters: [:],
                headers: [:],
                responseTransformer: ResponseTransformer(key: "loyalty", transformer: LoyaltyModelTransformer()),
                completion: mapCompletion { [weak self] result in
                    switch result {
                        case .success(let response):
                            guard let self = self else { return }

                            try? self.store.write { transaction in
                                try transaction.delete(type: LoyaltyModel.self)
                                try transaction.insert(response)
                            }
                            self.applicationSettingsService.loyaltyCacheExpDate = Date(timeIntervalSinceNow: CacheExpiration.day)
                            completion(.success(response))
                        case .failure(let error):
                            completion(.failure(error))
                    }
                }
            )
        }
    }

    func loyaltyBlock(completion: @escaping (Result<[LoyaltyBlock], AlfastrahError>) -> Void) {
        rest.read(
            path: "api/loyalty/blocks",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "block_list",
                transformer: ArrayTransformer(transformer: LoyaltyBlockTransformer())
            ),
            completion: mapCompletion { completion($0) }
        )
    }

    func getBlockLink(blockId: Int, completion: @escaping (Result<String, AlfastrahError>) -> Void) {
        rest.read(
            path: "/api/loyalty/blocks/\(blockId)/deeplink/",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "deeplink", transformer: CastTransformer<Any, String>()),
            completion: mapCompletion { completion($0) }
        )
    }

    func loyaltyOperations(count: Int, offset: Int, completion: @escaping (Result<[LoyaltyOperation], AlfastrahError>) -> Void) {
        rest.read(
            path: "loyalty/operations",
            id: nil,
            parameters: [ "count": "\(count)", "offset": "\(offset)" ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "operation_list",
                transformer: ArrayTransformer(transformer: LoyaltyOperationTransformer(), skipFailures: false)
            ),
            completion: mapCompletion(completion)
        )
    }

    enum CacheExpiration {
        static let day = TimeInterval(60 * 60 * 24)
    }

    // MARK: - Updatable

    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func erase(logout: Bool) {
        try? store.write { transaction in
            try transaction.delete(type: LoyaltyModel.self)
        }
    }
}
