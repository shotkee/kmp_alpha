//
//  RestEsiaService.swift
//  AlfaStrah
//
//  Created by vit on 06.12.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy

class RestEsiaService: EsiaService {
    private let rest: FullRestClient
    private let secretKey: String
    
    private var authRequestInProgress = false
    
    private var authorizationData: AuthorizationResponse?
    
    var session: UserSession? {
        get {
            return authorizationData?.session
        }
    }
    
    var sessionWasReceived: Bool {
        get {
            return authorizationData != nil
        }
    }
    
    var sessionRequestInProggress: Bool {
        get {
            return authRequestInProgress
        }
    }
    
    init(
        rest: FullRestClient,
        secretKey: String
    ) {
        self.rest = rest
        self.secretKey = secretKey
    }
    
    func redirect(completion: @escaping (Result<EsiaAuthDataResponse, AlfastrahError>) -> Void) {
        rest.read(
            path: "api/esia/auth_link",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: EsiaAuthDataResponseTransformer()),
            completion: mapCompletion(completion)
        )
    }
    
    func features(completion: @escaping (Result<[String: Any], AlfastrahError>) -> Void) {
        rest.read(
            path: "features",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "features",
                transformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, Any>()
            )),
            completion: mapCompletion(completion)
        )
    }
    
    func auth(
        esiaToken: String,
        deviceToken: String,
        completion: @escaping (Result<AuthorizationResponse, AlfastrahError>) -> Void
    ) {
        if let authorizationData = self.authorizationData {
            completion(.success(authorizationData))
        } else {
            if !authRequestInProgress {
                authRequestInProgress = true
                
                let (seed, hash) = getSeedAndHash(
                    esiaToken,
                    secretKey: secretKey,
                    deviceToken: deviceToken
                )
                
                rest.create(
                    path: "api/esia/access_token",
                    id: nil,
                    object: [
                        "token": esiaToken,
                        "device_token": deviceToken,
                        "seed": seed,
                        "hash": hash
                    ],
                    headers: [:],
                    requestTransformer: DictionaryTransformer(
                        keyTransformer: CastTransformer<AnyHashable, String>(),
                        valueTransformer: CastTransformer<Any, String>()
                    ),
                    responseTransformer: ResponseTransformer(transformer: AuthorizationResponseTransformer()),
                    completion: mapCompletion { result in
                        self.authRequestInProgress = false
                        switch result {
                            case .success(let authorizationData):
                                self.authorizationData = authorizationData
                                completion(.success(authorizationData))
                            case .failure(let error):
                                completion(.failure(error))
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Updatable
    func erase(logout: Bool) {
        if logout {
            self.authorizationData = nil
        }
    }
    
    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.success(()))
    }
}
