//
//  EuroProtocolCarScheme+ViewTag.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 05.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

extension EuroProtocolCarScheme {
    init?(viewTags tags: [Int]) {
        guard tags.count <= 2, !tags.isEmpty else { return nil }

        if tags.count == 1, let tag = tags.first {
            switch tag {
                case 1:
                    self = .pos_1
                case 2:
                    self = .pos_2
                case 3:
                    self = .pos_3
                case 4:
                    self = .pos_4
                case 5:
                    self = .pos_5
                case 6:
                    self = .pos_6
                case 7:
                    self = .pos_7
                case 8:
                    self = .pos_8
                case 9:
                    self = .pos_9
                case 10:
                    self = .pos_10
                case 11:
                    self = .pos_11
                case 12:
                    self = .pos_12
                case 13:
                    self = .pos_13
                case 14:
                    self = .pos_14
                default:
                    return nil
            }

            return
        }

        switch (tags[0], tags[1]) {
            case (1, 2):
                self = .pos_1_2
            case (2, 3):
                self = .pos_2_3
            case (3, 4):
                self = .pos_3_4
            case (4, 5):
                self = .pos_4_5
            case (5, 6):
                self = .pos_5_6
            case (6, 7):
                self = .pos_6_7
            case (7, 8):
                self = .pos_7_8
            case (8, 9):
                self = .pos_8_9
            case (9, 10):
                self = .pos_9_10
            case (10, 11):
                self = .pos_10_11
            case (11, 12):
                self = .pos_11_12
            case (12, 13):
                self = .pos_12_13
            case (13, 14):
                self = .pos_13_14
            case (1, 14):
                self = .pos_14_1
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
            case .pos_5:
                return [ 5 ]
            case .pos_6:
                return [ 6 ]
            case .pos_7:
                return [ 7 ]
            case .pos_8:
                return [ 8 ]
            case .pos_9:
                return [ 9 ]
            case .pos_10:
                return [ 10 ]
            case .pos_11:
                return [ 11 ]
            case .pos_12:
                return [ 12 ]
            case .pos_13:
                return [ 13 ]
            case .pos_14:
                return [ 14 ]
            case .pos_1_2:
                return [ 1, 2 ]
            case .pos_2_3:
                return [ 2, 3 ]
            case .pos_3_4:
                return [ 3, 4 ]
            case .pos_4_5:
                return [ 4, 5 ]
            case .pos_5_6:
                return [ 5, 6 ]
            case .pos_6_7:
                return [ 6, 7 ]
            case .pos_7_8:
                return [ 7, 8 ]
            case .pos_8_9:
                return [ 8, 9 ]
            case .pos_9_10:
                return [ 9, 10 ]
            case .pos_10_11:
                return [ 10, 11 ]
            case .pos_11_12:
                return [ 11, 12 ]
            case .pos_12_13:
                return [ 12, 13 ]
            case .pos_13_14:
                return [ 13, 14 ]
            case .pos_14_1:
                return [ 1, 14 ]
        }
    }
}
