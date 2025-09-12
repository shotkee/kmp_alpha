//
//  StoryPageBody.swift
//  AlfaStrah
//
//  Created by Makson on 07.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct StoryPageBody {
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum ImageType: String {
        // sourcery: enumTransformer.value = "image"
        case image = "image"
    }
    
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum BackgroundImageType: String {
        // sourcery: enumTransformer.value = "image"
        case image = "image"
        // sourcery: enumTransformer.value = "color_fill"
        case colorFill = "color_fill"
    }
    
    // sourcery: transformer.name = "title"
    let title: String?
    // sourcery: transformer.name = "title_color"
    let titleColor: String?
    // sourcery: transformer.name = "text"
    let text: String?
    // sourcery: transformer.name = "text_color"
    let textColor: String?
    // sourcery: transformer.name = "image_type"
    let imageType: ImageType?
    // sourcery: transformer.name = "image", transformer = "UrlTransformer<Any>()"
    let image: URL?
    // sourcery: transformer.name = "background_image_type"
    let backgroundImageType: BackgroundImageType
    // sourcery: transformer.name = "background_image", transformer = "UrlTransformer<Any>()"
    let backgroundImage: URL?
    // sourcery: transformer.name = "background_color"
    let backgroundColor: String?
}
