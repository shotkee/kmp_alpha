//
//  RestMedicalCardService.swift
//  AlfaStrah
//
//  Created by Makson on 02.05.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy
import SDWebImage

// swiftlint:disable file_length
class RestMedicalCardService: MedicalCardService, Updatable {
    private let applicationSettingsService: ApplicationSettingsService
    private let rest: FullRestClient
    private let store: Store
    private let authorizer: HttpRequestAuthorizer
    private let endpointsService: EndpointsService
    
    // MARK: - Contstants
    private struct Constants {
        static let filesLocalStorageDirectoryName = "medical_card_local"
    }
    
    // MARK: - Local Files Storage
    private let filesLocalStorageDirectory = Storage.documentsDirectory.appendingPathComponent(
        Constants.filesLocalStorageDirectoryName,
        isDirectory: true
    )
   
    private func localFileStore(_ file: String) -> SimpleAttachmentStore {
        SimpleAttachmentStore(directory: filesLocalStorageDirectory, name: file)
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
    
    private struct FileUpload {
        let attachmentUploadSource: Attachment?
        let fileEntryToUpload: MedicalCardFileEntry?
        var taskId: FileOperationId?
    }
    
    private typealias UploadId = String
    
    private struct FileDownload {
        let fileEntry: MedicalCardFileEntry
        var taskId: FileOperationId?
    }
    
    private typealias DownloadId = String
    
    typealias ResultCallback = (Result<Void, AlfastrahError>) -> Void
    
    // MARK: - Service Variables
    private lazy var fileOperationSession = createSession()
    
    private var uploadsQueue: [UploadId: FileUpload] = [:]
    private var downloadsQueue: [DownloadId: FileDownload] = [:]
    
    private var getMedicalCardTokenCompletions: [ResultCallback] = []
    
    private var isAuthorizationTokenRequestInProgress = false
        
    private(set) var medicalCardToken: MedicalCardToken? {
        get {
            applicationSettingsService.medicalCardToken
        }
        set {
            applicationSettingsService.medicalCardToken = newValue
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
    
    private lazy var uploadsSession = createUploadsSession()
    
	private var logger: TaggedLogger?
	
    init(
        rest: FullRestClient,
		logger: TaggedLogger?,
        store: Store,
        authorizer: HttpRequestAuthorizer,
        applicationSettingsService: ApplicationSettingsService,
        endpointsService: EndpointsService
    ) {
        self.rest = rest
		self.logger = logger
        self.store = store
        self.applicationSettingsService = applicationSettingsService
        self.authorizer = authorizer
        self.endpointsService = endpointsService
        medicalCardToken = applicationSettingsService.medicalCardToken
		
        guard let fileEntries = cachedFileEntries()
        else { return }

        self.fileEntries = fileEntries.map {
            var fileEntry = $0

			switch fileEntry.status {
				case .uploading:
					fileEntry.status = .error
					
				case .downloading, .retry:
					fileEntry.status = .remote
					
				case .localAndRemote, .remote, .error, .virusCheck:
					break

			}
			
            return fileEntry
        }
    }
    
    func hasMedicalCardToken() -> Bool {
        if let medicalCardToken = medicalCardToken,
           medicalCardToken.expirationDate > Date() {
            return true
        } else {
            return false
        }
    }
    
    private func authorize(request: URLRequest) -> URLRequest {
        var request = request
        
        medicalCardToken.map { request.setValue("Bearer \($0.token)", forHTTPHeaderField: "Authorization") }
        return request
    }
    
    private func authorize(request: URLRequest, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = request
        
        func handleValidToken() {
            medicalCardToken.map { request.setValue("\($0.token)", forHTTPHeaderField: "Authorization") }
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
    
    func haveUploadingFiles() -> Bool {
        fileEntries.contains(
            where: { $0.status == .uploading }
        )
    }
    
    func getEndpoint(completion: @escaping () -> Void){
        endpointsService.endpoints(completion: { _ in completion() })
    }
    
    func getMedicalCardToken(completion: @escaping (Result<Void, AlfastrahError>) -> Void) {
        rest.read(
            path: "/api/medicalfilestorage/token",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: MedicalCardTokenTransformer()),
            completion: mapCompletion { [weak self] result in
                guard let self = self
                else { return }
                
                switch result {
                    case .success(let token):
                        self.medicalCardToken = token
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        )
    }
    
    // MARK: - Queues operations
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
    
    func renameFile(
        fileEntry: MedicalCardFileEntry,
        completion: @escaping (Result<Void, MedicalCardServiceError>) -> Void
    ) {
        guard let fileId = fileEntry.fileId
        else {
            completion(.failure(.common(NSLocalizedString("medical_card_file_entry_common_error", comment: ""))))
            return
        }
        
        rest.create(
            path: "/api/medicalfilestorage/file_rename",
            id: nil,
            object: [
                "file_id": fileId,
                "title": fileEntry.originalFilename
            ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, Any>()
            ),
            responseTransformer: VoidTransformer(),
            completion: mapCompletion { result in
                switch result {
                    case .success:
                        self.updateFileEntry(fileEntry: fileEntry)
                        completion(.success(()))
                    case .failure(let error):
                        self.fileEntriesSubscriptions.fire(
                            self.convertMedicalCardFileEntriesToFileEntriesGroup(
                                self.fileEntries
                            )
                        )
                        completion(.failure(.error(error)))
                }
            }
        )
    }
    
    private func createSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.httpShouldSetCookies = false
        configuration.timeoutIntervalForRequest = 300
        
        return .init(configuration: configuration)
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
    
    func removeFile(
        searchString: String,
        fileId: Int64,
        completion: @escaping (Result<Void, AlfastrahError>) -> Void
    ) {
        updateMedicalCardTokenIfExpired { result in
            switch result {
                case .success:
                    self.rest.create(
                        path: "/api/medicalfilestorage/file_remove",
                        id: nil,
                        object: [
                            "file_id": fileId,
                        ],
                        headers: [:],
                        requestTransformer: DictionaryTransformer(
                            keyTransformer: CastTransformer<AnyHashable, String>(),
                            valueTransformer: CastTransformer<Any, Any>()
                        ),
                        responseTransformer: VoidTransformer(),
                        completion: mapCompletion { result in
                            switch result {
                                case .success:
                                    self.fileEntries = self.fileEntries.filter { $0.fileId != fileId }
                                    completion(.success(()))
                                case .failure(let error):
                                    completion(.failure(error))
                            }
                        }
                    )
                case .failure:
                    completion(.failure(.unknownError))
            }
        }
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
    
    func getActualFiles(searchString: String) -> [MedicalCardFileEntriesGroup] {
        searchFiles(searchString: searchString.lowercased())
    }
    
    private func updateFileEntry(
        fileEntry: MedicalCardFileEntry
    ) {
        guard let index = fileEntries.firstIndex(where: { $0.id == fileEntry.id })
        else { return }
        
        fileEntries[index].originalFilename = fileEntry.originalFilename
    }
    
    func getMedicalCardFiles(useCache: Bool, completion: @escaping (Result<[MedicalCardFile], AlfastrahError>) -> Void) {
        if useCache, let files = cachedFiles() {
            completion(.success(files))
        } else {
            rest.read(
                path: "/api/medicalfilestorage/file_list",
                id: nil,
                parameters: [:],
                headers: [:],
                responseTransformer: ResponseTransformer(
                    key: "file_list",
                    transformer: ArrayTransformer(
                        transformer: MedicalCardFileTransformer()
                    )
                ),
                completion: mapCompletion { result in
                    switch result {
                        case .success(let files):
                            try? self.store.write { transaction in
                                try transaction.delete(type: MedicalCardFile.self)
                                try transaction.insert(files)
                            }
                            completion(.success(files))
                        case .failure(let error):
                            completion(.failure(error))
                    }
                }
            )
        }
    }
          
    let urlPathPreviewImage = "/resource-cloud/preview-content/"
    
    func imagePreviewUrl(for fileEntry: MedicalCardFileEntry) -> URL? {
        if !isImageFileExtension(fileExtension: fileEntry.fileExtension) {
            return nil
        }
        
        if let localStorageFilename = fileEntry.localStorageFilename,
           let url = localStorageUrl(for: localStorageFilename) {
            return url
        } else if let baseDomain = endpointsService.medicalCardFileServerDomain,
           let fileId = fileEntry.fileId {
            return URL(string: "https://\(baseDomain)\(urlPathPreviewImage)\(fileId)/mobile-app")
        } else { return nil }
    }
    
    func isUrlPreviewImage(url: URL) -> Bool {
        guard let medicalCardFileServerDomain = endpointsService.medicalCardFileServerDomain,
              let basePath = URL(string: "https://\(medicalCardFileServerDomain)")?.path
        else { return false }
        
        return url.absoluteString.contains(
            basePath + urlPathPreviewImage
        )
    }
    
    func searchFiles(searchString: String) -> [MedicalCardFileEntriesGroup] {
        if searchString.isEmpty {
            return self.convertMedicalCardFileEntriesToFileEntriesGroup(fileEntries)
        }
        else {
            var files: [MedicalCardFileEntry] = []
            fileEntries.forEach { fileEntry in
                if fileEntry.originalFilename.lowercased().contains(searchString.lowercased()) {
                    files.append(fileEntry)
                }
            }
            
            files = files.sorted { $0.creationDate > $1.creationDate }
            
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
    
    func getMedicalCardFiles(completion: @escaping (Result<[MedicalCardFile], AlfastrahError>) -> Void) {
        rest.read(
            path: "/api/medicalfilestorage/file_list",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "file_list",
                transformer: ArrayTransformer(
                    transformer: MedicalCardFileTransformer()
                )
            ),
            completion: mapCompletion { result in
                switch result {
                    case .success(let response):
                        completion(.success(response))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        )
    }
    
    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }
    
    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }
    
    func erase(logout: Bool) {
        if logout {
            medicalCardToken = nil
            fileEntries = []
        }
        
        cancelAllOperations()
        
        try? store.write { transaction in
            try transaction.delete(type: MedicalCardFile.self)
            try transaction.delete(type: MedicalCardFileEntry.self)
        }
        try? FileManager.default.removeItem(at: filesLocalStorageDirectory)
    }
    
    private func cachedFiles() -> [MedicalCardFile]? {
        var files: [MedicalCardFile] = []
        try? store.read { transaction in
            files = try transaction.select()
        }
        return files
    }
    
    private func createUploadsSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.httpShouldSetCookies = false
        configuration.timeoutIntervalForRequest = 300
        
        return .init(configuration: configuration)
    }
    
    private func createUploadTask(
        request: URLRequest,
        serializedUrl: URL,
        fileEntry: MedicalCardFileEntry,
        completion: @escaping (FileOperationResult) -> Void
    ) -> FileOperationId {
        let authorizedRequest = authorize(request: request)
        
        let task = fileOperationSession.uploadTask(
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
                              let status = responseDictionary["status"] as? Int,
                              let statusText = responseDictionary["statusText"] as? String {
                        switch status {
                            case 0:
                                // resourceEntityId only success reguest
                                if let medicalCardFileId = dataDictionary["resourceEntityId"] as? Int64 {
                                    var modifiedMedicalCard = fileEntry
                                    modifiedMedicalCard.fileId = medicalCardFileId
                                    modifiedMedicalCard.status = .virusCheck
                                    
                                    completion(.success(modifiedMedicalCard))
                                }
                                else {
                                    completion(.failure(.common(NSLocalizedString("medical_card_file_entry_common_error", comment: ""))))
                                }
                            case -220:
                                completion(.failure(.common(statusText)))
                            case -221:
                                completion(.failure(.fileSizeExceeded(fileEntry.originalFilename, statusText)))
                            case -222:
                                completion(.failure(.storageSizeExceeded(statusText)))
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
        endpointsService.endpoints{ result in
            switch result {
                case .success(let endpoints):
                    self.updateMedicalCardTokenIfExpired { result in
                        switch result {
                            case .success:
                                for (key, value) in self.uploadsQueue {
                                    guard let attachment = value.attachmentUploadSource,
                                          let fileEntryToUpload = value.fileEntryToUpload
                                    else { continue }

                                    // start upload
                                    let taskId = self.uploadFile(
                                        fileEntry: fileEntryToUpload,
                                        sourceFileUrl: attachment.url,
                                        filesServerBaseUrl: URL(string: "https://\(endpoints.medicalCardFileServerDomain)")
                                    ) { result in
                                    // after trying to upload a file, we remove the entry from the queue
                                    // and pass the file/error to the file array
                                        self.handleFileUpload(
                                            result,
                                            for: fileEntryToUpload,
                                            completion: { result in
                                                switch result {
                                                    case .success:
                                                        completion(.success(attachment))
                                                    case .failure(let error):
                                                        completion(.failure(error))
                                                }
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
		self.localFileStore(filenameWithExtension).copy(from: attachment.url) { _ in}
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
    
    private func uploadFile(
        fileEntry: MedicalCardFileEntry,
        sourceFileUrl: URL,
        filesServerBaseUrl: URL?,
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
            
            var request = authorize(
                request: .init(
                    url: filesServerBaseUrl.appendingPathComponent("/resource-cloud/mobile-app")
                )
            )
            
            request.httpMethod = "POST"
            request.addValue(
                serializedContentType,
                forHTTPHeaderField: "Content-Type"
            )
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
    
    func cancelUpload(for fileEntry: MedicalCardFileEntry) {
        guard let activeUpload = uploadsQueue.values.first(where: { $0.fileEntryToUpload?.id == fileEntry.id }),
              let taskId = activeUpload.taskId
        else { return }
        
        removeCachedFile(fileName: fileEntry.originalFilename)
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
    
    private func cancelTask(by id: Int, completion: @escaping () -> Void) {
        uploadsSession.getAllTasks { tasks in
            let task = tasks.first { $0.taskIdentifier == id }
            task?.cancel()
            completion()
        }
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
                        completion(.success(()))
                    case .failure:
                        // try to get cached files
                        self?.getMedicalCardFiles(
                            useCache: true,
                            completion: { [weak self] result in
                                switch result {
                                    case .success(let files):
                                        self?.updateFileEntries(with: files)
                                        completion(.success(()))
                                    case .failure(let error):
                                        completion(.failure(error))
                                }
                            }
                        )
                }
            }
        )
    }
    
    private func updateFileEntries(with files: [MedicalCardFile]) {
        var newFileEntries: [MedicalCardFileEntry] = []
        var fileEntriesToDelete: [MedicalCardFileEntry] = []
        
        var newRemoteFiles = files

        for (fileEntryIndex, fileEntry) in fileEntries.enumerated() {
            var modifiedFileEntry = fileEntries[fileEntryIndex]

            if let remoteFileIndex = newRemoteFiles.firstIndex(where: { $0.id == fileEntry.fileId }) {
                // modify local entry with data from server
                let fileEntryCurrentStatus = modifiedFileEntry.status

                let remoteFile = newRemoteFiles[remoteFileIndex]

                switch remoteFile.status {
                    case .success:
                        switch fileEntryCurrentStatus {
							case .localAndRemote, .remote, .downloading, .retry:
                                break
                            case .error:
                                // clear local storage and cache from local copy of file entry
                                modifiedFileEntry.status = .remote
                            case .virusCheck:
                                modifiedFileEntry.status = modifiedFileEntry.localStorageFilename != nil
                                    ? .localAndRemote
                                    : .remote
                            case .uploading:
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
					case .commonError:
						modifiedFileEntry.status = .error
						modifiedFileEntry.errorType = .common
					
					case .typeNotSupported:
						modifiedFileEntry.status = .error
						modifiedFileEntry.errorType = .typeNotSupported
						
					case .antivirusError:
						modifiedFileEntry.status = .error
						modifiedFileEntry.errorType = .virusOccured
                }

                modifiedFileEntry.originalFilename = remoteFile.name
                modifiedFileEntry.creationDate = remoteFile.creationDate
                modifiedFileEntry.sizeInBytes = remoteFile.sizeInBytes
                modifiedFileEntry.fileId = remoteFile.id

                fileEntries[fileEntryIndex] = modifiedFileEntry
                
                newRemoteFiles = newRemoteFiles.filter { $0.id != newRemoteFiles[remoteFileIndex].id }
            } else {
                // if fileEntry has .remote, .localAndRemote, .virusCheck state we need to delete local version otherwise we don't do anything with the file
                switch modifiedFileEntry.status {
					case .error, .uploading, .downloading, .retry:
						break
					case .remote, .localAndRemote, .virusCheck:
                        fileEntriesToDelete.append(fileEntry)
                }
            }
        }
        
        // remove file entries which not exist on server
        fileEntries = fileEntries.filter { !fileEntriesToDelete.contains($0) }
            
        for newFile in newRemoteFiles {
            let fileEntryStatus: MedicalCardFileEntry.Status

            switch newFile.status {
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
                originalFilename: newFile.name,
                creationDate: newFile.creationDate,
                sizeInBytes: newFile.sizeInBytes,
                fileExtension: newFile.fileExtension,
                fileId: newFile.id
            )
			
			if newFile.status == .antivirusError {
				fileEntry.errorType = .virusOccured
			}
			
			if newFile.status == .commonError {
				fileEntry.errorType = .common
			}
		
			if newFile.status == .typeNotSupported {
				fileEntry.errorType = .typeNotSupported
			}
			
            // cache images only when new files (with success status) were accured on remote server
            if fileEntry.status == .remote,
               isImageFileExtension(fileExtension: fileEntry.fileExtension?.lowercased()) {
                cachePreviewImage(for: fileEntry)
            }

            newFileEntries.append(fileEntry)
        }

        fileEntries.append(contentsOf: newFileEntries)
    }
    
    private func cachedFileEntries() -> [MedicalCardFileEntry]? {
        var fileEntries: [MedicalCardFileEntry] = []
        try? store.read { transaction in
            fileEntries = try transaction.select()
        }
        
        return fileEntries
    }
    
    // MARK: - Images
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
       
        return imageFileExtensions.contains(fileExtension.lowercased())
    }
	
	func isImage(_ fileEntry: MedicalCardFileEntry) -> Bool {
		return isImageFileExtension(fileExtension: fileEntry.fileExtension)
	}
    
    private func cachePreviewImage(for fileEntry: MedicalCardFileEntry) {
        if isImageFileExtension(
            fileExtension: fileEntry.fileExtension
        ) {
            SDWebImageManager.shared.loadImage(
                with: self.imagePreviewUrl(for: fileEntry),
                options: .highPriority,
                progress: nil,
                completed: { _, _, _, _, _, _ in }
            )
        }
    }
    
    private var fileEntriesSubscriptions: Subscriptions<[MedicalCardFileEntriesGroup]> = Subscriptions()
            
    func subscribeForFileEntriesUpdates(listener: @escaping ([MedicalCardFileEntriesGroup]) -> Void) -> Subscription {
        fileEntriesSubscriptions.add(listener)
    }
    
    func size(of localFile: String) -> Int {
        return Int(self.localFileStore(localFile).sizeBytes)
    }
    
    func localStorageUrl(for filename: String) -> URL? {
        return localFileStore(filename).exists
            ? localFileStore(filename).url
            : nil
    }
    
    private func addDownload(for fileEntry: MedicalCardFileEntry) {
        downloadsQueue[fileEntry.id] = .init(fileEntry: fileEntry)
    }
    
    func downloadFile(
        for fileEntry: MedicalCardFileEntry,
        completion: @escaping (Result<MedicalCardFileEntry, MedicalCardServiceError>) -> Void
	) {
		guard let index = self.fileEntries.firstIndex(where: { $0.id == fileEntry.id })
		else { return }
		
        endpointsService.endpoints { result in
            switch result {
                case .success(let endpoints):
                    self.fileEntries[index].status = .downloading
                    
                    self.updateMedicalCardTokenIfExpired { result in
                        switch result {
                            case .success:
                                guard let filesServerBaseUrl = URL(
                                    string: "https://\(endpoints.medicalCardFileServerDomain)"
                                ),
                                      let fileId = fileEntry.fileId
                                else { return }
                                
                                let fileEntryId = fileEntry.id
                                
                                self.addDownload(for: fileEntry)
                                
                                var request = self.authorize(
                                    request: .init(
                                        url: filesServerBaseUrl.appendingPathComponent(
                                            "/resource-cloud/content/\(fileId)/mobile-app"
                                        )
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
								self.fileEntries[index].status = .retry
                                completion(.failure(.error(error)))
                        }
                    }
                case .failure(let error):
					self.fileEntries[index].status = .retry
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
						guard let index = self.fileEntries.firstIndex(where: { $0.id == fileEntry.id })
						else { return }
						
						self.fileEntries[index].status = .retry
						
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
											guard let index = self?.fileEntries.firstIndex(where: { $0.id == fileEntry.id })
											else { return }
											
											self?.fileEntries[index].status = .retry
											
                                            completion(.failure(.error(error)))
                                    }
                                }
                            case 200:
                                guard let fileUrl = fileUrl
                                else { return }
                                
								self.saveDownloadedFile(from: fileUrl, for: fileEntry, completion: completion)
                            default:
								guard let index = self.fileEntries.firstIndex(where: { $0.id == fileEntry.id })
								else { return }
								
								self.fileEntries[index].status = .retry
								
                                completion(.failure(.unknownStatusCode))
                        }
                    }
                }
            }
        )
        task.resume()
        return task.taskIdentifier
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
    
    private func saveDownloadedFile(
        from url: URL,
        for fileEntry: MedicalCardFileEntry,
		completion: @escaping (FileOperationResult) -> Void
    ) {
        var modifiedFileEntry = fileEntry
        let filenameWithExtension: String
        
        if let fileExtension = fileEntry.fileExtension?.lowercased() {
            filenameWithExtension = fileEntry.originalFilename + "." + fileExtension
        } else {
            filenameWithExtension = fileEntry.originalFilename
        }
    
		self.localFileStore(filenameWithExtension).copy(from: url) { result in
			switch result {
				case .success:
					modifiedFileEntry.localStorageFilename = filenameWithExtension
					modifiedFileEntry.status = .localAndRemote
					
					completion(.success(modifiedFileEntry))
					
				case .failure(let error):
					modifiedFileEntry.localStorageFilename = filenameWithExtension
					modifiedFileEntry.status = .error
					
					completion(.failure(.error(error)))
			}
		}
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
    
    func retryUploadFile(for fileEntry: MedicalCardFileEntry, completion: @escaping (FileOperationResult) -> Void) {
        endpointsService.endpoints { result in
            switch result {
                case .success(let endpoints):
                    guard let localFilename = fileEntry.localStorageFilename,
                          let url = self.localStorageUrl(for: localFilename),
                          let index = self.fileEntries.firstIndex(where: { $0.id == fileEntry.id })
                    else { return }
                
                    self.fileEntries[index].status = .uploading
                
                    let fileEntryId = fileEntry.id

                    // start upload
                    let taskId = self.uploadFile(
                        fileEntry: fileEntry,
                        sourceFileUrl: url,
                        filesServerBaseUrl: URL(string: "https://\(endpoints.medicalCardFileServerDomain)")
                    ) { result in
                        self.handleFileUpload(
                            result,
                            for: fileEntry,
                            completion: completion
                        )
                    }

                    if let taskId = taskId {
                        self.uploadsQueue[fileEntryId]?.taskId = taskId
                    } else {
                        self.uploadsQueue.removeValue(forKey: fileEntryId)
                    }
                case .failure(let error):
                    completion(.failure(.error(error)))
            }
        }
    }
}
