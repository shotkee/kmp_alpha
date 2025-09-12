//
//  RestDmsCostRecoveryService.swift
//  AlfaStrah
//
//  Created by vit on 24.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy

class RestDmsCostRecoveryService: DmsCostRecoveryService {
    private let rest: FullRestClient
    private let authorizer: HttpRequestAuthorizer
    
    private lazy var uploadsSession = createUploadsSession()

    init(
        rest: FullRestClient,
        baseUrl: URL,
        authorizer: HttpRequestAuthorizer
    ) {
        self.rest = rest
        self.authorizer = authorizer
    }
    
    func dmsCostRecoveryData(
        insuranceId: String,
        completion: @escaping (Result<DmsCostRecoveryData, AlfastrahError>) -> Void
    ) {
        rest.read(
            path: "api/insurances/dms/compensation/form_data",
            id: nil,
            parameters: [
                "insurance_id": insuranceId
            ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "form_data",
                transformer: DmsCostRecoveryDataTransformer()
            ),
            completion: mapCompletion(completion)
        )
    }
    
    func searchBanks(
        query: String,
        completion: @escaping (Result<[DmsCostRecoveryBank], AlfastrahError>) -> Void
    ) -> NetworkTask {
        rest.read(
            path: "api/bank/search",
            id: nil,
            parameters: [
                "query": query
            ],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "bank_list",
                transformer: ArrayTransformer(transformer: DmsCostRecoveryBankTransformer())
            ),
            completion: mapCompletion(completion)
        )
    }
    
    func createApplication(
        insuranceId: String,
        applicationRequest: DmsCostRecoveryApplicationRequest,
        completion: @escaping (Result<DmsCostRecoveryApplicationResponse, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "api/insurances/dms/compensation/request_create",
            id: nil,
            object: DmsCostRecoveryApplicationRequestParameters(insuranceId: insuranceId, request: applicationRequest),
            headers: [:],
            requestTransformer: DmsCostRecoveryApplicationRequestParametersTransformer(),
            responseTransformer: ResponseTransformer(transformer: DmsCostRecoveryApplicationResponseTransformer()),
            completion: mapCompletion(completion)
        )
    }
    
    func submitApplication(
        applicationId: String,
        documentsIds: [String],
        completion: @escaping (Result<DmsCostRecoveryApplicationSubmitResponse, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "api/insurances/dms/compensation/request_submit",
            id: nil,
            object: DmsCostRecoveryApplicationSubmitRequest(
                applicationId: applicationId,
                request: documentsIds
            ),
            headers: [:],
            requestTransformer: DmsCostRecoveryApplicationSubmitRequestTransformer(),
            responseTransformer: ResponseTransformer(transformer: DmsCostRecoveryApplicationSubmitResponseTransformer()),
            completion: mapCompletion(completion)
        )
    }
    
    func uploadDocument(
        insuranceId: String,
        applicationId: String,
        uploadName: String,
        attachment: Attachment,
        completion: @escaping (DocumentUploadResult) -> Void
    ) -> DocumentUploadId? {
        let multipartResult = multipartEncode(
            fileUrl: attachment.url,
            parameters: [
                "insurance_id": insuranceId,
                "request_id": applicationId,
                "file_item_value": uploadName
            ]
        )
        
        guard let (serializedUrl, serializedContentType) = multipartResult.value,
              FileManager.default.fileExistsAtURL(serializedUrl)
        else { return nil }
        
        var request = authorizer.authorize(
            request: .init(
                url: rest.baseURL.appendingPathComponent("api/insurances/dms/compensation/file_upload")
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
        
    private func multipartEncode(
        fileUrl: URL,
        parameters: [String: String]
    ) -> Result<(url: URL, contentType: String), AttachmentTransferError>
    {
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
    
    private func createUploadsSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.httpShouldSetCookies = false
        configuration.timeoutIntervalForRequest = 300
        
        return .init(configuration: configuration)
    }
    
    func editApplication(
        applicationId: String,
        applicationRequest: DmsCostRecoveryApplicationRequest,
        completion: @escaping (Result<DmsCostRecoveryApplicationResponse, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "api/insurances/dms/compensation/request_update",
            id: nil,
            object: DmsCostRecoveryApplicationEditParameters(applicationId: applicationId, request: applicationRequest),
            headers: [:],
            requestTransformer: DmsCostRecoveryApplicationEditParametersTransformer(),
            responseTransformer: ResponseTransformer(transformer: DmsCostRecoveryApplicationResponseTransformer()),
            completion: mapCompletion(completion)
        )
    }
}
