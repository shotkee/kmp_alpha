//
//  ObjectId
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 29/10/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

struct ObjectId: Codable, Hashable {
    let value: String

    init(_ id: String) {
        value = id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            let intId = try container.decode(Int64.self)
            value = "\(intId)"
        } catch DecodingError.typeMismatch {
            value = try container.decode(String.self)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
