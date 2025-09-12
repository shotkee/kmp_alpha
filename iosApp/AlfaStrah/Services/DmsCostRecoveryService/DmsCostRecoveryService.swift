//
//  DmsCostRecoveryService.swift
//  AlfaStrah
//
//  Created by vit on 24.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//
import Legacy

protocol DmsCostRecoveryService {
    typealias DocumentId = Int
    typealias DocumentUploadResult = Result<DocumentId?, Error>
    typealias DocumentUploadId = Int
    
    func dmsCostRecoveryData(
        insuranceId: String,
        completion: @escaping (Result<DmsCostRecoveryData, AlfastrahError>) -> Void
    )
    
    func searchBanks(
        query: String,
        completion: @escaping (Result<[DmsCostRecoveryBank], AlfastrahError>) -> Void
    ) -> NetworkTask
    
    func createApplication(
        insuranceId: String,
        applicationRequest: DmsCostRecoveryApplicationRequest,
        completion: @escaping (Result<DmsCostRecoveryApplicationResponse, AlfastrahError>) -> Void
    )
    
    func uploadDocument(
        insuranceId: String,
        applicationId: String,
        uploadName: String,
        attachment: Attachment,
        completion: @escaping (DocumentUploadResult) -> Void
    ) -> DocumentUploadId?
    
    func cancelDocumentUpload(uploadId: DocumentUploadId)
    
    func submitApplication(
        applicationId: String,
        documentsIds: [String],
        completion: @escaping (Result<DmsCostRecoveryApplicationSubmitResponse, AlfastrahError>) -> Void
    )
    
    func editApplication(
        applicationId: String,
        applicationRequest: DmsCostRecoveryApplicationRequest,
        completion: @escaping (Result<DmsCostRecoveryApplicationResponse, AlfastrahError>) -> Void
    )
}
