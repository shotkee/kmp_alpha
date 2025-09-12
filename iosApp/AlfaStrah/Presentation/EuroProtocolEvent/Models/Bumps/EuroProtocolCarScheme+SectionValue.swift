//
//  EuroProtocolCarScheme+SectionValue.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 07.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// TODO: Remove this file when SDK is updated accordingly
extension EuroProtocolCarScheme {
    init?(sectionValue value: String) {
        switch value {
            case "1":
                self = .pos_1
            case "2":
                self = .pos_2
            case "3":
                self = .pos_3
            case "4":
                self = .pos_4
            case "5":
                self = .pos_5
            case "6":
                self = .pos_6
            case "7":
                self = .pos_7
            case "8":
                self = .pos_8
            case "9":
                self = .pos_9
            case "10":
                self = .pos_10
            case "11":
                self = .pos_11
            case "12":
                self = .pos_12
            case "13":
                self = .pos_13
            case "14":
                self = .pos_14
            case "1-2":
                self = .pos_1_2
            case "2-3":
                self = .pos_2_3
            case "3-4":
                self = .pos_3_4
            case "4-5":
                self = .pos_4_5
            case "5-6":
                self = .pos_5_6
            case "6-7":
                self = .pos_6_7
            case "7-8":
                self = .pos_7_8
            case "8-9":
                self = .pos_8_9
            case "9-10":
                self = .pos_9_10
            case "10-11":
                self = .pos_10_11
            case "11-12":
                self = .pos_11_12
            case "12-13":
                self = .pos_12_13
            case "13-14":
                self = .pos_13_14
            case "14-1":
                self = .pos_14_1
            default:
                return nil
        }
    }
}
