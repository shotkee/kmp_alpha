//
//  Story.swift
//  AlfaStrah
//
//  Created by Makson on 07.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct Story: Entity {
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum Status: String {
        // sourcery: enumTransformer.value = "unviewed"
        case unviewed = "unviewed"
        // sourcery: enumTransformer.value = "viewed"
        case viewed = "viewed"
    }
    // sourcery: transformer.name = "story_id"
    let id: Int
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "title_color"
    let titleColor: String
    // sourcery: transformer.name = "preview", transformer = "UrlTransformer<Any>()"
    let preview: URL
    // sourcery: transformer.name = "page_list"
    let pageList: [StoryPage]
    // sourcery: transformer.name = "status"
    let status: Status
    
    // MARK: - Mutations
    
    func updating(status: Status) -> Self {
        return .init(
            id: id,
            title: title,
            titleColor: titleColor,
            preview: preview,
            pageList: pageList,
            status: status
        )
    }
}
