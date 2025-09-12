//
//  SelectedInfoViewBDUI.swift
//  AlfaStrah
//
//  Created by vit on 13.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class SelectedListRowView: UIView {
		private lazy var rootStackView: UIStackView = {
			let value: UIStackView = .init(frame: .zero)
			value.alignment = .center
			value.axis = .horizontal
			value.spacing = 18
			return value
		}()
		
		private lazy var textLabel: UILabel = {
			let value: UILabel = .init(frame: .zero)
			value.textAlignment = .left
			value.numberOfLines = 0
			return value
		}()
		
		private lazy var selectedImageView: UIImageView = .init(frame: .zero)
		
		private lazy var separatorView: UIView = {
			let separator = UIView(frame: .zero)
			separator.backgroundColor = .Stroke.divider
			return separator
		}()
		
		var tapHandler: (() -> Void)?
		
		private var isSelected: Bool = false
		
		private var text: ThemedSizedTextComponentDTO?
		
		private var margins: UIEdgeInsets = .zero
		
		// MARK: Init
		
		required init?(coder: NSCoder) {
			super.init(coder: coder)
			
			commonSetup()
		}
		
		override init(frame: CGRect) {
			super.init(frame: frame)
			
			commonSetup()
		}
		
		private func commonSetup() {
			backgroundColor = .clear
			selectedImageView.contentMode = .center
			
			addSubview(rootStackView)
			addSubview(separatorView)
			
			rootStackView.addArrangedSubview(textLabel)
			rootStackView.addArrangedSubview(selectedImageView)
			
			separatorView.translatesAutoresizingMaskIntoConstraints = false
			rootStackView.translatesAutoresizingMaskIntoConstraints = false
			
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
			addGestureRecognizer(tapGestureRecognizer)
			
			rootStackView.edgesToSuperview()
			separatorView.edgesToSuperview(excluding: .top)
			separatorView.height(1)
			selectedImageView.height(24)
			selectedImageView.heightToWidth(of: selectedImageView)
			
			updateUI()
		}
		
		private func updateUI() {
			rootStackView.layoutMargins = margins
			
			selectedImageView.image = isSelected ? .Icons.tick
				.tintedImage(withColor: .Icons.iconAccent)
				.resized(newWidth: 22) : nil
		}
		
		func set(
			text: ThemedSizedTextComponentDTO?,
			isSelected: Bool,
			margins: UIEdgeInsets = .zero,
			showSeparator: Bool = false
		) {
			self.text = text
			self.margins = margins
			self.separatorView.isHidden = !showSeparator
			self.isSelected = isSelected
			
			updateUI()
			
			if let text {
				textLabel <~ BDUI.StyleExtension.Label(text, for: traitCollection.userInterfaceStyle)
			}
		}
		
		func update(isSelected: Bool) {
			self.isSelected = isSelected
			
			updateUI()
		}
		
		@objc private func viewTap() {
			tapHandler?()
			updateUI()
		}
		
		// MARK: - Dark Theme Support
		override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
			super.traitCollectionDidChange(previousTraitCollection)
			
			updateTheme()
		}
		
		private func updateTheme() {
			let image = selectedImageView.image
			
			selectedImageView.image = image?.tintedImage(withColor: .Icons.iconAccent)
			
			if let text {
				textLabel <~ BDUI.StyleExtension.Label(text, for: traitCollection.userInterfaceStyle)
			}
		}
	}
}
