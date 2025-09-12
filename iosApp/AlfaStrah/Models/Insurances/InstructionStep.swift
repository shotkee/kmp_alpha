//
//  InstructionStep.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 31/03/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct InstructionStep: Entity {
    // sourcery: transformer.name = "sort_number"
    var sortNumber: Int
    var title: String
    // sourcery: transformer.name = "full_description"
    var fullDescription: String
}
