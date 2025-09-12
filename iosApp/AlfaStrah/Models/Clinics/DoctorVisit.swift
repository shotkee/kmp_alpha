//
//  DoctorVisit.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 14/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

// sourcery: transformer
struct DoctorVisit: CommonAppointment {    
    // sourcery: transformer = IdTransformer<Any>()
    let id: String
    let clinic: Clinic?
    var doctor: ShortDoctor
    // sourcery: transformer.name = "interval"
    var doctorScheduleInterval: DoctorScheduleInterval
    // sourcery: transformer.name = "insurance_id"
    let insuranceId: String
    // sourcery: transformer.name = "alert"
    let alertMessage: String?
	// sourcery: transformer.name = "status"
	let status: AppointmentStatus?
        
    var doctorPhotoUrl: URL? {
        return self.doctor.photoUrl
    }
    
    var doctorFullName: String? {
        return self.doctor.title
    }
    
    var appointmentDate: Date? {
        return self.doctorScheduleInterval.startDate
    }
    
    var compareDate: Date? {
        return self.doctorScheduleInterval.startDate
    }
    
    var description: String? {
        return self.doctor.speciality.title
    }
    
    var type: CommonAppointmentType {
        return .infoClinic(self.id)
    }
}

// sourcery: transformer
struct DoctorVisitsResponse {
    // sourcery: transformer.name = "visit_list"
    var visits: [DoctorVisit]
    // sourcery: transformer.name = "total_count"
    var total: Int
}
