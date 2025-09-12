//
// IdTransformer
// AlfaStrah
//
// Created by Eugene Egorov on 21 November 2018.
// Copyright (c) 2018 RedMadRobot. All rights reserved.
//

import Legacy

struct IdTransformer<From>: Transformer {
    public typealias Source = From
    public typealias Destination = String

    private let stringTransformer = CastTransformer<Source, Destination>()

    public func transform(source value: Source) -> TransformerResult<Destination> {
        guard let number = value as? NSNumber else { return stringTransformer.transform(source: value) }

        return TransformerResult(number.stringValue, .transform)
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        stringTransformer.transform(destination: value)
    }
}
