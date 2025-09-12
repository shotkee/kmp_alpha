//
//  InsuredPerson.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 08.07.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct FranchiseTransitionInsuredPerson
{
    let id: Int

    // sourcery: transformer.name = "first_name"
    let firstName: String

    // sourcery: transformer.name = "last_name"
    let lastName: String

    let patronymic: String?

    // sourcery: transformer.name = "has_program_pdf"
    let hasProgramPdf: Bool

    // sourcery: transformer.name = "has_clinics_pdf"
    let hasClinicsPdf: Bool

    // sourcery: transformer.name = "is_checked"
    let isCheckedByDefault: Bool

    // sourcery: transformer.name = "is_readonly"
    let isCheckboxReadonly: Bool
}
