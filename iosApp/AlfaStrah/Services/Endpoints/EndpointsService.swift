//
//  EndpointsService.swift
//  AlfaStrah
//
//  Created by vit on 28.07.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

protocol EndpointsService {
    func endpoints(completion: @escaping (Result<Endpoints, AlfastrahError>) -> Void)
    var medicalCardFileServerDomain: String? { get }
	var productsUrlBDUI: URL? { get }
}
