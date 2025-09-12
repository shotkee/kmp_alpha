//
//  FranchiseTransitionRequest.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 14.07.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct FranchiseTransitionRequest
{
    // sourcery: transformer.name = "insurance_id"
    // sourcery: transformer = IdTransformer<Any>()
    let insuranceId: String

    // sourcery: transformer.name = "person_ids"
    let personIds: [Int]
}
