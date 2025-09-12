//
//  BottomWidgetsFooterView.swift
//  AlfaStrah
//
//  Created by vit on 10.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class BottomWidgetsFooterView: FooterView<BottomWidgetsFooterDTO> {
		private let actionButtonsStackView = UIStackView()
		
		private var actions: [(UIButton, EventsDTO?)] = []
		
		required init(
			block: BottomWidgetsFooterDTO,
			horizontalInset: CGFloat = 0,
			handleEvent: @escaping (EventsDTO) -> Void
		) {
			super.init(block: block, horizontalInset: horizontalInset, handleEvent: handleEvent)
			
			setupUI()
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		private func setupUI() {
			addSubview(actionButtonsStackView)
			
			actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
			actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
			actionButtonsStackView.alignment = .fill
			actionButtonsStackView.distribution = .fill
			actionButtonsStackView.axis = .vertical
			actionButtonsStackView.spacing = 0
			actionButtonsStackView.backgroundColor = .clear
			
			actionButtonsStackView.edgesToSuperview(excluding: .top)
			
			actionButtonsStackView.edgesToSuperview()
			
			updateTheme()
		}
		
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let currentUserInterfaceStyle = traitCollection.userInterfaceStyle
			
			backgroundColor = block.themedBackgroundColor?.color(for: currentUserInterfaceStyle)
			
			actionButtonsStackView.subviews.forEach({ $0.removeFromSuperview() })
			actions.removeAll()
			
			if let content = block.content {
				for component in content {
					if component.type == .widgetButton {
						if let buttonMarginTop = component.paddingTop {
							actionButtonsStackView.addArrangedSubview(spacer(buttonMarginTop))
						}
						let button = RoundEdgeButton()
						button.setTitle(component.themedTitle?.text, for: .normal)
						
						button <~ Style.RoundedButton.RoundedParameterizedButton(
							textColor: component.themedTitle?.themedColor?.color(for: currentUserInterfaceStyle),
							backgroundColor: component.themedBackgroundColor?.color(for: currentUserInterfaceStyle),
							borderColor: component.themedBorderColor?.color(for: currentUserInterfaceStyle)
						)
						
						button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
						
						button.height(48)
						
						actionButtonsStackView.addArrangedSubview(button)
						
						actions.append((button, component.events))
						
						if let buttonMarginBottom = component.paddingBottom {
							actionButtonsStackView.addArrangedSubview(spacer(buttonMarginBottom))
						}
					}
				}
			}
		}
		
		@objc func buttonAction(sender: UIButton) {
			guard let actionIndex = actions.firstIndex(where: { $0.0 == sender }),
				  let events = actions[actionIndex].1
			else { return }
			
			handleEvent(events)
		}
	}
}
