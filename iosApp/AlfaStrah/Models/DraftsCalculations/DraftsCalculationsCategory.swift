//
//  DraftsCalculationsCategory.swift
//  AlfaStrah
//
//  Created by mac on 27.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct DraftsCalculationsCategory {
    // sourcery: transformer.name = "category_id"
    let id: Int
    
    // sourcery: transformer.name = "icon", transformer = "UrlTransformer<Any>()"
    let icon: URL

	// sourcery: transformer.name = "icon_themed"
	let iconThemed: ThemedValue?
    
    // sourcery: transformer.name = "title_in_filters"
    let titleInFilters: String
    
    // sourcery: transformer.name = "title"
    let title: String
    
    // sourcery: transformer.name = "draft_list"
    let drafts: [DraftsCalculationsData]
    
    // sourcery: transformer.name = "show_in_filters"
    let shownInFilters: Bool
    
}
