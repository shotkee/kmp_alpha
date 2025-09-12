//
//  ShortDoctor.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 29/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

// sourcery: transformer
struct ShortDoctor {
    // sourcery: transformer = IdTransformer<Any>()
    let id: String
    let title: String
    // sourcery: transformer.name = "doctor_speciality"
    let speciality: DoctorSpeciality
    // sourcery: transformer.name = "photo_url", transformer = "UrlTransformer<Any>()"
    var photoUrl: URL?
    // sourcery: transformer.name = "experience_years"
    var yearsOfExperience: Int?
    // sourcery: transformer.name = "experience_description"
    var experience: String?
}
