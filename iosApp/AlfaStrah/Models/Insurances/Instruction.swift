//
//  Instruction.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 31/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct Instruction: Entity {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String
    // sourcery: transformer.name = "insurance_category_id", transformer = IdTransformer<Any>()
    var insuranceCategoryId: String
    // sourcery: transformer.name = "last_modified", , transformer = "TimestampTransformer<Any>(scale: 1)"
    var lastModified: Date
    var title: String
    // sourcery: transformer.name = "short_description"
    var shortDescription: String
    // sourcery: transformer.name = "full_description"
    var fullDescription: String
    var steps: [InstructionStep]
}
