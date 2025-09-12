//
//  CampaignService.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 29/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//
import Legacy

protocol CampaignService {
    func campaigns(completion: @escaping (Result<[Campaign], AlfastrahError>) -> Void)
}
