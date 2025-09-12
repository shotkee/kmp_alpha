//
//  VerticalCustomRadioButtonWidgetView.swift
//  AlfaStrah
//
//  Created by vit on 15.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class VerticalCustomRadioButtonWidgetView: WidgetView<VerticalCustomRadioButtonWidgetDTO> {
		private let contentStackView = UIStackView()
		
		required init(
			block: VerticalCustomRadioButtonWidgetDTO,
			horizontalInset: CGFloat = 18,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupUI() {
			addSubview(contentStackView)
			contentStackView.isLayoutMarginsRelativeArrangement = true
			contentStackView.layoutMargins = .zero
			contentStackView.alignment = .fill
			contentStackView.distribution = .fill
			contentStackView.axis = .vertical
			contentStackView.spacing = 0
			contentStackView.backgroundColor = .clear
			
			contentStackView.edgesToSuperview()
			contentStackView.width(to: self)
			
			updateTheme()
		}
		
		private func widgetEntry(for stateContainer: StateContainerComponentDTO) -> ViewBuilder.WidgetEntry? {
			return stateContainer.isActive
			?  	ViewBuilder.constructWidgetEntry(
				for: stateContainer.activeStateWidget,
				indexFormData: false,
				horizontalLayoutOneSideContentInset: self.horizontalInset,
				handleEvent: { events in
					self.handleEvent?(events)
				}
			)
			: ViewBuilder.constructWidgetEntry(
				for: stateContainer.nonActiveStateWidget,
				indexFormData: false,
				horizontalLayoutOneSideContentInset: self.horizontalInset,
				handleEvent: { events in
					self.handleEvent?(events)
				}
			)
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			updateSelection(selectedContainer: nil, themeUpdate: true)
		}
		
		private func updateSelection(selectedContainer: StateContainerComponentDTO?, themeUpdate: Bool) {
			contentStackView.subviews.forEach({ $0.removeFromSuperview() })
			buttons.removeAll()
			
			if let items = block.items {
				for (index, stateContainer) in items.enumerated() {
					let widgetEntry = widgetEntry(for: stateContainer)
					
					if !themeUpdate, stateContainer === selectedContainer {
						let formDataValue = stateContainer.isActive ? widgetEntry?.widget.formData?.value : nil
						self.replaceFormData(with: formDataValue)
					}
					
					if let widgetView = widgetEntry?.view {
						let button = UIButton()
						button.addTarget(self, action: #selector(clicked(_:)), for: .touchUpInside)
						buttons.append((button, { [weak self] in
							stateContainer.isActive.toggle()
							
							self?.updateSelection(selectedContainer: stateContainer, themeUpdate: false)
						}))
						
						widgetView.addSubview(button)
						button.edgesToSuperview()
						
						contentStackView.addArrangedSubview(widgetView)
						
						if index != items.count - 1,
						   let paddingVerical = block.paddingVertical,
						   paddingVerical != 0 {
							contentStackView.addArrangedSubview(spacer(paddingVerical))
						}
					}
				}
			}
		}
		
		private var buttons: [(UIButton, (() -> Void)?)] = []
		
		@objc func clicked(_ sender: UIButton) {
			if let buttonEntry = buttons.first(where: { $0.0 === sender }) {
				buttonEntry.1?()
			}
		}
	}
}
