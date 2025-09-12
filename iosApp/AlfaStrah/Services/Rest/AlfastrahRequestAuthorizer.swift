//
//  AlfastrahRequestAuthorizer.swift
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 10.07.2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Legacy

protocol HttpRequestAuthorizer: RequestAuthorizer {
    func authorize(request: URLRequest) -> URLRequest
}

class AlfastrahRequestAuthorizer: HttpRequestAuthorizer {
    private let userAgent: String
	
    private var sessionToken: String?
    var tokenSubscription: Subscription?
	
    lazy private(set) var sessionListener: (UserSession?) -> Void = { [weak self] session in
        self?.sessionToken = session?.accessToken
    }

	init(accessToken: String?, userAgent: String) {
        self.userAgent = userAgent
        self.sessionToken = accessToken
    }

    func authorize(request: URLRequest, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = request
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        sessionToken.map { request.setValue("access_token=\($0)", forHTTPHeaderField: "Cookie") }
		sessionToken.map { request.setValue($0, forHTTPHeaderField: "Access-Token") }
		
        completion(.success(request))
    }

    func authorize(request: URLRequest) -> URLRequest {
        var request = request
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        sessionToken.map { request.setValue("access_token=\($0)", forHTTPHeaderField: "Cookie") }
		
        return request
    }

    func refresh(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.failure(AlfastrahError.unknownError))
        
        DispatchQueue.main.async {
            ApplicationFlow.shared.forceLogout()
        }
    }
}
