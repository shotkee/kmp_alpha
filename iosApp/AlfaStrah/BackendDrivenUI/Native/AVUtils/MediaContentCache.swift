//
//  MediaContentCache.swift
//  AlfaStrah
//
//  Created by vit on 05.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import AVFoundation

class MediaContentCache: NSObject {
	static let shared: MediaContentCache = .init()
	
	// swiftlint:disable:next large_tuple
	typealias CacheEntry = (
		assetUrlPath: String?,
		assetLoaderDelegate: AssetLoaderDelegate?,
		player: AVQueuePlayer?,
		looper: AVPlayerLooper?,
		localFileURL: String?,
		canBeLoadedFromLocalVersion: Bool,
		notificationToken: NSObjectProtocol?
	)
	
	typealias RemoteUrlPath = String
	
	private static var downloadsQueue: [RemoteUrlPath: CacheEntry] = [:]
	
	func player(for url: URL, reload: @escaping (AVQueuePlayer?, AVPlayerLooper?) -> Void) {
		if let player = Self.downloadsQueue[url.absoluteString]?.player,
		   let looper =  Self.downloadsQueue[url.absoluteString]?.looper,
		   Self.downloadsQueue[url.absoluteString]?.assetUrlPath == nil {
			reload(player, looper)
		} else {
			if let player = Self.downloadsQueue[url.absoluteString]?.player,
			   let looper =  Self.downloadsQueue[url.absoluteString]?.looper {
				reload(player, looper)
			} else {
				createPlayerForRemoteMedia(from: url, reload: reload)
			}
		}
	}
	
	private func createPlayerForLocalMedia(for remoteUrl: URL, completion: @escaping (AVQueuePlayer?, AVPlayerLooper?) -> Void) {
		guard let entry = Self.downloadsQueue[remoteUrl.absoluteString],
			  let localUrlPath = entry.localFileURL,
			  entry.canBeLoadedFromLocalVersion
		else {
			completion(nil, nil)
			return
		}
		
		let urlAsset = AVURLAsset(url: URL(fileURLWithPath: localUrlPath))
		let item = AVPlayerItem(asset: urlAsset)
		let queuePlayer = AVQueuePlayer(playerItem: item)
		let playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
		
		Self.downloadsQueue[remoteUrl.absoluteString] = (
			nil,
			nil,
			queuePlayer,
			playerLooper,
			localUrlPath,
			true,
			nil
		)
		
		completion(Self.downloadsQueue[remoteUrl.absoluteString]?.player, Self.downloadsQueue[remoteUrl.absoluteString]?.looper)
	}
	
	private func createPlayerForRemoteMedia(from url: URL, reload: @escaping (AVQueuePlayer?, AVPlayerLooper?) -> Void) {
		let loaderDelegate = AssetLoaderDelegate(withURL: url)
		
		guard let streamingAssetURL = loaderDelegate.streamingAssetURL
		else { return }
		
		let mediaAsset = AVURLAsset(url: streamingAssetURL)
		mediaAsset.resourceLoader.setDelegate(loaderDelegate, queue: .main)
		
		loaderDelegate.completion = { localFileURL in
			if let localFileURL {
				Self.downloadsQueue[url.absoluteString]?.localFileURL = localFileURL.absoluteString
				
				let notificationToken = NotificationCenter.default.addObserver(
					forName: .AVPlayerItemDidPlayToEndTime,
					object: nil,
					queue: .main
				) { notification in
					
					if let item = notification.object as? AVPlayerItem,
					   let asset = item.asset as? AVURLAsset,
					   Self.downloadsQueue[url.absoluteString]?.assetUrlPath == asset.url.absoluteString {
						defer {
							if let notificationToken = Self.downloadsQueue[url.absoluteString]?.notificationToken {
								NotificationCenter.default.removeObserver(notificationToken)
							}
						}
						
						// need reload to local file after item playing end
						Self.downloadsQueue[url.absoluteString]?.canBeLoadedFromLocalVersion = true
						
						self.createPlayerForLocalMedia(for: url, completion: reload)
					}
				}
				
				Self.downloadsQueue[url.absoluteString]?.notificationToken = notificationToken
				
			} else {
				print("failed to download media file.")
			}
		}
		
		let item = AVPlayerItem(asset: mediaAsset)
		let queuePlayer = AVQueuePlayer(playerItem: item)
		let playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
		
		Self.downloadsQueue[url.absoluteString] = (
			streamingAssetURL.absoluteString,
			loaderDelegate,
			queuePlayer,
			playerLooper,
			nil,
			false,
			nil
		)
		
		reload(Self.downloadsQueue[url.absoluteString]?.player, Self.downloadsQueue[url.absoluteString]?.looper)
	}
}
