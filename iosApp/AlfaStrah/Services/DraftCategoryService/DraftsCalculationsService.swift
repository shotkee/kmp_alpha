//
//  DraftsCalculationsService.swift
//  AlfaStrah
//
//  Created by mac on 27.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

protocol DraftsCalculationsService {
    func getDraftCategories(completion: @escaping (Result<DraftsCalculationsCategoriesWithInfo, AlfastrahError>) -> Void)
	func deleteDraft(by draftId: Int, completion: @escaping (Result<Void, AlfastrahError>) -> Void)
}
