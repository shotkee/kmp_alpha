//
//  ChatRequestAutorizer.swift
//  AlfaStrah
//
//  Created by vit on 21.06.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation
import Legacy

class ChatRequestAutorizer: HttpRequestAuthorizer {
    private let userAgent = UserAgent.main
    
    var refreshRest: FullRestClient?
    var middleRest: FullRestClient?
    var session: CascanaChatSession?
    
    var sessionSubscription: Subscription?
    lazy private(set) var sessionListener: (CascanaChatSession?) -> Void = { [weak self] session in
        self?.session = session
    }

    func authorize(request: URLRequest, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = request
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        if let accessToken = session?.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        completion(.success(request))
    }

    func authorize(request: URLRequest) -> URLRequest {
        var request = request
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        if let accessToken = session?.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    private var refreshSessionIndex = 0
    private let refreshSessionTryLimit = 5

    func refresh(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let refreshToken = self.session?.refreshToken,
              let refreshRest = self.refreshRest
        else { return }
        
        if refreshSessionIndex >= refreshSessionTryLimit {
            refreshSessionIndex = 0
            completion(.failure(AlfastrahError.unknownError))
            
            self.refreshChatSession { result in
                switch result {
                    case .success(let session):
                        self.refreshSessionIndex = 0
                        
                        self.session = session
                        completion(.success(()))
                        
                    case .failure(let error):
                        completion(.failure(error))
                        
                }
            }
            
            return
        }
        
        refreshSessionIndex += 1
        
        refreshRest.create(
            path: "CEC.ChatBackend.VerificationService/api/Token/refresh",
            id: nil,
            object: ["refreshToken": refreshToken],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: CascanaChatTokenResponseTransformer(),
            completion: mapCompletion { result in
                switch result {
                    case .success(let tokenResponse):
                        self.refreshSessionIndex = 0
                        
                        self.session = CascanaChatSession(
                            accessToken: tokenResponse.accessToken,
                            refreshToken: tokenResponse.refreshToken
                        )
                        
                        completion(.success(()))
                        
                    case .failure:
                        self.refreshChatSession { result in
                            switch result {
                                case .success(let session):
                                    self.refreshSessionIndex = 0
                                    
                                    self.session = session
                                    completion(.success(()))
                                    
                                case .failure(let error):
                                    completion(.failure(error))
                                    
                            }
                        }
                }
            }
        )
    }
    
    private func refreshChatSession(completion: @escaping (Result<CascanaChatSession, AlfastrahError>) -> Void) {
        guard let rest = middleRest
        else { return }
        
        let task = rest.read(
            path: "api/account/cascana",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: CascanaChatSessionTransformer()),
            completion: mapCompletion { result in
                switch result {
                    case .success(let response):
                        completion(.success(response))
                    case .failure(let error ):
                        completion(.failure(error))
                }
            }
        )
    }
}
