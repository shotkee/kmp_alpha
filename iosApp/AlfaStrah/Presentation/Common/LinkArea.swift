//
//  LinkArea.swift
//  AlfaStrah
//
//  Created by vit on 05.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

struct LinkArea {
    private let id = UUID().uuidString
    let text: String
    let link: URL?
    let tapHandler: (_ url: URL?) -> Void

    var absoluteString: String {
        link?.absoluteString ?? id
    }
}
