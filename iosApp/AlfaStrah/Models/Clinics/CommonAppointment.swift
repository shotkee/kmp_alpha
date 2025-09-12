//
//  CommonAppointment.swift
//  AlfaStrah
//
//  Created by Vitaly Shkinev on 14.09.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

protocol CommonAppointment {
    var doctorPhotoUrl: URL? { get }
    var doctorFullName: String? { get }
    var appointmentDate: Date? { get }
    var compareDate: Date? { get }
    var description: String? { get }
    var clinic: Clinic? { get }
    var type: CommonAppointmentType { get }
	var status: AppointmentStatus? { get }
}

enum CommonAppointmentType {
    case offline(_ id: Int)
    case infoClinic(_ id: String)
}
