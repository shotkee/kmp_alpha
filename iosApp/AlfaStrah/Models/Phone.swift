//
//  Phone.swift
//  AlfaStrah
//
//  Created by Станислав Старжевский on 11.12.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

// sourcery: transformer
struct Phone: Entity, Equatable {
    var plain: String
    // sourcery: transformer.name = "human_readable"
    var humanReadable: String
    // sourcery: transformer.name = "internet_call"
    var voipCall: VoipCall?
    
    init(plain: String, humanReadable: String, voipCall: VoipCall? = nil) {
        self.plain = plain
        self.humanReadable = humanReadable
        self.voipCall = voipCall
    }
}
