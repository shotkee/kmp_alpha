//
//  SingleParameterTransformer.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 07/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

struct SingleParameterTransformer<ContentTransformer: Transformer>: Transformer where ContentTransformer.Source == Any {
    public typealias Source = Any
    public typealias Destination = ContentTransformer.Destination

    private let key: String
    private let transformer: ContentTransformer

    init(key: String, transformer: ContentTransformer) {
        self.key = key
        self.transformer = transformer
    }

    public func transform(source value: Source) -> TransformerResult<Destination> {
        guard let source = value as? [String: Any] else { return .failure(.source) }
        guard let data = source[key] else { return .failure(.transform) }

        return transformer.transform(source: data)
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        switch transformer.transform(destination: value) {
            case .success(let result):
                let destination: [String: Any] = [ key: result ]
                return .success(destination)
            case .failure(let error):
                return .failure(error)
        }
    }
}
