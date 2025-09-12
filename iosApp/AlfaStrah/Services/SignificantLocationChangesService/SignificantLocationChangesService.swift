//
//  SignificantLocationChangesService.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 27.02.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Legacy

protocol SignificantLocationChangesService {
    typealias SubscriptionCallback = (_ location: Coordinate) -> Void
    func start()
    func stop()
    func subscribeForLocation(_ callback: @escaping SubscriptionCallback) -> Subscription
}
