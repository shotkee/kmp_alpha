//
//  Updatable.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 03/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

enum ServiceUpdateError: Error {
    case authNeeded
    case notImplemented
    case error(AlfastrahError)
}

protocol Updatable {
    // Perform action in silent mode not blocking user. Called on background queue
    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void)

    // Update services before app is ready for the user. Blocks user UI.
    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void)

    func erase(logout: Bool)
}
