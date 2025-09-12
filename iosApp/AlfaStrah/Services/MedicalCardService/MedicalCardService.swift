//
//  MedicalCardService.swift
//  AlfaStrah
//
//  Created by Makson on 02.05.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation
import Legacy

enum MedicalCardServiceError: Error {
    case unknownStatusCode
    case common(_ error: String)
    case fileSizeExceeded(_ filename: String, _ description: String)
    case storageSizeExceeded(_ description: String)
    case error(Error)

    var errorMessage: (title: String, message: String) {
        switch self {
            case .unknownStatusCode:
                return (
                    title: NSLocalizedString("medical_card_file_alert_error_title", comment: ""),
                    message: NSLocalizedString("medical_card_file_entry_common_error", comment: "")
                )
            case .fileSizeExceeded(_, let description):
                return (
                    title: NSLocalizedString("medical_card_file_alert_error_title", comment: ""),
                    message: description
                )
            case .storageSizeExceeded(let description):
                return (
                    title: NSLocalizedString("medical_card_file_alert_error_title", comment: ""),
                    message: description
                )
            case .common(let description):
                return (
                    title: NSLocalizedString("medical_card_file_alert_error_title", comment: ""),
                    message: description
                )
            case .error(let error):
                return (
                    title: NSLocalizedString("common_loading_error", comment: ""),
                    message: error.localizedDescription
                )
        }
    }
}

protocol MedicalCardService {
    typealias FileId = Int64
    typealias FileOperationId = Int
    
    typealias FileOperationResult = Result<MedicalCardFileEntry, MedicalCardServiceError>
    
    func hasMedicalCardToken() -> Bool
    func haveUploadingFiles() -> Bool
    func imagePreviewUrl(for fileEntry: MedicalCardFileEntry) -> URL?
    func isUrlPreviewImage(url: URL) -> Bool
    func getMedicalCardToken(completion: @escaping (Result<Void, AlfastrahError>) -> Void)
    func getMedicalCardFiles(useCache: Bool, completion: @escaping (Result<[MedicalCardFile], AlfastrahError>) -> Void)
    func getActualFiles(searchString: String) -> [MedicalCardFileEntriesGroup]
    func fileEntries(completion: @escaping (Result<Void, AlfastrahError>) -> Void)
    func addUpload(from attachment: Attachment)
    func startUpload(completion: @escaping (Result<Attachment, MedicalCardServiceError>) -> Void)
    func cancelUpload(for attachment: Attachment)
    func subscribeForFileEntriesUpdates(listener: @escaping ([MedicalCardFileEntriesGroup]) -> Void) -> Subscription
    func size(of localFile: String) -> Int
    func localStorageUrl(for filename: String) -> URL?
    func searchFiles(searchString: String) -> [MedicalCardFileEntriesGroup]
    func renameFile(fileEntry: MedicalCardFileEntry, completion: @escaping (Result<Void, MedicalCardServiceError>) -> Void)
    func getEndpoint(completion: @escaping () -> Void)
    func downloadFile(
        for fileEntry: MedicalCardFileEntry,
        completion: @escaping (FileOperationResult) -> Void
    )
    func removeFile(
        searchString: String,
        fileId: Int64,
        completion: @escaping (Result<Void, AlfastrahError>) -> Void
    )
    func removeCachedFile(
        fileName: String
    ) -> Bool
    func retryUploadFile(
        for fileEntry: MedicalCardFileEntry,
        completion: @escaping (FileOperationResult) -> Void
    )
    func cancelUpload(for fileEntry: MedicalCardFileEntry)
	
	func isImage(_ fileEntry: MedicalCardFileEntry) -> Bool
}
