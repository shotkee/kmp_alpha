//
//  MobileDeviceTokenService.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 12.11.2021.
//  Copyright © 2021 Touch Instinct. All rights reserved.
//

typealias MobileDeviceToken = String

protocol MobileDeviceTokenService {
    func resetDeviceToken()
    func getDeviceToken(completion: @escaping (Result<MobileDeviceToken, AlfastrahError>) -> Void)
}
