//
//  ResponseWithInfoMessageTransformer.swift
//  AlfaStrah
//
//  Created by vit on 18.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Legacy

struct ResponseWithInfoMessageTransformer<ContentTransformer: Transformer>: Transformer where ContentTransformer.Source == Any {
	public typealias Source = Any
	public typealias Destination = (content: ContentTransformer.Destination, infoMessage: InfoMessage?)
	
	private let key: String?
	private let transformer: ContentTransformer
	
	init(key: String? = nil, transformer: ContentTransformer) {
		self.key = key
		self.transformer = transformer
	}
	
	public func transform(source value: Source) -> TransformerResult<Destination> {
		guard let source = value as? [String: Any] else { return .failure(.source) }
		guard var data = source["data"] else { return .failure(.transform) }
		
		var infoMessage: InfoMessage?
		
		if let key = key {
			guard let keyedData = (data as? [String: Any])?[key]
			else { return .failure(.transform) }
			
			if let info = (keyedData as? [String: Any])?["info_message"] {
				if let value = InfoMessageTransformer().transform(source: info).value {
					infoMessage = value
				}
			}
			
			data = keyedData
		}
		
		if let value = transformer.transform(source: data).value {
			return .success((value, infoMessage))
		} else {
			return .failure(.transform)
		}
	}
	
	public func transform(destination value: Destination) -> TransformerResult<Source> {
		switch (transformer.transform(destination: value.0)) {
			case .success(let result):
				let destination: [String: Any]
				if let key = key {
					destination = [ "data": [ key: result ] ]
				} else {
					destination = [ "data": result ]
				}
				
				return .success(destination)
				
			case .failure(let error):
				return .failure(error)
				
		}
	}
}
