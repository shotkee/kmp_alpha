//
//  JsonTransformer
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 24.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Foundation
import Legacy

struct JsonTransformer<From>: Transformer {
    public typealias Source = From
    public typealias Destination = Json

    public init() {}

    public func transform(source value: Source) -> TransformerResult<Destination> {
        TransformerResult(Json(value: value), .transform)
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        TransformerResult(value.value as? From, .transform)
    }
}
