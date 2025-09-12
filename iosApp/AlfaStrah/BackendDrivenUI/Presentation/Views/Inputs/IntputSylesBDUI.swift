//
//  IntputStylesBDUI.swift
//  AlfaStrah
//
//  Created by vit on 25.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

struct InputAppearanceBDUI {
	let borderColor: BDUI.ThemedValueComponentDTO?
	let fontColor: BDUI.ThemedValueComponentDTO?
	let backgroundColor: BDUI.ThemedValueComponentDTO?
}

struct InputStylesBDUI {
	let abandoned: InputAppearanceBDUI
	let selected: InputAppearanceBDUI
	let error: InputAppearanceBDUI
	let accessoryThemedColor: BDUI.ThemedValueComponentDTO?
}

enum AppearanceTypeBDUI {
	case abandoned
	case selected
	case error
}

protocol TextInputBDUI: UITextField {
	var appearanceType: AppearanceTypeBDUI { get set }
	var floatingLabelAttributedText: NSAttributedString? { get set }
}
