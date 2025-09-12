//
//  DesinSystemColor.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 27.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

struct DesignSystemColor {
    let title: String
    let color: UIColor

    static let allPacks: [[DesignSystemColor]] = [
        [
            .init(title: "Red", color: Style.Color.Palette.red),
            .init(title: "DarkRed", color: Style.Color.Palette.darkRed)
        ],
        [
            .init(title: "Black", color: Style.Color.Palette.black)
        ],
        [
            .init(title: "DarkGray", color: Style.Color.Palette.darkGray)
        ],
        [
            .init(title: "LightGray", color: Style.Color.Palette.lightGray)
        ],
        [
            .init(title: "WhiteGray", color: Style.Color.Palette.whiteGray)
        ]
    ]
}
