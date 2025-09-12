//
//  RestEndpointsService.swift
//  AlfaStrah
//
//  Created by vit on 28.07.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy

class RestEndpointsService: EndpointsService {
    typealias ResultCallback = (Result<Endpoints, AlfastrahError>) -> Void
    private let rest: FullRestClient
    
    private var endpoints: Endpoints?
    private var isOprerationInProgress: Bool = false
    private var completions: [ResultCallback] = []

    init(rest: FullRestClient) {
        self.rest = rest
    }
    
    var medicalCardFileServerDomain: String? {
        return endpoints?.medicalCardFileServerDomain
    }
	
	var productsUrlBDUI: URL? {
		return endpoints?.productsUrlBDUI
	}
    
    func endpoints(completion: @escaping (Result<Endpoints, AlfastrahError>) -> Void) {
        if let endpoints = endpoints {
            completion(.success(endpoints))
        } else {
            completions.append(completion)
            
            if !isOprerationInProgress {
                isOprerationInProgress = true
                rest.read(
                    path: "endpoints",
                    id: nil,
                    parameters: [:],
                    headers: [:],
                    responseTransformer: EndpointsTransformer(),
                    completion: mapCompletion { result in
                        self.isOprerationInProgress = false
                        
                        switch result {
                            case .success(let endpoints):
                                self.endpoints = endpoints
                            case .failure:
                                break
                        }

                        self.completions.forEach { $0(result) }
                        self.completions.removeAll()
                    }
                )
            }
        }
    }
}
