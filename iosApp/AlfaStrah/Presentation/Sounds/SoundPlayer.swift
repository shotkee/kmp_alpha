//
//  SoundPlayer.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 27/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Foundation

@objc protocol SoundPlayer: AnyObject {
    func play(sound name: String)
}
