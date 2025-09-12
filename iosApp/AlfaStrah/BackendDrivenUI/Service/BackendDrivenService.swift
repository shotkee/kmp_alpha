//
//  BackendDrivenDmsService.swift
//  AlfaStrah
//
//  Created by vit on 27.03.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	typealias ContentWithInfoMessage = (content: [String: Any], infoMessage: InfoMessage?)
	
	protocol BackendDrivenService {
		func bduiObject(
			needPostData: Bool,
			addTimezoneParameter: Bool,
			formData: [FormDataEntryComponentDTO]?,
			for requestBackendComponent: RequestComponentDTO,
			completion: @escaping (Result<ContentWithInfoMessage, AlfastrahError>) -> Void
		)
		
		func backendDrivenDataForMain(completion: @escaping (Result<[String: Any], AlfastrahError>) -> Void)
		func profile(completion: @escaping (Result<[String: Any], AlfastrahError>) -> Void)
		func bonusPoints(completion: @escaping (Result<[String: Any], AlfastrahError>) -> Void)
		func products(completion: @escaping (Result<[String: Any], AlfastrahError>) -> Void)
		
		func eventReportOSAGO(insuranceId: String, completion: @escaping (Result<[String: Any], AlfastrahError>) -> Void)
		
		// deprecated
		func backendDrivenData(
			url: URL,
			headers: [String: String],
			completion: @escaping (Result<ContentWithInfoMessage, AlfastrahError>) -> Void
		)
		
		typealias FileId = Int
		
		func upload(
			fileEntry: FilePickerFileEntry,
			to uploadUrl: URL,
			completion: @escaping (Result<FileId, AlfastrahError>) -> Void
		)
	}
}
