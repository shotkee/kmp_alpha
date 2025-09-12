//
//  CommonNoteProtocol.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 03.03.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

protocol CommonNoteProtocol {
    var currentText: String? { get }
    var isValid: Bool { get }

    func updateText(_ text: String)
    func validate()
}
