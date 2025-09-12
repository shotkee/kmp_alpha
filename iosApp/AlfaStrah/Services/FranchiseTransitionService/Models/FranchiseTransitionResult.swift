//
//  FranchiseTransitionResult.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 11.07.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct FranchiseTransitionResult
{
    let persons: [FranchiseTransitionResultInsuredPerson]

    let state: Status

    // sourcery: transformer.name = "result_message"
    let message: String?

    // sourcery: enumTransformer
    enum Status: Int
    {
        // sourcery: defaultCase
        case nothingChanged = 0
        case changedAllPrograms = 1
        case changedSomePrograms = 2
    }

    var isSuccessful: Bool
    {
        switch state
        {
            case .nothingChanged, .changedSomePrograms:
                return false
            case .changedAllPrograms:
                return true
        }
    }
}
