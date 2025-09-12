//
//  ClinicsService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 09/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Legacy

protocol ClinicsService {
    // MARK: - Offline appointment

    func clinicsTreatments(completion: @escaping (Result<[ClinicTreatment], AlfastrahError>) -> Void)
    func clinics(insuranceId: String, treatments: [ClinicTreatment], completion: @escaping (Result<[Clinic], AlfastrahError>) -> Void)
	func clinics(insuranceId: String, completion: @escaping (Result<ClinicResponse, AlfastrahError>) -> Void)
    func citiesWithMetro(completion: @escaping (Result<[CityWithMetro], AlfastrahError>) -> Void)
    func metroStations(in city: CityWithMetro, insuranceId: String, completion: @escaping (Result<[MetroStation], AlfastrahError>) -> Void)
    func createOfflineAppointment(
        cancelingAppointmentAvisId: Int?,
        _ newAppointment: OfflineAppointmentRequest,
        completion: @escaping (Result<Void, AlfastrahError>) -> Void
    )
    func offlineAppointments(completion: @escaping (Result<[OfflineAppointment], AlfastrahError>) -> Void)
    func offlineAppointment(id: String, completion: @escaping (Result<OfflineAppointment, AlfastrahError>) -> Void)
    func offlineAppointmentSettings(
        for clinicId: String,
        completion: @escaping (Result<OfflineAppointmentSettings, AlfastrahError>) -> Void
    )
    
    // MARK: - AVIS offline appointment
    
    func offlineAppointmentsAVIS(
        byInsuranceId insuranceId: String,
        completion: @escaping (Result<[AVISAppointment], AlfastrahError>) -> Void
    )

    func cancelOfflineAppointmentAVIS(
        id: Int,
        insuranceId: String,
        completion: @escaping (Result<Void, AlfastrahError>) -> Void
    )

    // MARK: - Online appointment

    func specialities(for clinicId: String, insuranceId: String, completion: @escaping (Result<[DoctorSpeciality], AlfastrahError>) -> Void)
    func doctors(
        for clinicId: String,
        insuranceId: String,
        specialityId: String,
        for date: Date,
        completion: @escaping (Result<[FullDoctor], AlfastrahError>) -> Void
    )
    func doctor(
        id: String,
        clinicId: String,
        specialityId: String,
        insuranceId: String,
        scheduleStartDate: Date,
        scheduleEndDate: Date,
        completion: @escaping (Result<FullDoctor, AlfastrahError>) -> Void
    )
    func createAppointment(_ doctorVisit: DoctorVisit, completion: @escaping (Result<Void, AlfastrahError>) -> Void)
    func cancelAppointment(_ doctorVisit: DoctorVisit, completion: @escaping (Result<Bool, AlfastrahError>) -> Void)
    func updateAppointment(_ doctorVisit: DoctorVisit, completion: @escaping (Result<DoctorVisit, AlfastrahError>) -> Void)
    func futureAppointments(insuranceId: String, completion: @escaping (Result<[DoctorVisit], AlfastrahError>) -> Void)
    func pastAppointments(insuranceId: String, offset: Int, pageSize: Int,
        completion: @escaping (Result<DoctorVisitsResponse, AlfastrahError>) -> Void)
    func appointment(id: String, completion: @escaping (Result<DoctorVisit, AlfastrahError>) -> Void)
}
