//
//  ISODateInRegionTransformer.swift
//  AlfaStrah
//
//  Created by vit on 26.04.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy
import SwiftDate

public struct ISODateInRegionTransofrmer<From>: Transformer {
    public typealias Source = From
    public typealias Destination = DateInRegion

    public func transform(source value: Source) -> TransformerResult<Destination> {
        guard let timestamp = value as? String
        else { return .failure(.transform) }
        
        return TransformerResult(timestamp.toISODate(), .transform)
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        return TransformerResult( value.toString() as? From, .transform)
    }
}
