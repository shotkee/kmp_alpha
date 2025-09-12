//
//  ChoiceView.swift
//  AlfaStrah
//
//  Created by vit on 22.02.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import TinyConstraints

class ChoiceView: UIView {
	private let contentStackView = UIStackView()
	private let imageView = UIImageView()
	private let titleLabel = UILabel()
	private let checkbox = CommonCheckboxButton(appearance: .radiobutton)
	private var callback: ((_ selected: Bool) -> Void)?
	
	override init(frame: CGRect) {
		super.init(frame: frame)

		setupUI()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		setupUI()
	}
	
	private func setupUI() {
		setupContentStackView()
		setupImageView()
		contentStackView.addArrangedSubview(spacer(4))
		setupTitleLabel()
		setupCheckbox()
		setupTapGestureRecognizer()
	}
	
	private func setupTapGestureRecognizer() {
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
		addGestureRecognizer(tapGestureRecognizer)
	}
	
	@objc private func viewTap() {
		let state = checkbox.isSelected
		
		if !state {
			checkbox.isSelected = true
			callback?(checkbox.isSelected)
		}
	}
	
	func set() {
		checkbox.isSelected = true
	}
	
	func reset() {
		checkbox.isSelected = false
	}
	
	private func setupContentStackView() {
		addSubview(contentStackView)
		
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = .zero
		contentStackView.alignment = .fill
		contentStackView.distribution = .fill
		contentStackView.axis = .vertical
		contentStackView.spacing = 12
		contentStackView.backgroundColor = .clear
		contentStackView.isUserInteractionEnabled = false
				
		contentStackView.edgesToSuperview()
	}
	
	private func setupImageView() {
		contentStackView.addArrangedSubview(imageView)
	}
	
	private func setupTitleLabel() {
		titleLabel <~ Style.Label.primarySubhead
		titleLabel.numberOfLines = 0
		titleLabel.textAlignment = .center
		contentStackView.addArrangedSubview(titleLabel)
	}
	
	private func setupCheckbox() {
		checkbox.isUserInteractionEnabled = false
		contentStackView.addArrangedSubview(checkbox)
	}
	
	func configure(
		image: UIImage? = nil,
		title: String,
		appearance: Appearance = .radiobutton,
		callback: ((_ selected: Bool) -> Void)? = nil
	) {
		imageView.image = image
		titleLabel.text = title
		self.callback = callback
	}
	
	enum Appearance {
		case checkbox
		case radiobutton
	}
}
