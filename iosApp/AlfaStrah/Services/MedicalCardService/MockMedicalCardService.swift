//
//  MockMedicalCardService.swift
//  AlfaStrah
//
//  Created by Makson on 12.05.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation
import Legacy
import SwiftDate
import SDWebImage

// swiftlint:disable file_length
class MockMedicalCardService: MedicalCardService, Updatable {
    private var medicalCardToken: MedicalCardToken?
    private let store: Store
    private let sessionRequestAuthorizer: HttpRequestAuthorizer
    private let filesServerBaseUrl: URL?
    
    private let filesLocalStorageDirectory = Storage.documentsDirectory.appendingPathComponent(
        Constants.filesLocalStorageDirectoryName,
        isDirectory: true
    )
   
    private func localFileStore(_ file: String) -> SimpleAttachmentStore {
        SimpleAttachmentStore(directory: filesLocalStorageDirectory, name: file)
    }

    private struct FileUpload {
        let attachmentUploadSource: Attachment?
        let fileEntryToUpload: MedicalCardFileEntry?
        var taskId: FileOperationId?
    }
        
    private typealias UploadId = String
    private var uploadsQueue: [UploadId: FileUpload] = [:]
    
    private struct FileDownload {
        let fileEntry: MedicalCardFileEntry
        var taskId: FileOperationId?
    }
    
    private typealias DownloadId = String
    private var downloadsQueue: [DownloadId: FileDownload] = [:]
        
    private lazy var uploadsSession = createUploadsSession()
    
    private var isAuthorizationTokenRequestInProgress = false
    
    init(
        authorizer: HttpRequestAuthorizer,
        store: Store,
        filesServerBaseUrl: URL?
    ) {
        self.sessionRequestAuthorizer = authorizer
        self.store = store
        self.filesServerBaseUrl = filesServerBaseUrl
        
        guard let fileEntries = cachedFileEntries()
        else { return }

        self.fileEntries = fileEntries.map {
            var fileEntry = $0
            if fileEntry.status == .uploading {
                fileEntry.status = .error
            }
            return fileEntry
        }
    }

    func hasMedicalCardToken() -> Bool {
        if let medicalCardToken = medicalCardToken,
           medicalCardToken.expirationDate > Date() {
            return true
        }
        else {
            return false
        }
    }
    
    func haveUploadingFiles() -> Bool {
        fileEntries.contains(
            where: { $0.status == .uploading }
        )
    }
    
    private func authorize(request: URLRequest) -> URLRequest {
        var request = request
        
        medicalCardToken.map { request.setValue("Bearer \($0)", forHTTPHeaderField: "Authorization") }
        return request
    }
    
    private func authorize(request: URLRequest, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = request
        
        func handleValidToken() {
            medicalCardToken.map { request.setValue("\($0)", forHTTPHeaderField: "Authorization") }
            completion(.success(request))
        }
        
        if hasMedicalCardToken() {
            handleValidToken()
        } else {
            getMedicalCardToken { result in
                switch result {
                    case .success:
                        handleValidToken()
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        }
    }
    
    private func updateMedicalCardTokenIfExpired(completion: @escaping (Result<Void, Error>) -> Void) {
        if hasMedicalCardToken() {
            completion(.success(()))
        } else {
            getMedicalCardToken { result in
                switch result {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        }
    }
    
    typealias ResultCallback = (Result<Void, AlfastrahError>) -> Void
    private var getMedicalCardTokenCompletions: [ResultCallback] = []
    
    func getMedicalCardToken(completion: @escaping (Result<Void, AlfastrahError>) -> Void) {
        guard !isAuthorizationTokenRequestInProgress
        else {
            getMedicalCardTokenCompletions.append(completion)
            return
        }
        
        isAuthorizationTokenRequestInProgress = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int.random(in: 1..<3))) {
            self.isAuthorizationTokenRequestInProgress = false
            self.medicalCardToken = self.token
            
            completion(.success(()))
            
            guard !self.getMedicalCardTokenCompletions.isEmpty
            else { return }
            
            self.getMedicalCardTokenCompletions.forEach { $0(.success(())) }
            
            self.getMedicalCardTokenCompletions = []
        }
    }
    
    private var filesCached = false // mock field
    
    func getMedicalCardFiles(useCache: Bool, completion: @escaping (Result<[MedicalCardFile], AlfastrahError>) -> Void) {
        if useCache, let files = cachedFiles() {
            completion(.success(files))
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int.random(in: 1..<3))) {
                if self.filesCached {
                    completion(.failure(.api(.init(httpCode: 999, internalCode: 0, title: "", message: "response error"))))
                    
                    self.filesCached = false
                    return
                }
                
                try? self.store.write { transaction in
                    try transaction.delete(type: MedicalCardFile.self)
                    try transaction.insert(self.files)
                }
                
                completion(.success(self.files))
                
                self.filesCached = true
            }
        }
    }
   
    func getEndpoint(completion: @escaping () -> Void){}
    
    func renameFile(
        fileEntry: MedicalCardFileEntry,
        completion: @escaping (Result<Void, MedicalCardServiceError>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int.random(in: 1..<3))) {
            let mockBool = Bool.random()
            if mockBool {
                self.updateFileEntry(fileEntry: fileEntry)
                completion(.success(()))
                self.filesCached = true
            }
            else {
                self.fileEntriesSubscriptions.fire(
                    self.convertMedicalCardFileEntriesToFileEntriesGroup(self.fileEntries)
                ) // need for reload notify in ViewController
                completion(.failure(.common(NSLocalizedString("medical_card_file_entry_common_error", comment: ""))))
                self.filesCached = false
            }
        }
    }
    
    func removeFile(
        searchString: String,
        fileId: Int64,
        completion: @escaping (Result<Void, AlfastrahError>) -> Void
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int.random(in: 1..<3))) {
            let mockBool = Bool.random()
            if mockBool {
                self.fileEntries = self.fileEntries.filter { $0.fileId != fileId }
                completion(
                    .success(())
                )
            }
            else {
                completion(.failure(.unknownError))
            }
        }
    }
    
    func getActualFiles(searchString: String) -> [MedicalCardFileEntriesGroup] {
        searchFiles(searchString: searchString.lowercased())
    }
    
    @discardableResult
    func removeCachedFile(
        fileName: String
    ) -> Bool {
        if let index = fileEntries.firstIndex(
            where: { $0.localStorageFilename == fileName }
        ) {
            fileEntries.remove(at: index)
            localFileStore(fileName).remove()
            return true
        } else if let index = fileEntries.firstIndex(
            where: { $0.originalFilename == fileName }
        ) {
            fileEntries.remove(at: index)
            localFileStore(fileName).remove()
            return true
        } else {
            return false
        }
    }
    
    private func updateFileEntry(
        fileEntry: MedicalCardFileEntry
    ) {
        guard let index = fileEntries.firstIndex(where: { $0.id == fileEntry.id })
        else { return }
        
        fileEntries[index].originalFilename = fileEntry.originalFilename
    }
    
    func imagePreviewUrl(fileId: MedicalCardService.FileId) -> URL? {
        URL(string: "https://i.ytimg.com/vi/q0XBHwIt3E4/maxresdefault.jpg") // test url
    }
                
    func isUrlPreviewImage(url: URL) -> Bool {
        true
    }
        
    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int.random(in: 1..<3))) {
            completion(.failure(.notImplemented))
        }
    }
    
    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int.random(in: 1..<3))) {
            completion(.failure(.notImplemented))
        }
    }
    
    func erase(logout: Bool) {
        if logout {
            medicalCardToken = nil
        }
        
        cancelAllOperations()
        
        try? store.write { transaction in
            try transaction.delete(type: MedicalCardFile.self)
            try transaction.delete(type: MedicalCardFileEntry.self)
        }
        try? FileManager.default.removeItem(at: filesLocalStorageDirectory)
    }
    
    private let token = MedicalCardToken(
        token: "asdadspadakdfksjdnejinfekjnejreiergjn",
        expirationDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
    )
    
    private let files: [MedicalCardFile] = [
        .init(
            id: 1,
            creationDate: "2023-06-01 16:12:00".toDate()?.date ?? Date(),
            name: "File0001",
            status: .commonError,
            sizeInBytes: 50000000,
            fileExtension: "PDF"
        ),
        .init(
            id: 2,
            creationDate: "2023-05-20 15:33:00".toDate()?.date ?? Date(),
            name: "FileWithVeryLongNameeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
            status: .typeNotSupported,
            sizeInBytes: 5000,
            fileExtension: "NotSupportedType"
        ),
        .init(
            id: 3,
            creationDate: "2019-05-20 15:30:00".toDate()?.date ?? Date(),
            name: "FileWithVeryLoooongNameeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
            status: .success,
            sizeInBytes: 5000,
            fileExtension: "JPEG"
        ),
        .init(
            id: 4,
            creationDate: "2023-04-20 15:30:00".toDate()?.date ?? Date(),
            name: "File0001",
            status: .success,
            sizeInBytes: 50000000,
            fileExtension: "PNG"
        ),
        .init(
            id: 5,
            creationDate: "2023-05-20 15:31:00".toDate()?.date ?? Date(),
            name: "File0001",
            status: .success,
            sizeInBytes: 50000000,
            fileExtension: "PNG"
        ),
        .init(
            id: 6,
            creationDate: "2023-05-20 15:30:00".toDate()?.date ?? Date(),
            name: "File0001",
            status: .success,
            sizeInBytes: 1500000000,
            fileExtension: "DOCX"
        ),
        .init(
            id: 7,
            creationDate: "2010-05-20 15:30:00".toDate()?.date ?? Date(),
            name: "File0001",
            status: .success,
            sizeInBytes: 50000000,
            fileExtension: "PDF"
        )
    ]
    
    func searchFiles(searchString: String) -> [MedicalCardFileEntriesGroup] {
        if searchString.isEmpty {
            return self.convertMedicalCardFileEntriesToFileEntriesGroup(fileEntries)
        }
        else {
            var files: [MedicalCardFileEntry] = []
            fileEntries.forEach { fileEntry in
                if fileEntry.originalFilename.lowercased().contains(searchString) {
                    files.append(fileEntry)
                }
            }
            
            return files.isEmpty
                ? []
                : [
                    .init(
                        kind: .search,
                        fileEntries: files
                    )
                ]
        }
    }
    
    private var fileEntries: [MedicalCardFileEntry] = [] {
        didSet {
            self.fileEntriesSubscriptions.fire(self.convertMedicalCardFileEntriesToFileEntriesGroup(self.fileEntries))
            
            try? self.store.write { transaction in
                try transaction.delete(type: MedicalCardFileEntry.self)
                try transaction.upsert(fileEntries)
            }
        }
    }
    
    private var fileEntriesSubscriptions: Subscriptions<[MedicalCardFileEntriesGroup]> = Subscriptions()
    
    func subscribeForFileEntriesUpdates(listener: @escaping ([MedicalCardFileEntriesGroup]) -> Void) -> Subscription {
        fileEntriesSubscriptions.add(listener)
    }
    
    private func cachedFiles() -> [MedicalCardFile]? {
        var files: [MedicalCardFile] = []
        try? store.read { transaction in
            files = try transaction.select()
        }
        return files
    }
     
    private func cachedFileEntries() -> [MedicalCardFileEntry]? {
        var fileEntries: [MedicalCardFileEntry] = []
        try? store.read { transaction in
            fileEntries = try transaction.select()
        }
        return fileEntries
    }
    
    private func convertMedicalCardFileEntriesToFileEntriesGroup(
        _ fileEntries: [MedicalCardFileEntry]
    ) -> [MedicalCardFileEntriesGroup] {
        var fileEntriesGroups: [MedicalCardFileEntriesGroup] = []
        let processingFileEntries = fileEntries
            .filter { ![.localAndRemote, .remote, .downloading].contains($0.status) }
            .sorted(by: { $0.creationDate > $1.creationDate })
        
        if !processingFileEntries.isEmpty {
            fileEntriesGroups.append(
                MedicalCardFileEntriesGroup(
                    kind: .processing,
                    fileEntries: processingFileEntries
                )
            )
        }
        
        let successfulUploads = fileEntries.filter { [.remote, .localAndRemote, .downloading].contains($0.status) }
        fileEntriesGroups += fileEntriesGroupedByMonthAndYear(successfulUploads)
        
        func fileEntriesGroupedByMonthAndYear(
            _ fileEntries: [MedicalCardFileEntry]
        ) -> [MedicalCardFileEntriesGroup] {
            var fileEntriesGrouped: [MedicalCardFileEntriesGroup] = []
            
            for fileEntry in fileEntries {
                let monthAndYear = Calendar.current.dateComponents(
                    [.year, .month],
                    from: fileEntry.creationDate
                )
                
                let date = Calendar.current.date(from: monthAndYear) ?? Date()
                
                let fileEntryIndex = fileEntriesGrouped.firstIndex(where: {
                    switch $0.kind {
                        case .processing, .search:
                            return false
                        case .successful(let date):
                            let successfulFileDate = Calendar.current.dateComponents(
                                [.year, .month],
                                from: date
                            )
                            return successfulFileDate == monthAndYear
                    }
                })
                
                if let index = fileEntryIndex {
                    fileEntriesGrouped[index].fileEntries.append(fileEntry)
                } else {
                    fileEntriesGrouped.append(
                        MedicalCardFileEntriesGroup(
                            kind: .successful(date),
                            fileEntries: [fileEntry]
                        )
                    )
                }
            }
            
            for index in 0 ..< fileEntriesGrouped.count {
                fileEntriesGrouped[index].fileEntries.sort(by: {
                    $0.creationDate > $1.creationDate
                })
            }
            
            return fileEntriesGrouped.sorted(by: {
                if let firstDate = $0.fileEntries.first?.creationDate,
                   let secondDate = $1.fileEntries.first?.creationDate {
                    return firstDate > secondDate
                } else { return false }
            })
        }
        
        return fileEntriesGroups
    }
    
    private func deleteAbandonedLocalFiles() {
        guard let localUrls = SimpleAttachmentStore.list(directoryUrl: filesLocalStorageDirectory)
        else { return }
        
        for url in localUrls {
            let filename = url.lastPathComponent
            
            if !fileEntries.contains(where: { $0.localStorageFilename == filename }) {
                localFileStore(filename).remove()
            }
        }
    }
    
    private func createUploadsSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.httpShouldSetCookies = false
        configuration.timeoutIntervalForRequest = 300
        
        return .init(configuration: configuration)
    }
    
    func retryUploadFile(
        for fileEntry: MedicalCardFileEntry,
        completion: @escaping (FileOperationResult) -> Void
    ) {
        guard let localFilename = fileEntry.localStorageFilename,
              let url = localStorageUrl(for: localFilename),
              let index = fileEntries.firstIndex(where: { $0.id == fileEntry.id })
        else { return }
        
        fileEntries[index].status = .uploading
        
        let fileEntryId = fileEntry.id
        
        // start upload
        let taskId = uploadFile(
            fileEntry: fileEntry,
            sourceFileUrl: url
        ) { result in
            self.handleFileUpload(
                result,
                for: fileEntry,
                completion: completion
            )
        }

        if let taskId = taskId {
            uploadsQueue[fileEntryId]?.taskId = taskId
        } else {
            uploadsQueue.removeValue(forKey: fileEntryId)
        }
    }
        
    private func uploadFile(
        fileEntry: MedicalCardFileEntry,
        sourceFileUrl: URL,
        completion: @escaping (FileOperationResult) -> Void
    ) -> FileOperationId? {
        guard let filesServerBaseUrl = filesServerBaseUrl,
              let filenameWithExtension = fileEntry.localStorageFilename
        else { return nil }
        
        do {
            let fileData = try Data(contentsOf: sourceFileUrl)
            let fileBase64EncodedString = fileData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            let body: [String: Any] = [
                "name": filenameWithExtension,
                "type": 1,
                "guid": UUID().uuidString.components(separatedBy: CharacterSet.alphanumerics.inverted).joined(),
                "privacyType": 1,
                "contentType": 3,
                "content": fileBase64EncodedString
            ]
            
            let result = medicalCardFileEncode(fileUrl: sourceFileUrl, payload: body)
            
            guard let (serializedUrl, serializedContentType) = result.value,
                  FileManager.default.fileExistsAtURL(serializedUrl)
            else { return nil }
            
            var request = sessionRequestAuthorizer.authorize(
                request: .init(
                    url: filesServerBaseUrl.appendingPathComponent("resource-cloud/mobile-app")
                )
            )
            
            request.httpMethod = "POST"
            request.addValue(
                serializedContentType,
                forHTTPHeaderField: "Content-Type"
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int.random(in: 1..<5))) {
                var modifiedFileEntry = fileEntry
                modifiedFileEntry.fileId = Int64.random(in: 0...Int64.max)
                modifiedFileEntry.status = .virusCheck
                
                completion(.success(modifiedFileEntry))
                
                // remove temporary json file after operation
                try? FileManager.default.removeItem(at: serializedUrl)
            }
            return Int.random(in: 0...Int.max)
            
            // RestMedicalCardService implementation
            return createUploadTask(
                request: request,
                serializedUrl: serializedUrl,
                fileEntry: fileEntry
            ) { result in
                completion(result)
                try? FileManager.default.removeItem(at: serializedUrl)
            }
        } catch {
            completion(.failure(.error(error)))
        }
        
        return nil
    }
    
    private func createUploadTask(
        request: URLRequest,
        serializedUrl: URL,
        fileEntry: MedicalCardFileEntry,
        completion: @escaping (FileOperationResult) -> Void
    ) -> FileOperationId {
        let authorizedRequest = authorize(request: request)
        
        let task = uploadsSession.uploadTask(
            with: request,
            fromFile: serializedUrl,
            completionHandler: { data, response, error in
                if let response = response as? HTTPURLResponse,
                   response.statusCode == ApiErrorKind.invalidAccessToken.rawValue {
                    self.getMedicalCardToken { result in
                        switch result {
                            case .success:
                                let taskId = self.createUploadTask(
                                    request: request,
                                    serializedUrl: serializedUrl,
                                    fileEntry: fileEntry
                                ) { result in
                                    completion(result)
                                }
                                
                                let fileEntryId = fileEntry.id
                                
                                if var queueEntry = self.uploadsQueue[fileEntryId] {
                                    queueEntry.taskId = taskId
                                    
                                    self.uploadsQueue[fileEntryId] = queueEntry
                                }
                            case .failure(let error):
                                completion(.failure(.error(error)))
                        }
                    }
                } else {
                    if let error = error {
                        if let error = error as? URLError,
                           error.code == URLError.cancelled {
                            // mute callback
                        } else {
                            completion(.failure(.error(error)))
                        }
                    } else if let data = data,
                              let responseDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                              let dataDictionary = responseDictionary["data"] as? [String: Any],
                              let status = dataDictionary["status"] as? Int,
                              let statusText = dataDictionary["statusText"] as? String {
                        switch status {
                            case 0:
                                let medicalCardFileId = dataDictionary["resourceEntityId"] as? Int64
                                var modifiedMedicalCard = fileEntry
                                modifiedMedicalCard.fileId = medicalCardFileId
                                modifiedMedicalCard.status = .virusCheck
                                
                                completion(.success(modifiedMedicalCard))
                            case -220:
                                completion(.failure(.common(statusText)))
                            case -221:
                                completion(.failure(.fileSizeExceeded(fileEntry.originalFilename, statusText)))
                            default:
                                completion(.failure(.unknownStatusCode))
                        }
                    } else {
                        completion(.failure(.common(NSLocalizedString("medical_card_file_entry_common_error", comment: ""))))
                    }
                    
                    try? FileManager.default.removeItem(at: serializedUrl)
                }
            }
        )
        task.resume()
        
        return task.taskIdentifier
    }
    
    func startUpload(completion: @escaping (Result<Attachment, MedicalCardServiceError>) -> Void) {
        updateMedicalCardTokenIfExpired { result in
            switch result {
                case .success:
                    for (key, value) in self.uploadsQueue {
                        guard let attachment = value.attachmentUploadSource,
                              let fileEntryToUpload = value.fileEntryToUpload
                        else { continue }

                        // start upload
                        let taskId = self.uploadFile(
                            fileEntry: fileEntryToUpload,
                            sourceFileUrl: attachment.url
                        ) { result in
                            // after trying to upload a file, we remove the entry from the queue
                            // and pass the file/error to the file array
                            self.handleFileUpload(
                                result,
                                for: fileEntryToUpload,
                                completion: { _ in
                                    completion(.success(attachment))
                                }
                            )
                        }

                        if let taskId = taskId {
                            self.uploadsQueue[key]?.taskId = taskId
                        } else {
                            self.uploadsQueue.removeValue(forKey: key)
                        }
                    }
                case .failure(let error):
                    completion(.failure(.error(error)))
            }
        }
    }
    
    private func handleFileUpload(
        _ result: FileOperationResult,
        for fileEntryToUpload: MedicalCardFileEntry,
        completion: @escaping (FileOperationResult) -> Void
    ) {
        guard let index = fileEntries.firstIndex(where: { $0.id == fileEntryToUpload.id })
        else { return }
        
        DispatchQueue.main.async {
            switch result {
                case .success(let modifiedFileEntry):
                    self.fileEntries[index] = modifiedFileEntry
                    completion(.success(modifiedFileEntry))
                case .failure(let error):
                    self.fileEntries[index].status = .error
                    completion(.failure(error))
            }
        }
        self.uploadsQueue.removeValue(forKey: fileEntryToUpload.id)
    }
    
    func addUpload(from attachment: Attachment) {
        var filenameWithExtension = attachment.originalName ?? attachment.filename
        var filename = filenameWithExtension.deletingPathExtension()
        let fileExtension = filenameWithExtension.pathExtension()
        
        // if filename with this name or with name plus index (1), (2), etc already exist
        let fileEntriesWithSameNames = self.fileEntries.filter {
            $0.originalFilename.range(
                of: "\(filename)\\(\\d+\\)",
                options: .regularExpression,
                range: nil,
                locale: nil
            ) != nil
        }.sorted(by: { $0.originalFilename < $1.originalFilename })
        
        if !fileEntriesWithSameNames.isEmpty {
            if let defaultFilename = fileEntriesWithSameNames.last?.originalFilename,
               let numberStringInFilenameRange = defaultFilename.range(of: "\\(\\d+\\)", options: .regularExpression),
               let numberInFilename = Int(defaultFilename[numberStringInFilenameRange].trimmingCharacters(in: ["(", ")"])) {
                filename = "\(filename)(\(numberInFilename + 1))"
            }
        } else if self.fileEntries.contains(where: { $0.originalFilename == filename }) {
            filename += "(1)"
        }
        
        filenameWithExtension = fileExtension.isEmpty
            ? filename
            : filename + "." + fileExtension
        
        // save to local storage
		self.localFileStore(filenameWithExtension).copy(from: attachment.url) { _ in }
        // save files to cache without fileId
        let fileEntryToUpload = MedicalCardFileEntry(
            id: UUID().uuidString,
            status: .uploading,
            localStorageFilename: filenameWithExtension,
            originalFilename: filename,
            creationDate: Date(),
            sizeInBytes: self.size(of: filenameWithExtension),
            fileExtension: fileExtension.uppercased()
        )

        self.fileEntries.append(fileEntryToUpload)
        
        uploadsQueue[fileEntryToUpload.id] = .init(attachmentUploadSource: attachment, fileEntryToUpload: fileEntryToUpload)
    }
    
    func cancelUpload(for fileEntry: MedicalCardFileEntry) {
        guard let activeUpload = uploadsQueue.values.first(where: { $0.fileEntryToUpload?.id == fileEntry.id }),
              let taskId = activeUpload.taskId
        else { return }
            
        cancelTask(by: taskId) {
            self.uploadsQueue.removeValue(forKey: fileEntry.id)
        }
    }
    
    func cancelUpload(for attachment: Attachment) {
        guard let activeUpload = uploadsQueue.first(where: { $0.key == attachment.id }),
              let taskId = activeUpload.value.taskId
        else { return }
        
        cancelTask(by: taskId) {
            self.uploadsQueue.removeValue(forKey: activeUpload.key)
        }
    }
    
    func cancelDownload(for fileEntry: MedicalCardFileEntry) {
        guard let activeDownload = downloadsQueue.first(where: { $0.key == fileEntry.id }),
              let taskId = activeDownload.value.taskId
        else { return }
        
        cancelTask(by: taskId) {
            self.downloadsQueue.removeValue(forKey: activeDownload.key)
        }
    }
    
    private func cancelTask(by id: Int, completion: @escaping () -> Void) {
        uploadsSession.getAllTasks { tasks in
            let task = tasks.first { $0.taskIdentifier == id }
            task?.cancel()
            completion()
        }
    }
    
    private func cancelAllOperations() {
        for download in downloadsQueue {
            guard let taskId = download.value.taskId
            else { continue }
            
            cancelTask(by: taskId) {
                self.downloadsQueue.removeValue(forKey: download.key)
            }
        }
        
        for upload in uploadsQueue {
            guard let taskId = upload.value.taskId
            else { continue }
            
            cancelTask(by: taskId) {
                self.uploadsQueue.removeValue(forKey: upload.key)
            }
        }
    }
    
    private func medicalCardFileEncode(
        fileUrl: URL,
        payload: [String: Any]
    ) -> Result<(url: URL, contentType: String), AttachmentTransferError> {
        let serializer = MedicalCardFileSerializer()
        let fileName = UUID().uuidString
        let contentType = "application/json"
        
        let serializerResult = serializer.serializeToFile(
            file: TransferredAttachment(
                parameterName: "file",
                filename: fileName,
                contentType: contentType,
                dataFileUrl: fileUrl
            ),
            payload: payload
        )
        return serializerResult.map { ($0, contentType) }
    }
    
    func fileEntries(completion: @escaping (Result<Void, AlfastrahError>) -> Void) {
        self.getMedicalCardFiles(
            useCache: false,
            completion: { [weak self] result in
                switch result {
                    case .success(let files):
                        self?.updateFileEntries(with: files)
                        
                        // check unused local storage files and remove them
                        self?.deleteAbandonedLocalFiles()
                    case .failure:
                        // try to get cached files
                        self?.getMedicalCardFiles(
                            useCache: true,
                            completion: { [weak self] result in
                                switch result {
                                    case .success(let files):
                                        self?.updateFileEntries(with: files)
                                    case .failure(let error):
                                        completion(.failure(error))
                                }
                            }
                        )
                }
            }
        )
    }
    
    private func addDownload(for fileEntry: MedicalCardFileEntry) {
        downloadsQueue[fileEntry.id] = .init(fileEntry: fileEntry)
    }
    
    func downloadFile(
        for fileEntry: MedicalCardFileEntry,
        completion: @escaping (Result<MedicalCardFileEntry, MedicalCardServiceError>) -> Void
    ) {
        guard let index = fileEntries.firstIndex(where: { $0.id == fileEntry.id })
        else { return }
        
        fileEntries[index].status = .downloading
        
        updateMedicalCardTokenIfExpired { result in
            switch result {
                case .success:
                    guard let filesServerBaseUrl = self.filesServerBaseUrl,
                          let fileId = fileEntry.fileId
                    else { return }
                    
                    let fileEntryId = fileEntry.id
                    
                    self.addDownload(for: fileEntry)
                    
                    var request = self.sessionRequestAuthorizer.authorize(
                        request: .init(
                            url: filesServerBaseUrl.appendingPathComponent("/resource-cloud/content/\(fileId)/mobile-app")
                        )
                    )
                    
                    request.httpMethod = "GET"
                    
                    let taskId = self.createDownloadTask(
                        request: request,
                        fileEntry: fileEntry
                    ) { result in
                        self.handleFileDownload(
                            result,
                            for: fileEntry,
                            completion: completion
                        )
                    }
                    
                    if var queueEntry = self.downloadsQueue[fileEntryId] {
                        queueEntry.taskId = taskId
                        
                        self.downloadsQueue[fileEntryId] = queueEntry
                    }
                case .failure(let error):
                    completion(.failure(.error(error)))
            }
        }
    }
        
    private func createDownloadTask(
        request: URLRequest,
        fileEntry: MedicalCardFileEntry,
        completion: @escaping (FileOperationResult) -> Void
    ) -> FileOperationId {
        let authorizedRequest = authorize(request: request)
        
        let task = URLSession.shared.downloadTask(
            with: request,
            completionHandler: { fileUrl, response, error in
                if let error = error {
                    if let error = error as? URLError,
                       error.code == URLError.cancelled {
                        // mute callback
                    } else {
                        completion(.failure(.error(error)))
                    }
                } else {
                    if let response = response as? HTTPURLResponse {
                        switch response.statusCode {
                            case ApiErrorKind.invalidAccessToken.rawValue:
                                self.getMedicalCardToken { [weak self] result in
                                    switch result {
                                        case .success:
                                            let taskId = self?.createDownloadTask(
                                                request: authorizedRequest,
                                                fileEntry: fileEntry
                                            ) { result in
                                                completion(result)
                                            }
                                            
                                            let fileEntryId = fileEntry.id
                                            
                                            if var queueEntry = self?.downloadsQueue[fileEntryId] {
                                                queueEntry.taskId = taskId
                                                
                                                self?.downloadsQueue[fileEntryId] = queueEntry
                                            }
                                        case .failure(let error):
                                            completion(.failure(.error(error)))
                                    }
                                }
                            case 200:
                                guard let fileUrl = fileUrl
                                else { return }
                                
                                let modifiedFileEntry = self.saveDownloadedFile(from: fileUrl, for: fileEntry)
                                
                                completion(.success(modifiedFileEntry))
                            default:
                                completion(.failure(.unknownStatusCode))
                        }
                    }
                }
            }
        )
        task.resume()
        return task.taskIdentifier
    }
    
    private func saveDownloadedFile(
        from url: URL,
        for fileEntry: MedicalCardFileEntry
    ) -> MedicalCardFileEntry {
        var modifiedFileEntry = fileEntry
        let filenameWithExtension: String
        
        if let fileExtension = fileEntry.fileExtension?.lowercased() {
            filenameWithExtension = fileEntry.originalFilename + "." + fileExtension
        } else {
            filenameWithExtension = fileEntry.originalFilename
        }
    
		self.localFileStore(filenameWithExtension).copy(from: url) { _ in }
    
        modifiedFileEntry.localStorageFilename = filenameWithExtension
        modifiedFileEntry.status = .localAndRemote
        
        return modifiedFileEntry
    }
    
    private func handleFileDownload(
        _ result: FileOperationResult,
        for fileEntry: MedicalCardFileEntry,
        completion: @escaping (FileOperationResult) -> Void
    ){
        guard let index = fileEntries.firstIndex(where: { $0.id == fileEntry.id })
        else { return }
        
        DispatchQueue.main.async {
            switch result {
                case .success(let modifiedFileEntry):
                    self.fileEntries[index] = modifiedFileEntry
                    completion(.success(modifiedFileEntry))
                case .failure(let error):
                    self.fileEntries[index].status = .remote
                    completion(.failure(error))
            }
        }
        
        downloadsQueue.removeValue(forKey: fileEntry.id)
    }
    
    private func updateFileEntries(with files: [MedicalCardFile]) {
        guard !files.isEmpty
        else { return }
        
        var newFileEntries: [MedicalCardFileEntry] = []
                
        for file in files {
            if let index = fileEntries.firstIndex(where: { file.id == $0.fileId }) {
                // modify local entry with data from server
                var modifiedFileEntry = fileEntries[index]
                let fileEntryCurrentStatus = modifiedFileEntry.status
                
                switch file.status {
                    case .success:
                        switch fileEntryCurrentStatus {
							case .localAndRemote, .remote, .downloading, .retry:
                                break
                            case .error:
                                // clear local storage and cache from local copy of file entry
                                modifiedFileEntry.status = .remote
                            case .virusCheck, .uploading:
                                modifiedFileEntry.status = .localAndRemote
                        }
						
                    case .inProgress:
                        switch fileEntryCurrentStatus {
							case .virusCheck, .uploading, .remote, .downloading, .retry:
                                modifiedFileEntry.status = .virusCheck
                            case .error, .localAndRemote:
                                // if local copy at error state or at wrong state we need delete it
                                // and user have to download file again after completion
                                // show file in .virusCheck state without local preview
                                modifiedFileEntry.status = .virusCheck
                                if let filename = modifiedFileEntry.localStorageFilename {
                                    localFileStore(filename).remove()
                                }
                        }
						
                    case .commonError, .typeNotSupported:
						modifiedFileEntry.status = .error
						
					case .antivirusError:
						modifiedFileEntry.status = .error
						
				}
                
                modifiedFileEntry.originalFilename = file.name
                modifiedFileEntry.creationDate = file.creationDate
                modifiedFileEntry.sizeInBytes = file.sizeInBytes
                modifiedFileEntry.fileId = file.id
                
                fileEntries[index] = modifiedFileEntry
            } else {
                let fileEntryStatus: MedicalCardFileEntry.Status
                
                switch file.status {
                    case .success:
                        fileEntryStatus = .remote
                    case .inProgress:
                        fileEntryStatus = .virusCheck
                    case .commonError, .typeNotSupported:
                        fileEntryStatus = .error
					case .antivirusError:
						fileEntryStatus = .error
				}
                
                let fileEntry = MedicalCardFileEntry(
                    id: UUID().uuidString,
                    status: fileEntryStatus,
                    originalFilename: file.name,
                    creationDate: file.creationDate,
                    sizeInBytes: file.sizeInBytes,
                    fileExtension: file.fileExtension,
                    fileId: file.id
                )
                
                // cache images only when new files (with success status) were acquired on remote server
                if fileEntry.status == .remote,
                   isImageFileExtension(fileExtension: fileEntry.fileExtension?.lowercased()) {
                    cachePreviewImage(for: fileEntry)
                }
                
                newFileEntries.append(fileEntry)
            }
        }
                
        fileEntries.append(contentsOf: newFileEntries)
    }
    
    func size(of localFilename: String) -> Int {
        return Int(self.localFileStore(localFilename).sizeBytes)
    }
    
    func localStorageUrl(for filename: String) -> URL? {
        return localFileStore(filename).exists
            ? localFileStore(filename).url
            : nil
    }
    
    private let imageFileExtensions: [String] = [
        "png",
        "jpeg",
        "jpg",
        "tif",
        "tiff"
    ]
    
    private func isImageFileExtension(
        fileExtension: String?
    ) -> Bool {
        guard let fileExtension = fileExtension
        else { return false }
        
        return imageFileExtensions.contains(fileExtension)
    }
    
    func imagePreviewUrl(for fileEntry: MedicalCardFileEntry) -> URL? {
        guard isImageFileExtension(fileExtension: fileEntry.fileExtension?.lowercased())
        else { return nil}
        
        switch fileEntry.status {
			case .remote, .retry, .downloading:
                return URL(string: "https://i.ytimg.com/vi/q0XBHwIt3E4/maxresdefault.jpg") // test url
            case .localAndRemote, .uploading, .virusCheck, .error:
                guard let localStorageFilename = fileEntry.localStorageFilename
                else { return nil }
                
                return localFileStore(localStorageFilename).url
        }
    }
    
    private func cachePreviewImage(for fileEntry: MedicalCardFileEntry) {
        if isImageFileExtension(
            fileExtension: fileEntry.fileExtension?.lowercased()
        ) {
            SDWebImageManager.shared.loadImage(
                with: self.imagePreviewUrl(for: fileEntry),
                options: .highPriority,
                progress: nil,
                completed: { _, _, _, _, _, _ in }
            )
        }
    }
	
	func isImage(_ fileEntry: MedicalCardFileEntry) -> Bool {  return false }
        
    private struct Constants {
        static let filesLocalStorageDirectoryName = "medical_card_local"
    }
}
