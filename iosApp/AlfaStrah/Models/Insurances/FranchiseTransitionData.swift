//
//  FranchiseTransitionData.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 08.07.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct FranchiseTransitionData
{
    let persons: [FranchiseTransitionInsuredPerson]

    // sourcery: transformer.name = "has_program_terms_pdf"
    let hasPdfWithProgramTerms: Bool

    // sourcery: transformer.name = "terms_message"
    let programTermsButtonTitle: String?

    // sourcery: transformer.name = "invitation_message"
    let promptText: String

    // sourcery: transformer.name = "approval_message"
    let confirmationText: String
}
