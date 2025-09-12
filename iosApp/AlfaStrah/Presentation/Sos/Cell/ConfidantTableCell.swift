//
//  ConfidantTableCell.swift
//  AlfaStrah
//
//  Created by Makson on 02.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import TinyConstraints

class ConfidantTableCell: UITableViewCell
{
	static let id: Reusable<ConfidantTableCell> = .fromClass()
	
	// MARK: Outlets
	private lazy var containerView = createContainerView()
	private var stackView = UIStackView()
	private var confidantView = UIView()
	private var initialsLabel = UILabel()
	private var phoneLabel = UILabel()
	private var editButton = RoundEdgeButton()
	private var emptyConfidantView = UIView()
	private var confidantLabel = UILabel()
	private var confidantDescriptionLabel = UILabel()
	private let addButton = RoundEdgeButton()
	private let callButton = RoundEdgeButton()
	
	// MARK: - Variables
	private var tapEditCallback: ((Confidant) -> Void)?
	private var tapCallCallback: ((String) -> Void)?
	private var tapAddCallback: (() -> Void)?
	private var confidant: Confidant?
	private var confidantBanner: ConfidantBanner?
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
	{
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		setupUI()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI()
	{
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		setupContainerView()
		setupStackView()
		setupConfidantView()
		setupEmptyConfidantView()
		setupInitialsLabel()
		setupPhoneLabel()
		setupEditButton()
		setupConfidantLabel()
		setupConfidantDescriptionLabel()
		setupAddButton()
		setupCallButton()
	}
	
	private func setupContainerView()
	{
		contentView.addSubview(containerView)
		containerView.topToSuperview(offset: 2)
		containerView.horizontalToSuperview(insets: .horizontal(18))
		containerView.bottomToSuperview(offset: -20)
	}
	
	private func updateVisibleConfidantViewAndEmptyConfidantView(hasData: Bool)
	{
		addButton.isHidden = hasData
		callButton.isHidden = !hasData
		confidantView.isHidden = !hasData
		emptyConfidantView.isHidden = hasData
	}
	
	private func createContainerView() -> UIView
	{
		let view = UIView()
		view.backgroundColor = .Background.backgroundSecondary
		
		return view.embedded(hasShadow: true, cornerRadius: 16)
	}
	
	private func setupStackView()
	{
		stackView.spacing = 10
		stackView.axis = .vertical
		containerView.addSubview(stackView)
		stackView.edgesToSuperview(
			insets: .insets(16)
		)
	}
	
	private func setupConfidantView()
	{
		confidantView.backgroundColor = .clear
		stackView.addArrangedSubview(confidantView)
	}
	
	private func setupInitialsLabel()
	{
		initialsLabel <~ Style.Label.primaryHeadline1
		initialsLabel.numberOfLines = 2
		initialsLabel.textAlignment = .left
		confidantView.addSubview(initialsLabel)
		initialsLabel.topToSuperview()
		initialsLabel.leadingToSuperview()
	}
	
	private func setupPhoneLabel()
	{
		phoneLabel.numberOfLines = 1
		phoneLabel.textAlignment = .left
		phoneLabel <~ Style.Label.primaryHeadline1
		confidantView.addSubview(phoneLabel)
		phoneLabel.topToBottom(of: initialsLabel, offset: 4)
		phoneLabel.height(20)
		phoneLabel.horizontalToSuperview()
		phoneLabel.bottomToSuperview()
	}
	
	private func setupEditButton()
	{
		editButton <~ Style.RoundedButton.primaryButtonSmallWithoutBorder
		editButton.setTitle(
			NSLocalizedString("sos_confidant_edit_button", comment: ""),
			for: .normal
		)
		editButton.semanticContentAttribute = .forceRightToLeft
		editButton.setImage(
			.Icons.arrow
				.resized(newWidth: 15)?
				.tintedImage(withColor: .Icons.iconAccent),
			for: .normal
		)
		editButton.contentEdgeInsets = UIEdgeInsets(
			top: 3,
			left: 0,
			bottom: 2,
			right: 0
		)
		editButton.addTarget(self, action: #selector(editButtonTap), for: .touchUpInside)
		
		confidantView.addSubview(editButton)
		editButton.trailingToSuperview()
		editButton.topToSuperview()
		editButton.leftToRight(of: initialsLabel, relation: .equalOrGreater)
		editButton.height(17)
		editButton.width(110)
	}
	
	@objc func editButtonTap()
	{
		guard let confidant = self.confidant
		else { return }
		
		tapEditCallback?(confidant)
	}
	
	private func setupAddButton()
	{
		addButton <~ Style.RoundedButton.outlinedButtonLarge
		addButton.setTitle(
			NSLocalizedString("sos_confidant_add_button", comment: ""),
			for: .normal
		)
		addButton.addTarget(self, action: #selector(addButtonTap), for: .touchUpInside)
		stackView.addArrangedSubview(addButton)
		addButton.height(48)
	}
	
	@objc private func addButtonTap()
	{
		tapAddCallback?()
	}
	
	private func setupEmptyConfidantView()
	{
		emptyConfidantView.backgroundColor = .clear
		stackView.addArrangedSubview(emptyConfidantView)
	}
	
	private func setupConfidantLabel()
	{
		confidantLabel <~ Style.Label.primaryHeadline1
		confidantLabel.numberOfLines = 1
		confidantLabel.textAlignment = .left
		emptyConfidantView.addSubview(confidantLabel)
		confidantLabel.topToSuperview()
		confidantLabel.leadingToSuperview()
		confidantLabel.trailingToSuperview()
	}
	
	private func setupConfidantDescriptionLabel()
	{
		confidantDescriptionLabel.numberOfLines = 2
		confidantDescriptionLabel.textAlignment = .left
		confidantDescriptionLabel <~ Style.Label.secondarySubhead
		emptyConfidantView.addSubview(confidantDescriptionLabel)
		confidantDescriptionLabel.topToBottom(of: confidantLabel, offset: 4)
		confidantDescriptionLabel.horizontalToSuperview()
		confidantDescriptionLabel.bottomToSuperview()
	}
	
	private func setupCallButton()
	{
		callButton <~ Style.RoundedButton.primaryButtonLarge
		callButton.setTitle(
			NSLocalizedString("sos_confidant_call_button", comment: ""),
			for: .normal
		)
		callButton.addTarget(self, action: #selector(callButtonTap), for: .touchUpInside)
		stackView.addArrangedSubview(callButton)
		callButton.height(48)
	}
	
	@objc private func callButtonTap()
	{
		if let confidant = confidant
		{
			tapCallCallback?(confidant.phone.plain)
		}
	}
	
	func configure(
		confidant: Confidant?,
		confidantBanner: ConfidantBanner?,
		tapEditCallback: @escaping ((Confidant) -> Void),
		tapCallCallback: @escaping ((String) -> Void),
		tapAddCallback: @escaping (() -> Void)
	)
	{
		self.tapEditCallback = tapEditCallback
		self.tapCallCallback = tapCallCallback
		self.tapAddCallback = tapAddCallback
		self.confidant = confidant
		self.confidantBanner = confidantBanner
		self.updateUI(
			confidant: confidant,
			confidantBanner: confidantBanner
		)
	}
	
	private func updateUI(
		confidant: Confidant?,
		confidantBanner: ConfidantBanner?
	)
	{
		if let confidant = confidant
		{
			updateVisibleConfidantViewAndEmptyConfidantView(hasData: true)
			initialsLabel.text = confidant.name
			phoneLabel.text = confidant.phone.plain
		}
		else if let confidantBanner = confidantBanner
		{
			updateVisibleConfidantViewAndEmptyConfidantView(hasData: false)
			confidantLabel.text = confidantBanner.title
			confidantDescriptionLabel.text = confidantBanner.description
		}
	}
}
