//
//  OptionalTransformer.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 10.03.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Legacy

struct OptionalTransformer<ValueTransformer: Transformer>: Transformer {
    public typealias Source = ValueTransformer.Source?
    public typealias Destination = ValueTransformer.Destination?

    private let transformer: ValueTransformer

    public init(transformer: ValueTransformer) {
        self.transformer = transformer
    }

    public func transform(source value: Source) -> TransformerResult<Destination> {
        if let value = value, !(value is NSNull) {
            // swiftlint:disable:next array_init
            return transformer.transform(source: value).map { $0 }.flatMapError { _ in TransformerResult<Destination>.success(nil) }
        } else {
            return .success(nil)
        }
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        if let value = value {
            // swiftlint:disable:next array_init
            return transformer.transform(destination: value).map { $0 }
        } else {
            return .success(nil)
        }
    }
}
