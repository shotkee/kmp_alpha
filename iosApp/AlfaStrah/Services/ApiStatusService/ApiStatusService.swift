//
//  ApiStatusService.swift
//  AlfaStrah
//
//  Created by Vitaly Shkinev on 21.11.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

protocol ApiStatusService {
    func apiStatus(completion: @escaping (Result<ApiStatus, AlfastrahError>) -> Void)
}
