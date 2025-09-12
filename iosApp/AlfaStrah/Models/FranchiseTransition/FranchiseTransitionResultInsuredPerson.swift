//
//  FranchiseTransitionInsuredPerson.swift
//  AlfaStrah
//
//  Created by Vitaly Shkinev on 12.07.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct FranchiseTransitionResultInsuredPerson
{
    let id: Int

    // sourcery: transformer.name = "first_name"
    let firstName: String

    // sourcery: transformer.name = "last_name"
    let lastName: String

    let patronymic: String?

    // sourcery: transformer.name = "is_successful"
    let isTransitionSuccessful: Bool

    // sourcery: transformer.name = "result_message"
    let transitionStatusDescription: String
}
