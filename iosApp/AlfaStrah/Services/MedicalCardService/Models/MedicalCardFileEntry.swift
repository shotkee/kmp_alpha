//
//  MedicalCardUpload.swift
//  AlfaStrah
//
//  Created by vit on 29.05.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class MedicalCardFileEntry: Entity, Equatable, StateObservable {
    let id: String
	var status: Status {
		didSet {
			stateChanged?(status)
		}
	}
	
    var localStorageFilename: String?
    var originalFilename: String
    var creationDate: Date
    var sizeInBytes: Int
    var fileExtension: String?
    var fileId: Int64?
	
	enum ErrorType: String {
		case common = "common"
		case typeNotSupported = "typeNotSupported"
		case virusOccured = "virusOccured"
	}
	
	var errorType: ErrorType?
    
    enum Status: String {
        case uploading = "uploading"
        case virusCheck = "virusCheck"
        case remote = "remote"
        case localAndRemote = "localAndRemote"
		case error = "error"
        case downloading = "downloading"
		case retry = "retryOperation"
    }
	
	typealias State = Status
	
	var stateChanged: ((Status) -> Void)?
	
	func setStateObserver(_ listener: @escaping (Status) -> Void) {
		stateChanged = listener
	}
	
	func deleteStateObserver() {
		stateChanged = nil
	}
	
	init(
		id: String,
		status: Status,
		localStorageFilename: String? = nil,
		originalFilename: String,
		creationDate: Date,
		sizeInBytes: Int,
		fileExtension: String? = nil,
		fileId: Int64? = nil,
		stateChanged: ((Status) -> Void)? = nil,
		errorType: ErrorType? = nil
	) {
		self.id = id
		self.status = status
		self.localStorageFilename = localStorageFilename
		self.originalFilename = originalFilename
		self.creationDate = creationDate
		self.sizeInBytes = sizeInBytes
		self.fileExtension = fileExtension
		self.fileId = fileId
		self.stateChanged = stateChanged
		self.errorType = errorType
	}
	
	static func == (lhs: MedicalCardFileEntry, rhs: MedicalCardFileEntry) -> Bool {
		return lhs.id == rhs.id
	}
}
