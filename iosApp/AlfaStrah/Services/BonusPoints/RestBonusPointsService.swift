//
//  RestBonusPointsService.swift
//  AlfaStrah
//
//  Created by vit on 18.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Legacy

class RestBonusPointsService: BonusPointsService {
	private let rest: FullRestClient
	private let store: Store
	
	private var isBonusPointsDataRequestInprogress = false
	
	init(rest: FullRestClient, store: Store) {
		self.rest = rest
		self.store = store
	}
	
	private func cachedBonusPointsData() -> BonusPointsData? {
		var bonusPointsData: BonusPointsData?
		try? store.read { transaction in
			bonusPointsData = try transaction.select().first
		}
		return bonusPointsData
	}
	
	func bonuses(useCache: Bool, completion: @escaping (Result<BonusPointsData, AlfastrahError>) -> Void) {
		if useCache, let bonusPointsData = cachedBonusPointsData() {
			completion(.success(bonusPointsData))
		} else {
			if !isBonusPointsDataRequestInprogress {
				isBonusPointsDataRequestInprogress = true
				rest.read(
					path: "api/bonuses",
					id: nil,
					parameters: [:],
					headers: [:],
					responseTransformer: ResponseTransformer(transformer: BonusPointsDataTransformer()),
					completion: mapCompletion { result in
						self.isBonusPointsDataRequestInprogress = false
						
						if case .success(let bonusPointsData) = result {
							try? self.store.write { transaction in
								try transaction.delete(type: BonusPointsData.self)
								try transaction.insert(bonusPointsData)
							}
						}

						completion(result)
					}
				)
			}
		}
	}
}
