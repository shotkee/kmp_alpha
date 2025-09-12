//
//  HealthAcademyService.swift
//  AlfaStrah
//
//  Created by mac on 08.08.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//
import Legacy

protocol HealthAcademyService {
    func getData(completion: @escaping (Result<[HealthAcademyCardGroup]?, AlfastrahError>) -> Void)
}
