//
//  KaskoExtensionService.swift
//  AlfaStrah
//
//  Created by vit on 10.03.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

protocol KaskoExtensionService {
    func kaskoExtensionUrl(insuranceId: String, completion: @escaping (Result<URL, AlfastrahError>) -> Void)
}
