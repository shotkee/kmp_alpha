//
//  EuroProtocolBikeScheme+ViewTag.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 06.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

extension EuroProtocolBikeScheme {
    init?(viewTags tags: [Int]) {
        guard let tag = tags.first, tags.count == 1 else {
            return nil
        }

        switch tag {
            case 1:
                self = .pos_1
            case 2:
                self = .pos_2
            case 3:
                self = .pos_3
            case 4:
                self = .pos_4
            default:
                return nil
        }
    }

    var viewTags: [Int] {
        switch self {
            case .pos_1:
                return [ 1 ]
            case .pos_2:
                return [ 2 ]
            case .pos_3:
                return [ 3 ]
            case .pos_4:
                return [ 4 ]
        }
    }
}
