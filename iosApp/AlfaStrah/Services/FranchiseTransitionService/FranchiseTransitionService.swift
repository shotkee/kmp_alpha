//
//  FranchiseTransitionService.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 08.07.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

protocol FranchiseTransitionService
{
    func franchiseTransitionData(
        insuranceId: String,
        completion: @escaping (Result<FranchiseTransitionData, AlfastrahError>) -> Void
    )

    func changeProgram(
        insuranceId: String,
        personIds: [Int],
        completion: @escaping (Result<FranchiseTransitionResult, AlfastrahError>) -> Void
    )
    
    func getUrlForChangeProgramTermsPdf(
        insuranceId: String
    ) -> URL
        
    func getUrlForInsuranceProgramPdf(
        insuranceId: String,
        personId: String
    ) -> URL
    
    func getUrlForClinicsListPdf(
        insuranceId: String,
        personId: String
    ) -> URL
}
