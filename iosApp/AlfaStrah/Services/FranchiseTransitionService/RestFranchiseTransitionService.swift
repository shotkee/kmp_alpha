//
//  RestFranchiseTransitionService.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 08.07.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import Legacy

class RestFranchiseTransitionService: FranchiseTransitionService
{
    private let rest: FullRestClient

    init(rest: FullRestClient)
    {
        self.rest = rest
    }

    func franchiseTransitionData(
        insuranceId: String,
        completion: @escaping (Result<FranchiseTransitionData, AlfastrahError>) -> Void
    )
    {
        rest.read(
            path: "api/insurances/dms/franchise/change_program_data",
            id: nil,
            parameters: [
                "insurance_id": insuranceId
            ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                transformer: FranchiseTransitionDataTransformer()
            ),
            completion: mapCompletion(completion)
        )
    }

    func changeProgram(
        insuranceId: String,
        personIds: [Int],
        completion: @escaping (Result<FranchiseTransitionResult, AlfastrahError>) -> Void
    )
    {
        rest.create(
            path: "api/insurances/dms/franchise/change_program",
            id: nil,
            object: FranchiseTransitionRequest(insuranceId: insuranceId, personIds: personIds),
            headers: [:],
            requestTransformer: FranchiseTransitionRequestTransformer(),
            responseTransformer: ResponseTransformer(
                transformer: FranchiseTransitionResultTransformer()
            ),
            completion: mapCompletion(completion)
        )
    }
    
    func getUrlForChangeProgramTermsPdf(insuranceId: String) -> URL
    {
        let url = rest.baseURL.appendingPathComponent(
            "/api/insurances/dms/franchise/change_program_terms_pdf"
        )
        return url.appendingQueryItem( itemName: "insurance_id", itemValue: insuranceId)
    }
    
    func getUrlForInsuranceProgramPdf(
        insuranceId: String,
        personId: String
    ) -> URL
    {
        let url = rest.baseURL.appendingPathComponent(
            "/api/insurances/dms/franchise/change_program_pdf"
        )
        
        return url.appendingQuery(items: [ "insurance_id": insuranceId, "person_id": personId])
    }
    
    func getUrlForClinicsListPdf(
        insuranceId: String,
        personId: String
    ) -> URL
    {
        let url = rest.baseURL.appendingPathComponent(
            "/api/insurances/dms/franchise/change_program_clinics_pdf"
        )
        
        return url.appendingQuery(items: [ "insurance_id": insuranceId, "person_id": personId])
    }
}
