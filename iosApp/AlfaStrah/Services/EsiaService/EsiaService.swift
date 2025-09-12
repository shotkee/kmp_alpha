//
//  EsiaService.swift
//  AlfaStrah
//
//  Created by vit on 06.12.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

protocol EsiaService: Updatable {
    func redirect(completion: @escaping (Result<EsiaAuthDataResponse, AlfastrahError>) -> Void)

    func auth(
        esiaToken: String,
        deviceToken: String,
        completion: @escaping (Result<AuthorizationResponse, AlfastrahError>) -> Void
    )
    
    func features(completion: @escaping (Result<[String: Any], AlfastrahError>) -> Void)
    
    var sessionWasReceived: Bool { get }
    
    var sessionRequestInProggress: Bool { get }
    
    var session: UserSession? { get }
}
