//
//  Message+DisplayedText.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 03.02.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import Foundation

extension Message {
    func getDisplayedText() -> String {
        if let keyboard = getKeyboard() {
            if let responseButtonID = keyboard.getResponse()?.getButtonID(),
               let responseButton = keyboard.getButtons()
                    .flatMap({ $0 })
                    .first(where: { $0.getID() == responseButtonID }) {
                return responseButton.getText()
            } else {
                return ""
            }
        } else {
            return getText()
        }
    }
}
