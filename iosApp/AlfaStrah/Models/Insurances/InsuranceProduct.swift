//
//  InsuranceProduct
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 15/12/2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct InsuranceProduct: Entity {
    // sourcery: transformer.name = "product_id"
    let id: Int64
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "text"
    let text: String
    // sourcery: transformer.name = "tag_list"
    let tagList: [InsuranceProductTag]
    // sourcery: transformer.name = "image", transformer = "UrlTransformer<Any>()"
    let image: URL
    // sourcery: transformer.name = "detailed_image", transformer = "UrlTransformer<Any>()"
    let detailedImage: URL
    // sourcery: transformer.name = "detailed_content"
    let detailedContent: [InsuranceProductDetailedContent]
    // sourcery: transformer.name = "detailed_button"
    let detailedButton: InsuranceProductDetailedButton?
}

// sourcery: transformer
struct InsuranceProductTag: Entity {
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "title_color"
    let titleColor: String
	// sourcery: transformer.name = "title_color_themed"
	let titleColorThemed: ThemedValue?
    // sourcery: transformer.name = "background_color"
    let backgroundColor: String
	// sourcery: transformer.name = "background_color_themed"
	let backgroundColorThemed: ThemedValue?
}

// sourcery: transformer
struct InsuranceProductDetailedContent: Entity {
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum ContentType: String {
        // sourcery: enumTransformer.value = "title"
        case title = "title"
        // sourcery: enumTransformer.value = "linked_text"
        case linkedText = "linked_text"
        // sourcery: enumTransformer.value = "list_with_checkmark"
        case listWithCheckmark = "list_with_checkmark"
        // sourcery: enumTransformer.value = "image"
        case image = "image"
    }
    
    // sourcery: transformer.name = "type"
    let contentType: ContentType
    // sourcery: transformer.name = "data"
    let data: InsuranceProductDetailedContentData
}

// sourcery: transformer
struct InsuranceProductDetailedContentData: Entity {
    // sourcery: transformer.name = "text"
    let text: String?
    // sourcery: transformer.name = "text"
    let linkedText: LinkedText?
    // sourcery: transformer.name = "text_list"
    let textArray: [String]?
    // sourcery: transformer.name = "image", transformer = "UrlTransformer<Any>()"
    let image: URL?
}

// sourcery: transformer
struct InsuranceProductDetailedButton {
    // sourcery: transformer.name = "button_text_color"
    let textColor: String
	// sourcery: transformer.name = "button_text_color_themed"
	let textColorThemed: ThemedValue?
    // sourcery: transformer.name = "button_color"
    let buttonColor: String
	// sourcery: transformer.name = "button_color_themed"
	let buttonColorThemed: ThemedValue?
    // sourcery: transformer.name = "action"
    let action: BackendAction
}
