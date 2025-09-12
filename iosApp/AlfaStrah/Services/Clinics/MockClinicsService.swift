//
//  MockClinicsService.swift
//  AlfaStrah
//
//  Created by Vitaly Shkinev on 02.09.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import Legacy
import SwiftDate

final class MockClinicsService: ClinicsService {
	
	func clinics(insuranceId: String, completion: @escaping (Result<ClinicResponse, AlfastrahError>) -> Void) 
	{
		completion(.failure(.api(.init(httpCode: 999, internalCode: 0, title: "Not implemented", message: "Not implemented"))))
	}
	
    // MARK: - Offline appointment

    func clinicsTreatments(completion: @escaping (Result<[ClinicTreatment], AlfastrahError>) -> Void) {
        completion(.failure(.api(.init(httpCode: 999, internalCode: 0, title: "Not implemented", message: "Not implemented"))))
    }

    func clinics(insuranceId: String, treatments: [ClinicTreatment], completion: @escaping (Result<[Clinic], AlfastrahError>) -> Void) {
        completion(.failure(.api(.init(httpCode: 999, internalCode: 0, title: "Not implemented", message: "Not implemented"))))
    }

    func citiesWithMetro(completion: @escaping (Result<[CityWithMetro], AlfastrahError>) -> Void) {
        completion(.failure(.api(.init(httpCode: 999, internalCode: 0, title: "Not implemented", message: "Not implemented"))))
    }

    func metroStations(
        in city: CityWithMetro,
        insuranceId: String,
        completion: @escaping (Result<[MetroStation], AlfastrahError>) -> Void
    ) {
        completion(.failure(.api(.init(httpCode: 999, internalCode: 0, title: "Not implemented", message: "Not implemented"))))
    }

    func createOfflineAppointment(
        cancelingAppointmentAvisId: Int?,
        _ newAppointment: OfflineAppointmentRequest,
        completion: @escaping (Result<Void, AlfastrahError>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int.random(in: 1..<3))) {
            completion(.success(()))
        }
    }

    func offlineAppointments(completion: @escaping (Result<[OfflineAppointment], AlfastrahError>) -> Void) {
        completion(.failure(.api(.init(httpCode: 999, internalCode: 0, title: "Not implemented", message: "Not implemented"))))
    }

    func offlineAppointment(id: String, completion: @escaping (Result<OfflineAppointment, AlfastrahError>) -> Void) {
        let phone = Phone(
            plain: "89999999999",
            humanReadable: "8 (999) 999-99-99"
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int.random(in: 1..<3))) {
            completion(.success(
                OfflineAppointment(
                    id: "123456",
                    appointmentNumber: "123456",
                    phone: phone,
                    date: Date(),
                    reason: "reason",
                    clinicId: "123456",
                    insuranceId: "123456"
                )
            ))
        }
    }

    func offlineAppointmentSettings(
        for clinicId: String,
        completion: @escaping (Result<OfflineAppointmentSettings, AlfastrahError>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int.random(in: 1..<3))) {
            
            if self.clinic.id == clinicId {
                completion(.success(self.defaultClinicInfoSpecilalities))
                return
            }
            
            if self.clinicAVIS.id == clinicId {
                completion(.success(self.defaultClinicAvisSpecilalities))
                return
            }
            
            completion(.failure(.api(.init(httpCode: 999, internalCode: 0, title: "", message: "clinic id not exist"))))
        }
    }
    
    func offlineAppointmentsAVIS(
        byInsuranceId insuranceId: String,
        completion: @escaping (Result<[AVISAppointment], AlfastrahError>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int.random(in: 1..<3))) { [weak self] in
            completion(.success(self?.avisAppointments ?? []))
        }
    }
        
    func cancelOfflineAppointmentAVIS(
        id: Int,
        insuranceId: String,
        completion: @escaping (Result<Void, AlfastrahError>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int.random(in: 1..<3))) {
            completion(.success(()))
        }
    }

    // MARK: - Online appointment

    func specialities(
        for clinicId: String,
        insuranceId: String,
        completion: @escaping (Result<[DoctorSpeciality], AlfastrahError>) -> Void
    ) {
        completion(.success(doctorsInPastSpecialities))
    }

    func doctors(
        for clinicId: String,
        insuranceId: String,
        specialityId: String,
        for date: Date,
        completion: @escaping (Result<[FullDoctor], AlfastrahError>) -> Void
    ) {
        guard let speciality = doctorsInPastSpecialities.first(where: { $0.id == specialityId }) else { return }

        completion(.success(doctorsInPast[speciality.id, default: []]))
    }

    func doctor(
        id: String,
        clinicId: String,
        specialityId: String,
        insuranceId: String,
        scheduleStartDate: Date,
        scheduleEndDate: Date,
        completion: @escaping (Result<FullDoctor, AlfastrahError>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int.random(in: 1..<3))) {
            if let specialityInPast = self.doctorsInPastSpecialities.first(where: {
                $0.id == specialityId
            }) {
                let doctors = self.doctorsInPast[specialityInPast.id, default: []]
                if let doctor = doctors.first(where: { $0.id == id }) {
                    completion(.success(doctor))
                    return
                }
            }
            
            if let specialityInFuture = self.doctorsInFutureSpecialities.first(where: {
                $0.id == specialityId
            }) {
                let doctors = self.doctorsInFuture[specialityInFuture.id, default: []]
                if let doctor = doctors.first(where: { $0.id == id }) {
                    completion(.success(doctor))
                    return
                }
            }
            
            completion(.failure(.api(.init(httpCode: 999, internalCode: 0, title: "", message: "Doctor id not exist"))))
        }
    }

    func createAppointment(_ doctorVisit: DoctorVisit, completion: @escaping (Result<Void, AlfastrahError>) -> Void) {
        let doctorVisit = DoctorVisit(
            id: nextId(),
            clinic: doctorVisit.clinic,
            doctor: doctorVisit.doctor,
            doctorScheduleInterval: doctorVisit.doctorScheduleInterval,
            insuranceId: doctorVisit.insuranceId,
            alertMessage: "Не забудьте взять паспорт",
			status: nil
        )
        futureDoctorVisits.append(doctorVisit)
        completion(.success(()))
    }

    func cancelAppointment(_ doctorVisit: DoctorVisit, completion: @escaping (Result<Bool, AlfastrahError>) -> Void) {
        if let index = futureDoctorVisits.firstIndex(where: { $0.id == doctorVisit.id }) {
            futureDoctorVisits.remove(at: index)
            completion(.success(true))
        } else {
            fatalError("Something went wrong")
        }
    }

    func updateAppointment(_ doctorVisit: DoctorVisit, completion: @escaping (Result<DoctorVisit, AlfastrahError>) -> Void) {
        if let index = futureDoctorVisits.firstIndex(where: { $0.id == doctorVisit.id }) {
            futureDoctorVisits.remove(at: index)
            createAppointment(doctorVisit) { result in
                switch result {
                    case .success:
                        completion(.success(doctorVisit))
                    case let .failure(error):
                        completion(.failure(error))
                }
            }
        } else {
            fatalError("Something went wrong")
        }
    }

    func futureAppointments(insuranceId: String, completion: @escaping (Result<[DoctorVisit], AlfastrahError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int.random(in: 1..<3))) { [weak self] in
            completion(.success(self?.futureDoctorVisits ?? []))
        }
    }

    func pastAppointments(
        insuranceId: String, offset: Int, pageSize: Int, completion: @escaping (Result<DoctorVisitsResponse, AlfastrahError>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int.random(in: 1..<3))) {
            var visits: [DoctorVisit] = []
            let total = self.pastDoctorVisits.count
            guard offset < self.pastDoctorVisits.count else {
                return completion(.success(DoctorVisitsResponse(visits: visits, total: total)))
            }

            visits = Array(self.pastDoctorVisits[offset ..< min(offset + pageSize, self.pastDoctorVisits.count)])
            completion(.success(DoctorVisitsResponse(visits: visits, total: total)))
        }
    }

    func appointment(id: String, completion: @escaping (Result<DoctorVisit, AlfastrahError>) -> Void) {
        if let doctorVisit = futureDoctorVisits.first(where: { $0.id == id }) {
            completion(.success(doctorVisit))
        }
    }

    // MARK: - Mock Data
    private let visitsInPastCount = 30
    private let visitsInFutureCount = 10
    private let avisVisitsCount = 33
    
    private let now: Date = Date()
    private let oneYearBeforeToday: Date = Calendar.current.date(
        byAdding: .year,
        value: -1,
        to: Date()
    ) ?? Date()
    
    private let oneYearAfterToday: Date = Calendar.current.date(
        byAdding: .year,
        value: 1,
        to: Date()
    ) ?? Date()
    
    private static func getRandomId() -> UInt64 {
        return UInt64.random(in: UInt64.min...UInt64.max)
    }
    
    private func nextId() -> String {
        struct Holder {
            static var id = 0
        }
        Holder.id += 1
        
        return "\(Holder.id)"
    }
    
    private func nextIdAVIS() -> Int {
        struct Holder {
            static var id = 0
        }
        Holder.id += 1
        
        return Holder.id
    }
    
    private static func getRandomDate(from: Date, to: Date) -> Date {
        return Date(timeIntervalSinceNow:
            .random(in: from.timeIntervalSinceNow...to.timeIntervalSinceNow)
        )
    }
    
    private static func getRandomOrderedDates(from: Date, to: Date, count: Int) -> [Date] {
        var dates: [Date] = []
        
        for _ in 0...count {
            dates.append(MockClinicsService.getRandomDate(from: from, to: to))
        }
        
        return dates.sorted{ $0 < $1 }
    }
    
    private let clinicInfoId = String(MockClinicsService.getRandomId())
    private let clinicAvisId = String(MockClinicsService.getRandomId())
    
    private var clinic: Clinic {
        let primaryPhone = Phone(
            plain: "89999999999",
            humanReadable: "8 (999) 999-99-99"
        )
        
        let secondaryPhone = Phone(
            plain: "89999999991",
            humanReadable: "8 (999) 999-99-91"
        )
        
        let phones = [primaryPhone, secondaryPhone]
       
        return Clinic(
            id: clinicInfoId,
            title: "Всем, здоровье",
            address: "проспект Медиков 5",
            coordinate: Coordinate(latitude: 0, longitude: 0),
            serviceHours: "пн-пт 8-20",
			labelList: [],
			metroList: [],
			serviceList: [],
			url: nil,
			phoneList: [],
			buttonText: "",
			buttonAction: .appointmentOffline,
			filterList: [],
			franchise: false
        )
    }
    
    private var clinicAVIS: Clinic {
        let primaryPhone = Phone(
            plain: "84959528833",
            humanReadable: "8 (495) 952-88-33"
        )
        
        let secondaryPhone = Phone(
            plain: "81231231212",
            humanReadable: "8 (123) 123-12-12"
        )
        
        let phones = [primaryPhone, secondaryPhone]
        
        return Clinic(
            id: clinicAvisId,
            title: "Психиатрическая Клиническая Больница № 1 им. Н.А. Алексеева",
            address: "Загородное ш., 2, Москва, 115191",
            coordinate: Coordinate(latitude: 0, longitude: 0),
            serviceHours: "пн-пт 8-20",
			labelList: [],
			metroList: [],
			serviceList: [],
			url: nil,
			phoneList: [],
			buttonText: "",
			buttonAction: .appointmentOffline,
			filterList: [],
			franchise: false
        )
    }
        
    private let doctorsInPastSpecialities = [
        DoctorSpeciality(
            id: "\(getRandomId())",
            title: "Гастроэнтеролог",
            description: "Проблемы пищеварения"
        ),
        DoctorSpeciality(
            id: "\(getRandomId())",
            title: "Дерматолог",
            description: "Кожные заболевания"
        ),
        DoctorSpeciality(
            id: "\(getRandomId()))",
            title: "Уролог",
            description: nil
        )
    ]
    
    private let doctorsInFutureSpecialities = [
        DoctorSpeciality(
            id: "\(getRandomId())",
            title: "Невропатолог",
            description: "Проблемы ЦНС"
        ),
        DoctorSpeciality(
            id: "\(getRandomId())",
            title: "Терапевт",
            description: "Общие вопросы"
        ),
        DoctorSpeciality(
            id: "\(getRandomId()))",
            title: "Хирург",
            description: nil
        )
    ]
    
    private let avisDoctorsSpecialities = [
        DoctorSpeciality(
            id: "\(getRandomId())",
            title: "Психотерапевт",
            description: nil
        ),
        DoctorSpeciality(
            id: "\(getRandomId())",
            title: "Психолог",
            description: nil
        ),
        DoctorSpeciality(
            id: "\(getRandomId()))",
            title: "Нейрохирург",
            description: nil
        )
    ]

    typealias DoctorSpecialityId = String
    
    private lazy var doctorsInPast: [DoctorSpecialityId: [FullDoctor]] = {
        var doctorsInfo: [DoctorSpecialityId: [FullDoctor]] = [:]
        for speciality in doctorsInPastSpecialities {
            doctorsInfo[speciality.id, default: []].append(mockFullDoctor(for: speciality, name: "Константинопольский Валерий Николаевич"))
            doctorsInfo[speciality.id, default: []].append(mockFullDoctor(for: speciality, name: "Арбузов Николай Викторович"))
            doctorsInfo[speciality.id, default: []].append(mockFullDoctor(for: speciality, name: "Пирогова Надежда Александровна"))
        }
        return doctorsInfo
    }()
    
    private lazy var doctorsInFuture: [DoctorSpecialityId: [FullDoctor]] = {
        var doctorsInfo: [DoctorSpecialityId: [FullDoctor]] = [:]
        for speciality in doctorsInFutureSpecialities {
            doctorsInfo[speciality.id, default: []].append(mockFullDoctor(for: speciality, name: "Козодоев Геннадий Петрович"))
            doctorsInfo[speciality.id, default: []].append(mockFullDoctor(for: speciality, name: "Горбунков Семён Семеныч"))
            doctorsInfo[speciality.id, default: []].append(mockFullDoctor(for: speciality, name: "Бунша Иван Васильевич"))
        }
        return doctorsInfo
    }()
    
    private lazy var avisDoctors: [DoctorSpecialityId: [FullDoctor]] = {
        var doctorsInfo: [DoctorSpecialityId: [FullDoctor]] = [:]
        for speciality in avisDoctorsSpecialities {
            doctorsInfo[speciality.id, default: []].append(mockFullDoctor(for: speciality, name: "Иванов Иван Иванович"))
            doctorsInfo[speciality.id, default: []].append(mockFullDoctor(for: speciality, name: "Петров Петр Петрович"))
            doctorsInfo[speciality.id, default: []].append(mockFullDoctor(for: speciality, name: "Ильин Илья Ильич"))
        }
        return doctorsInfo
    }()
    
    private lazy var defaultClinicInfoSpecilalities: OfflineAppointmentSettings = {
        return OfflineAppointmentSettings(
            clinicSpecialities: { [weak self] in
                guard let self = self
                else { return [ClinicSpeciality]() }
                
				return [ClinicSpeciality]()
            }(),
            minDateDays: 0,
            maxDateDays: 1,
            minInterval: 30,
            intervalStartTime: "08:00",
            intervalEndTime: "20:00",
            disclaimer: ""
        )
    }()
    
   private lazy var defaultClinicAvisSpecilalities: OfflineAppointmentSettings = {
       return OfflineAppointmentSettings(
           clinicSpecialities: { [weak self] in
               guard let self = self
               else { return [ClinicSpeciality]() }
               
			   return [ClinicSpeciality]()
           }(),
           minDateDays: 0,
           maxDateDays: 1,
           minInterval: 30,
           intervalStartTime: "08:00",
           intervalEndTime: "20:00",
           disclaimer: ""
       )
   }()
    
    private func doctorSchedules() -> [DoctorSchedule] {
        var doctorSchedules: [DoctorSchedule] = []
        let calendar = Calendar.current
        for index in 0 ... 13 {
            let date = calendar.date(byAdding: DateComponents(day: index), to: now) ?? Date()
            let schedule = DoctorSchedule(date: date, scheduleIntervals: scheduleIntervals(for: date))
            doctorSchedules.append(schedule)
        }
        return doctorSchedules
    }
    
    private func scheduleIntervals(for date: Date) -> [DoctorScheduleInterval] {
        var intervals: [DoctorScheduleInterval] = []
        
        for hour in 11 ... 18 {
            let start: TimeInterval = TimeInterval(hour * 60 * 60)
            let halfHour: TimeInterval = 30 * 60
            for half in 0 ... 1 {
                let from = start + TimeInterval(half) * halfHour
                let to = start + (TimeInterval(half) + 1) * halfHour
                let status = DoctorScheduleInterval.Status(rawValue: Int.random(in: 0..<2)) ?? .unavailable
                let interval = DoctorScheduleInterval(
                    id: String(MockClinicsService.getRandomId()),
                    date: date,
                    start: from,
                    end: to,
                    status: status
                )
                intervals.append(interval)
            }
        }
        return intervals
    }
    
    private func mockFullDoctor(for speciality: DoctorSpeciality, name: String) -> FullDoctor {
        let id = String(MockClinicsService.getRandomId())
        
        return FullDoctor(
            id: id,
            title: name,
            speciality: speciality,
            photoUrl: URL(string: "https://statesymbolsusa.org/sites/statesymbolsusa.org/files/primary-images/Rose-NationalflowerUSA.jpg"),
            yearsOfExperience: Int.random(in: 0...10),
            experience:
            """
            2007 год — ММА им. И.М. Сеченова, специальность — лечебное дело;
            2009 год — ФГБУ «Учебно-научный медицинский центр» Управления делами Президента РФ, ординатура, специальность — терапия;
            2014 год  — сертифицированные курсы в ФГБУ «Учебно-научный медицинский центр»
            Управления делами Президента РФ по специальности "терапия".
            Работал в ГКБ №51, ЦКБ с поликлиникой (дежурный врач-терапевт 1-го Терапевтического отделения),
            ФГБУ Поликлиника №5 УД ПРФ (участковый врач-терапевт)
            """,
            schedules: doctorSchedules()
        )
    }

    private lazy var avisAppointments: [AVISAppointment] = {
        guard !avisDoctorsSpecialities.isEmpty
        else { return [] }
        
        var appointments: [AVISAppointment] = []
        
        var orderedDates = MockClinicsService.getRandomOrderedDates(
            from: oneYearBeforeToday,
            to: oneYearAfterToday,
            count: avisVisitsCount
        )
        
        var specialityIterator = 0
        let specialitiesCount = avisDoctorsSpecialities.count
        
        for visitIndex in 0..<avisVisitsCount {
            
            guard visitIndex % specialitiesCount == 0
            else { continue }
            
            if specialityIterator >= specialitiesCount {
                specialityIterator = 0
            }
            
            let speciality = avisDoctorsSpecialities[specialityIterator]
            
            for doctor in avisDoctors[speciality.id, default: []] {
                let id = nextIdAVIS()
                
                let lastDate = orderedDates.popLast()
                
                let appointment = AVISAppointment(
                    id: id,
                    localDate: DateInRegion(lastDate ?? Date()),
                    clinicType: .avis,
                    avisClinic: clinicAVIS,
                    canBeCancelled: true,
                    canBeRecreated: true,
                    doctorFullName: doctor.title + "\n" + "AVIS: " + String(describing: id),
					referralOrDepartment: speciality.title, 
					status: nil
                )
                
                appointments.append(appointment)
            }
            
            specialityIterator += 1
        }
        
        return appointments
    }()
    
    private lazy var futureDoctorVisits: [DoctorVisit] = {
        return getDoctorsVisits(
            from: now,
            to: oneYearAfterToday,
            visitsCount: visitsInFutureCount,
            doctors: doctorsInFuture,
            specialities: doctorsInFutureSpecialities
        )
    }()
    
    private lazy var pastDoctorVisits: [DoctorVisit] = {
        return getDoctorsVisits(
            from: oneYearBeforeToday,
            to: now,
            visitsCount: visitsInPastCount,
            doctors: doctorsInPast,
            specialities: doctorsInPastSpecialities
        )
    }()
    
    private func getDoctorsVisits(
        from: Date,
        to: Date,
        visitsCount: Int,
        doctors: [DoctorSpecialityId: [FullDoctor]],
        specialities: [DoctorSpeciality]
    ) -> [DoctorVisit] {
        guard !specialities.isEmpty
        else { return [] }
                
        var orderedDates = MockClinicsService.getRandomOrderedDates(
            from: from,
            to: to,
            count: visitsCount
        )
        
        var visits: [DoctorVisit] = []
        let specialitiesCount = specialities.count
        var specialityIterator = 0
        
        for visitIndex in 0..<visitsCount {
            
            guard visitIndex % specialitiesCount == 0
            else { continue }
            
            if specialityIterator >= specialitiesCount {
                specialityIterator = 0
            }

            let speciality = specialities[specialityIterator]
            
            for doctor in doctors[speciality.id, default: []] {
                let date = orderedDates.popLast() ?? Date()
                
                let doctorSchedule = DoctorSchedule(date: date, scheduleIntervals: scheduleIntervals(for: date))
                
                let visitId = nextId()
                              
                let prefix = date > now ? "InFuture" : "InPast"
                
                let shortDoctor = ShortDoctor(
                    id: doctor.id,
                    title: doctor.title + "\n" + prefix + " " + String(describing: visitId),
                    speciality: doctor.speciality,
                    photoUrl: doctor.photoUrl,
                    yearsOfExperience: doctor.yearsOfExperience,
                    experience: doctor.experience
                )
                
                var scheduleIntervals = doctorSchedule.scheduleIntervals
                
                // "today" scheduleIntervals correction
                if Calendar.current.isDateInToday(date) {
                    if date > now {
                        scheduleIntervals = scheduleIntervals.filter{ $0.startDate > now }
                    } else {
                        scheduleIntervals = scheduleIntervals.filter{ $0.startDate < now }
                    }
                }
                
                guard let scheduleInterval = scheduleIntervals.randomElement()
                else { continue }
                
                visits.append(DoctorVisit(
                    id: visitId,
                    clinic: clinic,
                    doctor: shortDoctor,
                    doctorScheduleInterval: scheduleInterval,
                    insuranceId: "test",
                    alertMessage: nil,
					status: nil
                ))
            }
            
            specialityIterator += 1
        }
        return visits
    }
}
