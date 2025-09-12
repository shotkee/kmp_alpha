//
//  LoyaltyService.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 28/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//
import Legacy

protocol LoyaltyService: Updatable {
    func loyalty(useCache: Bool, completion: @escaping (Result<LoyaltyModel, AlfastrahError>) -> Void)
    func loyaltyOperations(count: Int, offset: Int, completion: @escaping (Result<[LoyaltyOperation], AlfastrahError>) -> Void)
    func cachedLoyalty(forced: Bool) -> LoyaltyModel?
    func loyaltyBlock(completion: @escaping (Result<[LoyaltyBlock], AlfastrahError>) -> Void)
    func getBlockLink(blockId: Int, completion: @escaping (Result<String, AlfastrahError>) -> Void)
}
