//
//  BonusPointsService.swift
//  AlfaStrah
//
//  Created by vit on 18.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

protocol BonusPointsService {
	func bonuses(useCache: Bool, completion: @escaping (Result<BonusPointsData, AlfastrahError>) -> Void)
}
