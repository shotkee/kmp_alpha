//
//  AssetLoaderDelegate.swift
//  AlfaStrah
//
//  Created by vit on 02.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation
import AVFoundation

class AssetLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {
	private static let SchemeSuffix = "-mediacache"
	
	var completion: ((URL?) -> Void)?
	
	lazy var streamingAssetURL: URL? = {
		if var components = URLComponents(url: self.url, resolvingAgainstBaseURL: false) {
			components.scheme = (components.scheme ?? "") + AssetLoaderDelegate.SchemeSuffix

			return components.url
		}
		
		return nil
	}()
	
	private let url: URL
	private var infoResponse: URLResponse?
	private var urlSession: URLSession?
	private lazy var mediaData = Data()
	private var loadingRequests = [AVAssetResourceLoadingRequest]()
	
	init(withURL url: URL) {
		self.url = url
		
		super.init()
	}
	
	func invalidate() {
		self.loadingRequests.forEach { $0.finishLoading() }
		self.invalidateURLSession()
	}
	
	// MARK: - AVAssetResourceLoaderDelegate
	func resourceLoader(
		_ resourceLoader: AVAssetResourceLoader,
		shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest
	) -> Bool {
		if self.urlSession == nil {
			self.urlSession = self.createURLSession()
			let task = self.urlSession?.dataTask(with: self.url)
			task?.resume()
		}
		
		self.loadingRequests.append(loadingRequest)
		
		return true
	}
	
	func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
		if let index = self.loadingRequests.firstIndex(of: loadingRequest) {
			self.loadingRequests.remove(at: index)
		}
	}
	
	// MARK: - URLSessionTaskDelegate
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		if let error = error {
			print("failed to download media file with error: \(error)")
		} else {
			saveFile { result in
				switch result {
					case .success(let fileUrl):
						DispatchQueue.main.async {
							self.completion?(fileUrl)
							self.invalidateURLSession()
						}
						
					case .failure(let error):
						print("failed to save media file with error: \(error)")
				}
			}
		}
	}
	
	// MARK: - URLSessionDataDelegate
	func urlSession(
		_ session: URLSession,
		dataTask: URLSessionDataTask,
		didReceive response: URLResponse,
		completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
	{
		self.infoResponse = response
		self.processRequests()
		
		completionHandler(.allow)
	}
	
	func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
		self.mediaData.append(data)
		self.processRequests()
	}
	
	private func createURLSession() -> URLSession {
		let config = URLSessionConfiguration.default
		let operationQueue = OperationQueue()
		operationQueue.maxConcurrentOperationCount = 1
		return URLSession(configuration: config, delegate: self, delegateQueue: operationQueue)
	}
	
	private func invalidateURLSession() {
		self.urlSession?.invalidateAndCancel()
		self.urlSession = nil
	}
	
	private func isInfo(request: AVAssetResourceLoadingRequest) -> Bool {
		return request.contentInformationRequest != nil
	}
	
	private func fillInfoRequest(request: inout AVAssetResourceLoadingRequest, response: URLResponse) {
		request.contentInformationRequest?.isByteRangeAccessSupported = true
		request.contentInformationRequest?.contentType = response.mimeType
		request.contentInformationRequest?.contentLength = response.expectedContentLength
	}
	
	private func processRequests() {
		var finishedRequests = Set<AVAssetResourceLoadingRequest>()
		self.loadingRequests.forEach {
			var request = $0
			if self.isInfo(request: request), let response = self.infoResponse {
				self.fillInfoRequest(request: &request, response: response)
			}
			if let dataRequest = request.dataRequest, self.checkAndRespond(forRequest: dataRequest) {
				finishedRequests.insert(request)
				request.finishLoading()
			}
		}
		
		self.loadingRequests = self.loadingRequests.filter { !finishedRequests.contains($0) }
	}
	
	private func checkAndRespond(forRequest dataRequest: AVAssetResourceLoadingDataRequest) -> Bool {
		let downloadedData = self.mediaData
		let downloadedDataLength = Int64(downloadedData.count)
		
		let requestRequestedOffset = dataRequest.requestedOffset
		let requestRequestedLength = Int64(dataRequest.requestedLength)
		let requestCurrentOffset = dataRequest.currentOffset
		
		if downloadedDataLength < requestCurrentOffset {
			return false
		}
		
		let downloadedUnreadDataLength = downloadedDataLength - requestCurrentOffset
		let requestUnreadDataLength = requestRequestedOffset + requestRequestedLength - requestCurrentOffset
		let respondDataLength = min(requestUnreadDataLength, downloadedUnreadDataLength)
		
		guard let range = Range(NSRange(location: Int(requestCurrentOffset), length: Int(respondDataLength)))
		else { return false }
		
		dataRequest.respond(with: downloadedData.subdata(in: range))
		
		let requestEndOffset = requestRequestedOffset + requestRequestedLength
		
		return requestCurrentOffset >= requestEndOffset
	}
	
	private func saveMediaDataToLocalFile() -> URL? {
		guard let docFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
		else { return nil }
		
		let fileName = self.url.lastPathComponent
		let fileURL = docFolderURL.appendingPathComponent(fileName)
		
		if FileManager.default.fileExists(atPath: fileURL.path) {
			do {
				try FileManager.default.removeItem(at: fileURL)
			} catch let error {
				print("Failed to delete file with error: \(error)")
			}
		}
		
		do {
			try self.mediaData.write(to: fileURL)
			print("player save data \(fileURL)")
		} catch let error {
			print("Failed to save data with error: \(error)")
			return nil
		}
		
		return fileURL
	}
	
	@discardableResult private func saveFile(completion: @escaping (Result<URL, Error>) -> Void) -> URL {
		let directoryName = Constants.mediaAssetLoaderTemporaryDirectoryName
			.appendingPathComponent(UUID().uuidString, isDirectory: true)
		
		Storage.createDirectory(url: directoryName)
		
		let url = directoryName.appendingPathComponent(self.url.lastPathComponent, isDirectory: false)
				
		try? FileManager.default.removeItem(at: url)
		
		do {
			try self.mediaData.write(to: url)
			completion(.success(url))
		} catch let error {
			completion(.failure(error))
		}
		
		return url
	}
	
	private struct Constants {
		static let mediaAssetLoaderTemporaryDirectoryName = Storage.tempDirectory.appendingPathComponent(
			"media_asset_loader",
			isDirectory: true
		)
	}
}
