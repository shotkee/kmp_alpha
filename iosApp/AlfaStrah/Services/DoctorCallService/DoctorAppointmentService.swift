//
//  DoctorAppointmentService.swift
//  AlfaStrah
//
//  Created by vit on 20.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

protocol DoctorAppointmentService {
    func createAppointment(
        doctorAppointmentRequest: DoctorAppointmentRequest,
        completion: @escaping (Result<DoctorAppointmentInfoMessage, AlfastrahError>) -> Void
    )
}
