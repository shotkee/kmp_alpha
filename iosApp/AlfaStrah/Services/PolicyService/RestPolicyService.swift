//
//  PolicyService.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 18.06.2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Legacy

class RestPolicyService: PolicyService {
    private let rest: FullRestClient
    
    private var cancellable = CancellableNetworkTaskContainer()
    private var registerTerms: LinkedText?

    init(rest: FullRestClient) {
        self.rest = rest
    }

    private func loadPolicies(completion: @escaping (Result<AlfastrahPolicies, AlfastrahError>) -> Void) {
        rest.read(
            path: "docs",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: AlfastrahPoliciesTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func loadTelematicsPolicyHTML(completion: @escaping (Result<String, AlfastrahError>) -> Void) {
        loadPolicies { completion($0.map { $0.telematic }) }
    }

    func getPersonalDataUsageTermsUrl(
        on screen: PolicyServiceScreen,
        completion: @escaping (Result<PersonalDataUsageAndPrivacyPolicyURLs, AlfastrahError>) -> Void
    ) {
        rest.read(
            path: "api/agreements/links",
            id: nil,
            parameters: [ "screen": "\(screen.rawValue)" ],
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: PersonalDataUsageAndPrivacyPolicyURLsTransformer()),
            completion: mapCompletion(completion)
        )
    }
    
    func registerTerms(completion: @escaping (Result<LinkedText, AlfastrahError>) -> Void) {
        if let registerTerms = registerTerms {
            completion(.success(registerTerms))
        } else {
            let task = rest.read(
                path: "api/texts",
                id: nil,
                parameters: [:],
                headers: [:],
                responseTransformer: ResponseTransformer(key: "register", transformer: LinkedTextTransformer()),
                completion: mapCompletion { result in
                    self.cancellable = CancellableNetworkTaskContainer()
                    switch result {
                        case .success(let terms):
                            self.registerTerms = terms
                            completion(.success(terms))
                        case .failure(let error ):
                            completion(.failure(error))
                    }
                }
            )
            
            cancellable.addCancellables([ task ])
        }
    }
    
    // MARK: - Updatable
    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }
    
    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        if !isUserAuthorized {
            registerTerms { _ in }
        }
    }
    
    func erase(logout: Bool) {
        if logout {
            cancellable.cancel()
            registerTerms = nil
        }
    }
}
