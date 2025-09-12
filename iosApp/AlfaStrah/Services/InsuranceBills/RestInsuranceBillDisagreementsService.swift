//
//  RestInsuranceBillDisagreementsService.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 15.06.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import Legacy

class RestInsuranceBillDisagreementsService: InsuranceBillDisagreementsService {
    private let rest: FullRestClient
    private let authorizer: HttpRequestAuthorizer
    
    private lazy var uploadsSession = createUploadsSession()
    
    init(
        rest: FullRestClient,
        authorizer: HttpRequestAuthorizer
    ) {
        self.rest = rest
        self.authorizer = authorizer
    }
    
    func insuranceBillDisagreementServices(
        insuranceId: String,
        insuranceBillId: Int,
        completion: @escaping (Result<[InsuranceBillDisagreementService], AlfastrahError>) -> Void
    ) {
        rest.read(
            path: "api/insurances/dms/bills/not_agree_services",
            id: nil,
            parameters: [
                "insurance_id": insuranceId,
                "bill_id": "\(insuranceBillId)",
            ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "services",
                transformer: ArrayTransformer(transformer: InsuranceBillDisagreementServiceTransformer())
            ),
            completion: mapCompletion { result in
                completion(result)
            }
        )
    }

    func insuranceBillDisagreementReasons(
        insuranceId: String,
        insuranceBillId: Int,
        completion: @escaping (Result<[InsuranceBillDisagreementReason], AlfastrahError>) -> Void
    ) {
        rest.read(
            path: "api/insurances/dms/bills/not_agree_reasons",
            id: nil,
            parameters: [
                "insurance_id": insuranceId,
                "bill_id": "\(insuranceBillId)",
            ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "reasons",
                transformer: ArrayTransformer(transformer: InsuranceBillDisagreementReasonTransformer())
            ),
            completion: mapCompletion { result in
                completion(result)
            }
        )
    }
    
    func uploadDocument(
        insuranceId: String,
        insuranceBillId: Int,
        attachment: Attachment,
        completion: @escaping (DocumentUploadResult) -> Void
    ) -> DocumentUploadId? {
        let multipartResult = multipartEncode(
            fileUrl: attachment.url,
            parameters: [
                "insurance_id": insuranceId,
                "bill_id": "\(insuranceBillId)"
            ]
        )
        
        guard let (serializedUrl, serializedContentType) = multipartResult.value,
              FileManager.default.fileExistsAtURL(serializedUrl)
        else { return nil }
        
        var request = authorizer.authorize(
            request: .init(
                url: rest.baseURL.appendingPathComponent("api/insurances/dms/bills/not_agree_upload_file")
            )
        )
        request.httpMethod = "POST"
        request.addValue(
            serializedContentType,
            forHTTPHeaderField: "Content-Type"
        )
        
        let task = uploadsSession.uploadTask(
            with: request,
            fromFile: serializedUrl,
            completionHandler: { data, _, error in
                if let error = error {
                    if let error = error as? URLError,
                       error.code == URLError.cancelled {
                        // mute callback
                    } else {
                        completion(.failure(error))
                    }
                }
                else if let data = data,
                        let responseDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let dataDictionary = responseDictionary["data"] as? [String: Any],
                        let documentId = dataDictionary["file_id"] as? Int {
                    completion(.success(documentId))
                } else {
                    completion(.success(nil))
                }
            }
        )
        task.resume()
        
        return task.taskIdentifier
    }
    
    func cancelDocumentUpload(uploadId: DocumentUploadId) {
        uploadsSession.getAllTasks { tasks in
            let task = tasks.first { $0.taskIdentifier == uploadId }
            task?.cancel()
        }
    }
    
    private func createUploadsSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.httpShouldSetCookies = false
        configuration.timeoutIntervalForRequest = 300
        
        return .init(configuration: configuration)
    }
    
    private func multipartEncode(
        fileUrl: URL,
        parameters: [String: String]
    ) -> Result<(url: URL, contentType: String), AttachmentTransferError> {
        let filename = "\(UUID().uuidString).\(fileUrl.pathExtension)"
        let serializer = MultipartFileSerializer()
        let serializerResult = serializer.serializeToFile(
            file: .init(
                parameterName: "file",
                filename: filename,
                contentType: "application/octet-stream",
                dataFileUrl: fileUrl
            ),
            parameters: parameters
        )
        return serializerResult.map { ($0, serializer.contentType) }
    }
    
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
    ) {
        let request = InsuranceBillDisagreementRequest(
            insuranceId: insuranceId,
            insuranceBillId: insuranceBillId,
            reasonId: reasonId,
            servicesIds: servicesIds,
            comment: comment,
            phone: phone,
            email: email,
            documentsIds: documentsIds
        )
        
        rest.create(
            path: "api/insurances/dms/bills/not_agree_send",
            id: nil,
            object: request,
            headers: [:],
            requestTransformer: InsuranceBillDisagreementRequestTransformer(),
            responseTransformer: VoidTransformer(),
            completion: mapCompletion(completion)
        )
    }
}
