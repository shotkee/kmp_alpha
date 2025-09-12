//
//  TextButtonArrowWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 22.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TextButtonArrowWidgetDTO: WidgetDTO {
		enum Key: String {
			case title = "title"
			case titleIcon = "titleIcon"
			case circle = "circle"
			case rightTopInfo = "rightTopInfo"
			case rightTopIcon = "rightTopIcon"
			case lines = "lines"
			case arrow = "arrow"
			case buttons = "buttons"
			case bottomButtons = "bottomButtons"
		}
		
		let themedTitle: ThemedTextComponentDTO?
		let themedTitleIcon: ThemedValueComponentDTO?
		let themedRightTopInfo: ThemedTextComponentDTO?
		let rightTopIcon: RightTopIconComponentDTO?
		let textRows: [СopyableThemedTextComponentDTO]?
		let arrow: ArrowComponentDTO?
		let menuButtons: [SquaredButtonWidgetDTO]?
		let actionButtons: [WidgetDTO]?
		
		required init(body: [String: Any]) {
			self.themedTitle = Self.instantinate(Key.title, body)
			self.themedTitleIcon = Self.instantinate(Key.titleIcon, body)
			self.themedRightTopInfo = Self.instantinate(Key.rightTopInfo, body)
			self.rightTopIcon = Self.instantinate(Key.rightTopIcon, body)
			self.textRows = Self.instantinate(Key.lines, body)
			self.arrow = Self.instantinate(Key.arrow, body)
			self.menuButtons = Self.instantinate(Key.buttons, body)
			self.actionButtons = Self.instantinate(Key.bottomButtons, body)
			
			super.init(body: body)
		}
	}
}
