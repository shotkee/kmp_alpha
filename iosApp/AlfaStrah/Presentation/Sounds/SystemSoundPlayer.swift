//
//  SystemSoundPlayer.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 27/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import AudioToolbox

@objc class SystemSoundPlayer: NSObject, SoundPlayer {
    static private let defaultSystemSound: SystemSoundID = 1002
    private let defaultSound: SystemSoundID
    private var sounds: [String: SystemSoundID] = [:]

    @objc override init() {
        defaultSound = SystemSoundPlayer.load(sound: "bell") ?? SystemSoundPlayer.defaultSystemSound

        super.init()
    }

    func play(sound name: String) {
        var sound = sounds[name]
        if sound == nil {
            sound = SystemSoundPlayer.load(sound: name) ?? defaultSound
            sounds[name] = sound
        }

        if let sound = sound {
            AudioServicesPlaySystemSound(sound)
        }
    }

    static private func load(sound name: String) -> SystemSoundID? {
        let url = Bundle.main.url(forResource: name, withExtension: nil)
        let id = url.flatMap { url -> SystemSoundID? in
            var id: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(url as CFURL, &id)
            return id != 0 ? id : nil
        }
        return id
    }
}
