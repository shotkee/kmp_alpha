//
//  MessageStubCell.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 27.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class MessageStubCell: MessageBubbleCell {
    static let reuseIdentifier: Reusable<MessageStubCell> = .class(id: "MyMessageStubCell")
    override func setup() {
        selectionStyle = .none
        contentView.subviews.forEach { $0.removeFromSuperview() }
    }

    override func layout() {
        add(constraints: [ heightAnchor.constraint(equalToConstant: 1) ])
    }

    override func staticStylize() {
    }

    override func dynamicStylize() {
    }
}
