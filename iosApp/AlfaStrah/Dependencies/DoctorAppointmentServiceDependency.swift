//
//  DoctorAppointmentServiceDependency.swift
//  AlfaStrah
//
//  Created by vit on 20.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

protocol DoctorAppointmentServiceDependency {
    var doctorAppointmentService: DoctorAppointmentService! { get set }
}
