//
//  EuroProtocolBikeScheme+SectionValue.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 07.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// TODO: Remove this file when SDK is updated accordingly
extension EuroProtocolBikeScheme {
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
            default:
                return nil
        }
    }
}
