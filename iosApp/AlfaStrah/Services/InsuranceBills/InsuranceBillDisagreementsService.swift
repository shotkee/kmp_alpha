//
//  InsuranceBillDisagreementsService.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 15.06.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import Legacy

protocol InsuranceBillDisagreementsService
{
    typealias DocumentId = Int
    typealias DocumentUploadResult = Result<DocumentId?, Error>
    typealias DocumentUploadId = Int
    
    func insuranceBillDisagreementServices(
        insuranceId: String,
        insuranceBillId: Int,
        completion: @escaping (Result<[InsuranceBillDisagreementService], AlfastrahError>) -> Void
    )
    
    func insuranceBillDisagreementReasons(
        insuranceId: String,
        insuranceBillId: Int,
        completion: @escaping (Result<[InsuranceBillDisagreementReason], AlfastrahError>) -> Void
    )
    
    func uploadDocument(
        insuranceId: String,
        insuranceBillId: Int,
        attachment: Attachment,
        completion: @escaping (DocumentUploadResult) -> Void
    ) -> DocumentUploadId?
    
    func cancelDocumentUpload(uploadId: DocumentUploadId)
    
    func submitDisagreement(
        insuranceId: String,
        insuranceBillId: Int,
        reasonId: Int,
        servicesIds: [Int],
        comment: String,
        phone: String?,
        email: String?,
        documentsIds: [Int],
        completion: @escaping (Result<Void, AlfastrahError>) -> Void
    )
}
