//
//  FranchiseTransitionUtils.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 14.07.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

func formatInsuredPersonName(
    firstName: String,
    lastName: String,
    patronymic: String?
) -> String
{
    let patronymic = patronymic.map { " \($0)" } ?? ""
    return "\(lastName) \(firstName)\(patronymic)"
}
