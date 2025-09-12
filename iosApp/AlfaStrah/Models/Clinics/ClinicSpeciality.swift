//
//  ClinicSpeciality.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 13.10.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct ClinicSpeciality {
    let id: Int
    let title: String
    // sourcery: transformer.name = "user_input_required"
    let userInputRequired: Bool
}
