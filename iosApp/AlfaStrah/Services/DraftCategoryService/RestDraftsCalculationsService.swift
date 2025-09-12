//
//  RestDraftsCalculationsService.swift
//  AlfaStrah
//
//  Created by mac on 27.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy

class RestDraftsCalculationsService: DraftsCalculationsService {
    private let rest: FullRestClient
    
    init(rest: FullRestClient) {
        self.rest = rest
    }
    
    func getDraftCategories(completion: @escaping (Result<DraftsCalculationsCategoriesWithInfo, AlfastrahError>) -> Void) {
        rest.read(
            path: "/api/insurances/draft_calculations",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: DraftsCalculationsCategoriesWithInfoTransformer()),
            completion: mapCompletion(completion)
        )
    }
	
	func deleteDraft(by draftId: Int, completion: @escaping (Result<Void, AlfastrahError>) -> Void) {
		rest.create(
			path: "/api/insurances/draft_calculations/delete",
			id: nil,
			object: [
				"id": draftId,
			],
			headers: [:],
			requestTransformer: DictionaryTransformer(
				keyTransformer: CastTransformer<AnyHashable, String>(),
				valueTransformer: CastTransformer<Any, Any>()
			),
			responseTransformer: VoidTransformer(),
			completion: mapCompletion(completion)
		)
	}
}
