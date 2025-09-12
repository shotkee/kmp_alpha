//
//  AVISAppointment.swift
//  AlfaStrah
//
//  Created by Vitaly Shkinev on 01.09.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import SwiftDate

// sourcery: transformer
struct AVISAppointment: CommonAppointment {
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum ClinicType {
        // sourcery: enumTransformer.value = "avis"
        case avis
        // sourcery: enumTransformer.value = "javis"
        case javis
    }
    
    // sourcery: transformer.name = "id"
    let id: Int
    // sourcery: transformer.name = "full_date"
    // sourcery: transformer = "ISODateInRegionTransofrmer<Any>()"
    var localDate: DateInRegion
    // sourcery: transformer.name = "clinic_type"
    var clinicType: AVISAppointment.ClinicType
    // sourcery: transformer.name = "clinic"
    var avisClinic: Clinic?
    // sourcery: transformer.name = "clinic_javis"
    var javisClinic: JavisClinic?
    // sourcery: transformer.name = "can_be_cancelled"
    let canBeCancelled: Bool
    // sourcery: transformer.name = "can_be_recreated"
    let canBeRecreated: Bool
    // sourcery: transformer.name = "doctor"
    let doctorFullName: String?
    // sourcery: transformer.name = "description"
    let referralOrDepartment: String?
	// sourcery: transformer.name = "status"
	let status: AppointmentStatus?
    
    var appointmentDate: Date? {
        // DateInRegion date field is utc date to timezone
        // (2023-05-02T16:00:00+03:00; DateInRegion.date = 2023.05.02 13:00)
        // so we need move utc timestamp to clinic local timezone
        // and use UTC timezone in formatter to represent appointment date
        guard let clinicLocalDate = Calendar.current.date(
            byAdding: .second,
            value: localDate.region.timeZone.secondsFromGMT(),
            to: localDate.date
        ) else { return nil }
        
        return clinicLocalDate
    }
    
    var compareDate: Date? {
        // avis appoinment date coming in clinic's (supposedly) timezone
        if let destinationTimeZone = TimeZone(identifier: "Europe/Moscow") {
            let sourceTimezone = localDate.region.timeZone
            return localDate.date.convert(
                from: sourceTimezone,
                to: destinationTimeZone
            )
        } else {
            return nil
        }
    }
    
    var doctorPhotoUrl: URL? {
        return nil
    }
            
    var description: String? {
        return referralOrDepartment
    }
    
    var type: CommonAppointmentType {
        return .offline(id)
    }
    
    var clinic: Clinic? {
        switch clinicType {
            case .avis:
                return avisClinic
            case .javis:
                guard let javisClinic = self.javisClinic
                else { return nil }
            
                var phones: [Phone] = []
                if let phone = javisClinic.phone {
                    phones.append(phone)
                }
            
                return  Clinic(
                    id: javisClinic.id,
                    title: javisClinic.title,
                    address: javisClinic.address,
                    coordinate: javisClinic.coordinate,
					serviceHours: "",
					labelList: [],
					metroList: [],
					serviceList: [],
					url: nil,
					phoneList: phones,
					buttonText: "",
					buttonAction: .appointmentOffline,
					filterList: [],
					franchise: false
                )
        }
    }
}

private extension Date {
    func convert(from timeZone: TimeZone, to destinationTimeZone: TimeZone) -> Date? {
        let calendar = Calendar.current
        
        var components = calendar.dateComponents(in: timeZone, from: self)
        
        components.timeZone = destinationTimeZone

        return calendar.date(from: components)
    }
}
