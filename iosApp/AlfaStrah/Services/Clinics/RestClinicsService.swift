//
//  RestClinicsService
//  AlfaStrah
//
//  Created by Vasyl Kotsiuba on 17.08.2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Legacy

class RestClinicsService: ClinicsService {
    private let rest: FullRestClient
    
    private var cancellable = CancellableNetworkTaskContainer()
    
    init(rest: FullRestClient) {
        self.rest = rest
    }

    // MARK: - Offline appointment
    func clinicsTreatments(completion: @escaping (Result<[ClinicTreatment], AlfastrahError>) -> Void) {
        rest.read(
            path: "/clinics/services",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "clinic_service_list",
                transformer: ArrayTransformer(
                    transformer: ClinicTreatmentTransformer()
                )
            ),
            completion: mapCompletion(completion)
        )
    }
	
	func clinics(insuranceId: String, completion: @escaping (Result<ClinicResponse, AlfastrahError>) -> Void) 
	{
		let parameters: [String: String] = [
			"insurance_id": insuranceId
		]
		
		rest.read(
			path: "/api/clinics",
			id: nil,
			parameters: parameters,
			headers: [:],
			responseTransformer: ResponseTransformer(
				transformer: ClinicResponseTransformer()
			),
			completion: mapCompletion(completion)
		)
	}

    func clinics(insuranceId: String, treatments: [ClinicTreatment], completion: @escaping (Result<[Clinic], AlfastrahError>) -> Void) {
        var parameters: [String: String] = [:]
        parameters["insurance_id"] = "\(insuranceId)"
        let treatmentsList = treatments.map { "\($0.id)" }
        if let data = try? JSONEncoder().encode(treatmentsList) {
            parameters["service_id_list"] = String(data: data, encoding: .utf8)
        }

        rest.read(
            path: "/clinics",
            id: nil,
            parameters: parameters,
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "clinic_list",
                transformer: ArrayTransformer(
                    transformer: ClinicTransformer()
                )
            ),
            completion: mapCompletion(completion)
        )
    }

    func citiesWithMetro(completion: @escaping (Result<[CityWithMetro], AlfastrahError>) -> Void) {
        rest.read(
            path: "/clinics/metro/cities",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "city_list",
                transformer: ArrayTransformer(
                    transformer: CityWithMetroTransformer()
                )
            ),
            completion: mapCompletion(completion)
        )
    }

    func metroStations(
        in city: CityWithMetro,
        insuranceId: String,
        completion: @escaping (Result<[MetroStation], AlfastrahError>) -> Void
    ) {
        var parameters: [String: String] = [:]
        parameters["citywithmetro_id"] = "\(city.id)"
        parameters["insurance_id"] = "\(insuranceId)"

        rest.read(
            path: "/clinics/metro/stations",
            id: nil,
            parameters: parameters,
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "metrostation_list",
                transformer: ArrayTransformer(
                    transformer: MetroStationTransformer()
                )
            ),
            completion: mapCompletion(completion)
        )
    }
    
    func createOfflineAppointment(
        cancelingAppointmentAvisId: Int?,
        _ newAppointment: OfflineAppointmentRequest,
        completion: @escaping (Result<Void, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "/doctor_appointments",
            id: nil,
            object: OfflineAppointmentRequestContainer(
                offlineAppointmentRequest: newAppointment,
                cancelingAppointmentAvisId: cancelingAppointmentAvisId
            ),
            headers: [:],
            requestTransformer: OfflineAppointmentRequestContainerTransformer(),
            responseTransformer: ResponseTransformer(
                key: "appointment",
                transformer: VoidTransformer()
            ),
            completion: mapCompletion(completion)
        )
    }

    func offlineAppointments(completion: @escaping (Result<[OfflineAppointment], AlfastrahError>) -> Void) {
        rest.read(
            path: "/doctor_appointments",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "appointment_list",
                transformer: ArrayTransformer(
                    transformer: OfflineAppointmentTransformer()
                )
            ),
            completion: mapCompletion(completion)
        )
    }

    func offlineAppointment(id: String, completion: @escaping (Result<OfflineAppointment, AlfastrahError>) -> Void) {
        rest.read(
            path: "/doctor_appointments/\(id)/single",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "appointment",
                transformer: OfflineAppointmentTransformer()
            ),
            completion: mapCompletion(completion)
        )
    }

    func offlineAppointmentSettings(
        for clinicId: String,
        completion: @escaping (Result<OfflineAppointmentSettings, AlfastrahError>) -> Void
    ) {
        rest.read(
            path: "/doctor_appointments/settings",
            id: nil,
            parameters: ["clinic_id": clinicId, "timezone_offset": "\(TimeZone.current.secondsFromGMT())"],
            headers: [:],
            responseTransformer: ResponseTransformer(
                transformer: OfflineAppointmentSettingsTransformer()
            ),
            completion: mapCompletion(completion)
        )
    }
    
    // MARK: - AVIS offline appointment
    func offlineAppointmentsAVIS(byInsuranceId insuranceId: String, completion: @escaping (Result<[AVISAppointment], AlfastrahError>) -> Void) {
        var parameters: [String: String] = [:]
        parameters["insurance_id"] = insuranceId

        rest.read(
            path: "/doctor_appointments_avis",
            id: nil,
            parameters: parameters,
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "appointment_list",
                transformer: ArrayTransformer(
                    transformer: AVISAppointmentTransformer()
                )
            ),
            completion: mapCompletion(completion)
        )
    }
            
    func cancelOfflineAppointmentAVIS(
        id: Int,
        insuranceId: String,
        completion: @escaping (Result<Void, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "/doctor_appointments/\(id)/cancel",
            id: nil,
            object: OfflineAppointmentCancelRequestContainer(
                avisId: id,
                insuranceId: insuranceId
            ),
            headers: [:],
            requestTransformer: OfflineAppointmentCancelRequestContainerTransformer(),
            responseTransformer: VoidTransformer(),
            completion: mapCompletion(completion)
        )
    }

    // MARK: - Online appointment

    func specialities(
        for clinicId: String,
        insuranceId: String,
        completion: @escaping (Result<[DoctorSpeciality], AlfastrahError>) -> Void
    ) {
        var parameters: [String: String] = [
            "clinic_id": clinicId,
            "insurance_id": insuranceId
        ]

        rest.read(
            path: "/doctors/specialities",
            id: nil,
            parameters: parameters,
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "speciality_list",
                transformer: ArrayTransformer(
                    transformer: DoctorSpecialityTransformer()
                )
            ),
            completion: mapCompletion(completion)
        )
    }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()

    func doctors(
        for clinicId: String,
        insuranceId: String,
        specialityId: String,
        for date: Date,
        completion: @escaping (Result<[FullDoctor], AlfastrahError>) -> Void
    ) {
        self.cancellable = CancellableNetworkTaskContainer()
        
        let parameters: [String: String] = [
            "clinic_id": clinicId,
            "speciality_id": specialityId,
            "insurance_id": insuranceId,
            "date": dateFormatter.string(from: date)
        ]

        let task = rest.read(
            path: "/doctors",
            id: nil,
            parameters: parameters,
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "doctor_list",
                transformer: ArrayTransformer(
                    transformer: FullDoctorTransformer()
                )
            ),
            completion: mapCompletion { result in
                switch result {
                    case .success(let results):
                        completion(.success(results))
                    case .failure(let error):
                        guard !error.isCanceled
                        else { return }
                        
                        completion(.failure(error))
                }
            }
        )
        
        cancellable.addCancellables([ task ])
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
        var parameters: [String: String] = [:]
        parameters["clinic_id"] = clinicId
        parameters["speciality_id"] = specialityId
        parameters["insurance_id"] = insuranceId
        parameters["start_date"] = dateFormatter.string(from: scheduleStartDate)
        parameters["end_date"] = dateFormatter.string(from: scheduleEndDate)
        
        rest.read(
            path: "/doctors/\(id)/single",
            id: nil,
            parameters: parameters,
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "doctor",
                transformer: FullDoctorTransformer()
            ),
            completion: mapCompletion(completion)
        )
    }

    func createAppointment(_ doctorVisit: DoctorVisit, completion: @escaping (Result<Void, AlfastrahError>) -> Void) {
        rest.create(
            path: "/doctors/interval/reserve",
            id: nil,
            object: ManageAppointmentRequest(
                intervalId: doctorVisit.doctorScheduleInterval.id,
                insuranceId: doctorVisit.insuranceId
            ),
            headers: [:],
            requestTransformer: ManageAppointmentRequestTransformer(),
            responseTransformer: VoidTransformer(),
            completion: mapCompletion(completion)
        )
    }

    func cancelAppointment(_ doctorVisit: DoctorVisit, completion: @escaping (Result<Bool, AlfastrahError>) -> Void) {
        rest.create(
            path: "/doctors/visits/\(doctorVisit.id)/cancel",
            id: nil,
            object: nil,
            headers: [:],
            requestTransformer: VoidTransformer(),
            responseTransformer: ResponseTransformer(
                key: "success",
                transformer: CastTransformer<Any, Bool>()
            ),
            completion: mapCompletion(completion)
        )
    }

    func updateAppointment(_ doctorVisit: DoctorVisit, completion: @escaping (Result<DoctorVisit, AlfastrahError>) -> Void) {
        rest.create(
            path: "/doctors/visits/\(doctorVisit.id)/update",
            id: nil,
            object: [ "interval_id": doctorVisit.doctorScheduleInterval.id ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: ResponseTransformer(key: "visit", transformer: DoctorVisitTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func futureAppointments(insuranceId: String, completion: @escaping (Result<[DoctorVisit], AlfastrahError>) -> Void) {
        var parameters: [String: String] = [:]
        parameters["insurance_id"] = insuranceId

        rest.read(
            path: "/doctors/visits/future",
            id: nil,
            parameters: parameters,
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "visit_list",
                transformer: ArrayTransformer(
                    transformer: DoctorVisitTransformer()
                )
            ),
            completion: mapCompletion(completion)
        )
    }

    func pastAppointments(
        insuranceId: String, offset: Int, pageSize: Int, completion: @escaping (Result<DoctorVisitsResponse, AlfastrahError>) -> Void
    ) {
        var parameters: [String: String] = [:]
        parameters["insurance_id"] = insuranceId
        parameters["offset"] = "\(offset)"
        parameters["limit"] = "\(pageSize)"

        rest.read(
            path: "/doctors/visits/past",
            id: nil,
            parameters: parameters,
            headers: [:],
            responseTransformer: ResponseTransformer(
                transformer: DoctorVisitsResponseTransformer()
            ),
            completion: mapCompletion(completion)
        )
    }

    func appointment(id: String, completion: @escaping (Result<DoctorVisit, AlfastrahError>) -> Void) {
        rest.read(
            path: "/doctors/visits/\(id)/single",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "visit",
                transformer: DoctorVisitTransformer()
            ),
            completion: mapCompletion(completion)
        )
    }
}
