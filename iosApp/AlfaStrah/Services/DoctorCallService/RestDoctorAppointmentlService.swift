//
//  RestDoctorAppointmentService.swift
//  AlfaStrah
//
//  Created by vit on 20.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy

class RestDoctorAppointmentlService: DoctorAppointmentService {
    private let rest: FullRestClient
    
    init(
        rest: FullRestClient
    ) {
        self.rest = rest
    }
    
    func createAppointment(
        doctorAppointmentRequest: DoctorAppointmentRequest,
        completion: @escaping (Result<DoctorAppointmentInfoMessage, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "api/doctor_call",
            id: nil,
            object: [
                "doctor_call": doctorAppointmentRequest
            ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: DoctorAppointmentRequestTransformer()
            ),
            responseTransformer: ResponseTransformer(
                key: "info_message",
                transformer: DoctorAppointmentInfoMessageTransformer()
            ),
            completion: mapCompletion(completion)
        )
    }
}
