//
//  WidgetView.swift
//  AlfaStrah
//
//  Created by vit on 29.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class WidgetView<T: WidgetDTO>: UIView, WidgetInitializable {
		let block: T
		let horizontalInset: CGFloat
		let handleEvent: ((EventsDTO) -> Void)?
		
		required init(
			block: T,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			self.block = block
			self.horizontalInset = horizontalInset
			self.handleEvent = handleEvent
			
			super.init(frame: .zero)
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		func replaceFormData(with data: Any?) {
			guard let formDataEntryName = block.formData?.name
			else { return }
			
			FormDataOperations.replaceFormData(for: block.events, with: data, action: self.handleEvent)
		}
	}
}
