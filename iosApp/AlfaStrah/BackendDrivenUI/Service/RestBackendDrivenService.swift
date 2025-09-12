//
//  RestBackendDrivenService.swift
//  AlfaStrah
//
//  Created by vit on 27.03.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Legacy

extension BDUI {
	class RestBackendDrivenService: NSObject,
									BackendDrivenService,
									URLSessionDataDelegate {
		private let http: Http
		private let requestAuthorizer: HttpRequestAuthorizer
		private let userSessionService: UserSessionService
		private let endpointsService: EndpointsService
		
		private let disposeBag: DisposeBag = DisposeBag()
		
		private var cancellable: CancellableNetworkTaskContainer?
		
		private var accessToken: String?
		
		init(
			http: Http,
			requestAuthorizer: HttpRequestAuthorizer,
			userSessionService: UserSessionService,
			endpointsService: EndpointsService
		) {
			self.http = http
			self.requestAuthorizer = requestAuthorizer
			self.userSessionService = userSessionService
			self.endpointsService = endpointsService
			
			self.accessToken = userSessionService.session?.accessToken
			
			super.init()
			
			userSessionService.subscribeSession { session in
				self.accessToken = session?.accessToken
			}.disposed(by: disposeBag)
		}
		
		func bduiObject(
			needPostData: Bool,
			addTimezoneParameter: Bool,
			formData: [BDUI.FormDataEntryComponentDTO]?,
			for requestBackendComponent: BDUI.RequestComponentDTO,
			completion: @escaping (Result<ContentWithInfoMessage, AlfastrahError>) -> Void
		) {
			
			self.cancellable?.cancel()
			self.cancellable = CancellableNetworkTaskContainer()
			
			guard let url = requestBackendComponent.url
			else {
				completion(.failure(AlfastrahError.unknownError))
				return
			}
			
			var headersDict: [String: String] = [:]
			
			if let headers = requestBackendComponent.headers {
				for header in headers {
					if let headerName = header.header,
					   let headerValue = header.value {
						headersDict[headerName] = headerValue
					}
				}
			}
			
			let queue = DispatchQueue.global(qos: .default)
			
			guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
			else { return }
			
			guard let scheme = urlComponents.scheme,
				  let host = urlComponents.host,
				  let baseUrl = URL(string: "\(scheme)://\(host)")
			else { return }
			
			var parameters: [String: String] = [:]
			
			if let queryItems = urlComponents.queryItems {
				parameters = Dictionary(uniqueKeysWithValues: queryItems.compactMap {
					if let value = $0.value {
						return ($0.name, value)
					} else {
						return nil
					}
				})
			}
			
			if addTimezoneParameter {
				let currentTimezoneString = AppLocale.currentTimezoneISO8601()
				parameters["timezone"] = currentTimezoneString
			}
			
			let rest = AlfastrahRestClient(
				http: self.http,
				baseURL: baseUrl,
				workQueue: queue,
				completionQueue: .main,
				requestAuthorizer: self.requestAuthorizer
			)
			
			var formDataDict: [String: Any] = [:]
			
			if let postDataJsonString = requestBackendComponent.postBody,
			   !postDataJsonString.isEmpty,
			   let postDataDictionary = try? JSONSerialization.jsonObject(with: Data(postDataJsonString.utf8)) as? [String: Any] {
				
				formDataDict = postDataDictionary
			}
			
			if needPostData {
				if let formData {
					for entry in formData {
						if let name = entry.name,
						   let value = entry.value {
							if name.hasSuffix("[]") {
								let arrayName = String(name.dropLast(2))
								
								if formDataDict[arrayName] == nil {
									formDataDict[arrayName] = [value]
								} else {
									if let sourceArray = formDataDict[arrayName] as? [Any] {
										var mutableArrayForName: [Any] = sourceArray
										mutableArrayForName.append(value)
										
										formDataDict[arrayName] = mutableArrayForName
									}
								}
							} else {
								formDataDict[name] = value
							}
						}
					}
				}
			}
			
			var task: NetworkTask?
			
			if requestBackendComponent.method == .post {
				task = rest.create(
					path: {
						if let items = urlComponents.queryItems,
						   !items.isEmpty,
						   let fullUrlPath = requestBackendComponent.url?.absoluteString {
							return fullUrlPath
						}
						
						return urlComponents.path
					}(),
					id: nil,
					object: formDataDict,
					headers: headersDict,
					requestTransformer: DictionaryTransformer(
						keyTransformer: CastTransformer<AnyHashable, String>(),
						valueTransformer: CastTransformer<Any, Any>()
					),
					responseTransformer: ResponseWithInfoMessageTransformer(
						transformer: DictionaryTransformer(
							keyTransformer: CastTransformer<AnyHashable, String>(),
							valueTransformer: CastTransformer<Any, Any>()
						)
					),
					completion: { result in
						self.handleRequest(result, completion: completion)
					}
				)
			} else {
				task = rest.read(
					path: urlComponents.path,
					id: nil,
					parameters: parameters,
					headers: headersDict,
					responseTransformer: ResponseWithInfoMessageTransformer(
						transformer: DictionaryTransformer(
							keyTransformer: CastTransformer<AnyHashable, String>(),
							valueTransformer: CastTransformer<Any, Any>()
						)),
					completion: { result in
						self.handleRequest(result, completion: completion)
					}
				)
			}
			
			if let task {
				self.cancellable?.addCancellables([ task ])
			}
		}
		
		private func handleRequest(
			_ result: Result<ContentWithInfoMessage, NetworkError>,
			completion: @escaping (Result<ContentWithInfoMessage, AlfastrahError>) -> Void
		) {
			let handleResult = { (_ result: Result<ContentWithInfoMessage, AlfastrahError>) -> Void in
				switch result {
					case .success(let data):
						if let infoMessage = data.infoMessage {
							completion(.success((data.content, infoMessage)))
						} else if let key = data.content.first?.key,
								  let value = data.content[key] as? [String: Any] {	// contain only one object - screen, action, .etc
							completion(.success((value, nil)))
						} else {
							completion(.failure(AlfastrahError.unknownError))
						}
						
					case .failure(let error):
						completion(.failure(error))
				}
			}
			
			mapCompletion(handleResult)(result)
		}
		
		// MARK: - Screens in tabs
		func backendDrivenDataForMain(
			completion: @escaping (Result<[String: Any], AlfastrahError>) -> Void
		) {
			endpointsService.endpoints { result in
				switch result {
					case .success(let endpoints):
						if let mainUrlString = endpoints.mainPagePathBDUI {
							guard let url = URL(string: mainUrlString),
								  let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
							else { return }
							
							guard let scheme = urlComponents.scheme,
								  let host = urlComponents.host,
								  let baseUrl = URL(string: "\(scheme)://\(host)")
							else { return }
							
							let queue = DispatchQueue.global(qos: .default)
							
							let rest = AlfastrahRestClient(
								http: self.http,
								baseURL: baseUrl,
								workQueue: queue,
								completionQueue: .main,
								requestAuthorizer: self.requestAuthorizer
							)
							
							rest.read(
								path: urlComponents.path,
								id: nil,
								parameters: [:],
								headers: [:],
								responseTransformer: ResponseTransformer(
									transformer: DictionaryTransformer(
										keyTransformer: CastTransformer<AnyHashable, String>(),
										valueTransformer: CastTransformer<Any, Any>()
									)),
								completion: mapCompletion(completion)
							)
							
						}
						
					case .failure(let error):
						completion(.failure(error))
				}
			}
		}
		
		func profile(completion: @escaping (Result<[String: Any], AlfastrahError>) -> Void) {
			endpointsService.endpoints { result in
				switch result {
					case .success(let endpoints):
						guard let profileUrlString = endpoints.profilePathBDUI,
							  let url = URL(string: profileUrlString),
							  let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
							  let scheme = urlComponents.scheme,
							  let host = urlComponents.host,
							  let baseUrl = URL(string: "\(scheme)://\(host)")
						else {
							completion(.failure(AlfastrahError.unknownError))
							return
						}
						
						let queue = DispatchQueue.global(qos: .default)
						
						let rest = AlfastrahRestClient(
							http: self.http,
							baseURL: baseUrl,
							workQueue: queue,
							completionQueue: .main,
							requestAuthorizer: self.requestAuthorizer
						)
						
						rest.read(
							path: urlComponents.path,
							id: nil,
							parameters: [:],
							headers: [:],
							responseTransformer: ResponseTransformer(
								transformer: DictionaryTransformer(
									keyTransformer: CastTransformer<AnyHashable, String>(),
									valueTransformer: CastTransformer<Any, Any>()
								)),
							completion: mapCompletion(completion)
						)
						
					case .failure(let error):
						completion(.failure(error))
				}
			}
		}
		
		func bonusPoints(completion: @escaping (Result<[String: Any], AlfastrahError>) -> Void) {
			endpointsService.endpoints { result in
				switch result {
					case .success(let endpoints):
						if let profileUrlString = endpoints.loyaltyPathBDUI {
							guard let url = URL(string: profileUrlString),
								  let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
							else { return }
							
							guard let scheme = urlComponents.scheme,
								  let host = urlComponents.host,
								  let baseUrl = URL(string: "\(scheme)://\(host)")
							else { return }
							
							let queue = DispatchQueue.global(qos: .default)
							
							let rest = AlfastrahRestClient(
								http: self.http,
								baseURL: baseUrl,
								workQueue: queue,
								completionQueue: .main,
								requestAuthorizer: self.requestAuthorizer
							)
							
							rest.read(
								path: urlComponents.path,
								id: nil,
								parameters: [:],
								headers: [:],
								responseTransformer: ResponseTransformer(
									transformer: DictionaryTransformer(
										keyTransformer: CastTransformer<AnyHashable, String>(),
										valueTransformer: CastTransformer<Any, Any>()
									)),
								completion: mapCompletion(completion)
							)
							
						}
						
					case .failure(let error):
						completion(.failure(error))
				}
			}
		}
		
		func products(completion: @escaping (Result<[String: Any], AlfastrahError>) -> Void) {
			func request(productsPath: String, completion: @escaping (Result<[String: Any], AlfastrahError>) -> Void) {
				guard let baseUrl = URL(string: "https://alfa-v3.entelis.team")
				else { return }
				
				let queue = DispatchQueue.global(qos: .default)
				
				let rest = AlfastrahRestClient(
					http: self.http,
					baseURL: baseUrl,
					workQueue: queue,
					completionQueue: .main,
					requestAuthorizer: self.requestAuthorizer
				)
				
				rest.read(
					path: productsPath,
					id: nil,
					parameters: [:],
					headers: [:],
					responseTransformer: ResponseTransformer(
						transformer: DictionaryTransformer(
							keyTransformer: CastTransformer<AnyHashable, String>(),
							valueTransformer: CastTransformer<Any, Any>()
						)),
					completion: mapCompletion(completion)
				)
			}
			
			if let productsUrlBDUI = self.endpointsService.productsUrlBDUI {
				request(productsPath: productsUrlBDUI.absoluteString, completion: completion)
			} else {
				self.endpointsService.endpoints { result in
					switch result {
						case .success(let endpoints):
							request(productsPath: endpoints.productsUrlBDUI?.absoluteString ?? "", completion: completion)
							
						case .failure(let error):
							completion(.failure(error))
					}
				}
			}
		}
		
		// MARK: - Event report OSAGO
		func eventReportOSAGO(insuranceId: String, completion: @escaping (Result<[String: Any], AlfastrahError>) -> Void) {
			endpointsService.endpoints { result in
				switch result {
					case .success(let endpoints):
						guard let urlString = endpoints.eventReportOsagoPathBDUI,
							  let url = URL(string: urlString),
							  let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
							  let scheme = urlComponents.scheme,
							  let host = urlComponents.host,
							  let baseUrl = URL(string: "\(scheme)://\(host)")
						else {
							completion(.failure(AlfastrahError.unknownError))
							return
						}
						
						let queue = DispatchQueue.global(qos: .default)
						
						let rest = AlfastrahRestClient(
							http: self.http,
							baseURL: baseUrl,
							workQueue: queue,
							completionQueue: .main,
							requestAuthorizer: self.requestAuthorizer
						)
						
						rest.read(
							path: urlComponents.path,
							id: nil,
							parameters: [ "insuranceId": insuranceId ],
							headers: [:],
							responseTransformer: ResponseTransformer(
								transformer: DictionaryTransformer(
									keyTransformer: CastTransformer<AnyHashable, String>(),
									valueTransformer: CastTransformer<Any, Any>()
								)),
							completion: mapCompletion(completion)
						)
						
					case .failure(let error):
						completion(.failure(error))
				}
			}
		}
		
		// MARK: - DEPRECATED. Dms compabiltity.
		func backendDrivenData(
			url: URL,
			headers: [String: String],
			completion: @escaping (Result<ContentWithInfoMessage, AlfastrahError>) -> Void
		) {
			let queue = DispatchQueue.global(qos: .default)
			
			guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
			else { return }
			
			guard let scheme = urlComponents.scheme,
				  let host = urlComponents.host,
				  let baseUrl = URL(string: "\(scheme)://\(host)")
			else { return }
			
			var parameters: [String: String] = [:]
			
			if let queryItems = urlComponents.queryItems {
				parameters = Dictionary(uniqueKeysWithValues: queryItems.compactMap {
					if let value = $0.value {
						return ($0.name, value)
					} else {
						return nil
					}
				})
			}
			
			let currentTimezoneString = AppLocale.currentTimezoneISO8601()
			parameters["timezone"] = currentTimezoneString
			
			let rest = AlfastrahRestClient(
				http: self.http,
				baseURL: baseUrl,
				workQueue: queue,
				completionQueue: .main,
				requestAuthorizer: self.requestAuthorizer
			)
			
			rest.read(
				path: urlComponents.path,
				id: nil,
				parameters: parameters,
				headers: headers,
				responseTransformer: ResponseWithInfoMessageTransformer(
					transformer: DictionaryTransformer(
						keyTransformer: CastTransformer<AnyHashable, String>(),
						valueTransformer: CastTransformer<Any, Any>()
					)),
				completion: mapCompletion(completion)
			)
		}
		
		// MARK: - Upload
		private lazy var urlSession = createUrlSession()
		
		private typealias QueueOperationHandler = (Int, FilePickerEntryState) -> Void
		private var uploadsQueue: [URLSessionTask: (FilePickerFileEntry, QueueOperationHandler)] = [:]
		
		private func createUrlSession() -> URLSession {
			let configuration = URLSessionConfiguration.default
			
			configuration.urlCache = nil
			configuration.httpShouldSetCookies = false
			configuration.timeoutIntervalForRequest = 300
			
			configuration.requestCachePolicy = .returnCacheDataElseLoad
			configuration.sessionSendsLaunchEvents = true
			configuration.allowsCellularAccess = true
			// wait for optimal conditions to perform the transfer, such as when the device is plugged in or connected to Wi-Fi
			configuration.isDiscretionary = true
			
			let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
			
			return session
		}
		
		// MARK: - URLSessionDelegate
		public func urlSession(
			_ session: URLSession,
			task: URLSessionTask,
			didSendBodyData bytesSent: Int64,
			totalBytesSent: Int64,
			totalBytesExpectedToSend: Int64
		) {}
		
		func upload(
			fileEntry: FilePickerFileEntry,
			to uploadUrl: URL,
			completion: @escaping (Result<FileId, AlfastrahError>) -> Void
		) {
			guard let attachment = fileEntry.attachment
			else {
				completion(.failure(AlfastrahError.unknownError))
				return
			}
			
			let multipartResult = multipartEncode(
				fileUrl: attachment.url,
				parameters: [:]
			)
			
			guard let (serializedUrl, serializedContentType) = multipartResult.value,
				  FileManager.default.fileExistsAtURL(serializedUrl)
			else {
				let error = AlfastrahError.api(
					.init(
						httpCode: 999,
						internalCode: 999,
						title: NSLocalizedString("common_error_title", comment: ""),
						message: NSLocalizedString("common_error_something_went_wrong_tile", comment: "")
					)
				)
				
				completion(.failure(error))
				
				return
			}
			
			var request = requestAuthorizer.authorize(
				request: .init(url: uploadUrl)
			)
			
			request.httpMethod = "POST"
			request.addValue(
				serializedContentType,
				forHTTPHeaderField: "Content-Type"
			)
			
			fileEntry.state = .processing(previewUrl: attachment.url, attachment: fileEntry.attachment, type: .uploading)
			
			let task = urlSession.uploadTask(with: request, fromFile: serializedUrl) { data, response, error in
				DispatchQueue.main.async {
					if let error = error {
						completion(.failure(.error(error)))
					} else if let data = data,
							  let responseDictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
							  let dataDictionary = responseDictionary["data"] as? [String: Any],
							  let fileId = dataDictionary["fileId"] as? Int {
						completion(.success(fileId))
						fileEntry.state = .ready(previewUrl: attachment.url, attachment: fileEntry.attachment)
					} else {
						completion(.failure(AlfastrahError.unknownError))
					}
				}
			}
			
			task.resume()
		}
		
		// MARK: - Upload encode
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
	}
}
