//
//  FullDoctor.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 29/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

// sourcery: transformer
struct FullDoctor {
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
    // sourcery: transformer.name = "interval_dates"
    var schedules: [DoctorSchedule]

    var shortDoctor: ShortDoctor {
        ShortDoctor(
            id: id,
            title: title,
            speciality: speciality,
            photoUrl: photoUrl,
            yearsOfExperience: yearsOfExperience,
            experience: experience
        )
    }
}
