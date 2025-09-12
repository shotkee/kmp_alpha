//
//  MedicalCardFile.swift
//  AlfaStrah
//
//  Created by vit on 19.04.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct MedicalCardFile: Entity {
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum Status: String {
        // sourcery: enumTransformer.value = "processing"
        case inProgress = "processing"
        // sourcery: enumTransformer.value = "success"
        case success = "success"
        // sourcery: enumTransformer.value = "failure_type"
        case typeNotSupported = "failure_type"
        // sourcery: enumTransformer.value = "failure_common"
        case commonError = "failure_common"
		// sourcery: enumTransformer.value = "failure_antivirus"
		case antivirusError = "failure_antivirus"
    }
    // sourcery: transformer.name = "file_id"
    let id: Int64
    // sourcery: transformer.name = "datetime_created"
    // sourcery: transformer = "DateTransformer<Any>()"
    let creationDate: Date
    // sourcery: transformer.name = "title"
    let name: String
    // sourcery: transformer.name = "status"
    let status: Status
    // sourcery: transformer.name = "size"
    let sizeInBytes: Int
    // sourcery: transformer.name = "title_extension"
    var fileExtension: String?
}
