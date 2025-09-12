//
// ResponseTransformer
// AlfaStrah
//
// Created by Eugene Egorov on 22 November 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import Legacy

struct ResponseTransformer<ContentTransformer: Transformer>: Transformer where ContentTransformer.Source == Any {
    public typealias Source = Any
    public typealias Destination = ContentTransformer.Destination

    private let key: String?
    private let transformer: ContentTransformer

    init(key: String? = nil, transformer: ContentTransformer) {
        self.key = key
        self.transformer = transformer
    }

    public func transform(source value: Source) -> TransformerResult<Destination> {
        guard let source = value as? [String: Any] else { return .failure(.source) }
        guard var data = source["data"] else { return .failure(.transform) }

        if let key = key {
            guard let keyedData = (data as? [String: Any])?[key] else { return .failure(.transform) }

            data = keyedData
        }

        return transformer.transform(source: data)
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        switch transformer.transform(destination: value) {
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
