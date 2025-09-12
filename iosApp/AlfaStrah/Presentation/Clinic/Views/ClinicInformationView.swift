//
//  ClinicInformationView.swift
//  AlfaStrah
//
//  Created by Makson on 08.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import UIKit
import TinyConstraints

class ClinicInformationView: UIView,
							 UICollectionViewDelegate,
							 UICollectionViewDataSource,
							 UICollectionViewDelegateFlowLayout {
	// MARK: - Outlets
	private let stackView = createStackView()
	private let nameLabel = createNameLabel()
	private let addressContainerView = UIView()
	private let addressLabel = createAddressLabel()
	private let copyButton = RoundEdgeButton()
	private let containerCollectionView = UIView()
	private var tagCollectionViewHeightConstraint: NSLayoutConstraint?
	private lazy var collectionView: UICollectionView = {
		let value: UICollectionView = .init(frame: .zero, collectionViewLayout: collectionLayout)
		value.backgroundColor = .clear
		value.delegate = self
		value.dataSource = self
		value.showsHorizontalScrollIndicator = false
		value.showsVerticalScrollIndicator = false
		value.isScrollEnabled = false
		value.isUserInteractionEnabled = false
		value.registerReusableCell(ClinicMetroCollectionViewCell.id)
		
		return value
	}()
	
	private lazy var collectionLayout: UICollectionViewFlowLayout = {
		let value: TagsLayout = .init()
		return value
	}()
	
	private var clinic: Clinic
	
	init(clinic: Clinic)
	{
		self.clinic = clinic
		super.init(frame: .zero)
		
		buildUI()
	}
	
	required init?(coder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}
}

private extension ClinicInformationView
{
	static func createStackView() -> UIStackView
	{
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 4
		
		return stackView
	}
	
	static func createNameLabel() -> UILabel
	{
		let label = UILabel()
		label <~ Style.Label.primaryHeadline1
		label.numberOfLines = 0
		
		return label
	}
	
	static func createAddressLabel() -> UILabel
	{
		let label = UILabel()
		label <~ Style.Label.secondaryText
		label.numberOfLines = 0
		
		return label
	}
	
	func buildUI()
	{
		self.addSubview(stackView)
		stackView.edgesToSuperview()
		setupTagViews(labelList: clinic.labelList ?? [])
		setupSpacerView()
		setupNameLabel()
		setupCopyButton()
		setupAddressContainerView()
		setupOpeningHoursLabel(serviceHours: clinic.serviceHours)
		if !(clinic.metroList ?? []).isEmpty
		{
			setupSpacerView()
		}
		setupCollectionView(metroList: clinic.metroList ?? [])
	}
	
	func setupTagViews(labelList: [ClinicLabelList])
	{
		labelList.forEach
		{
			stackView.addArrangedSubview(
				createTagView(clinicLabelList: $0)
			)
		}
	}
	
	func createTagView(clinicLabelList: ClinicLabelList) -> UIView
	{
		let view = UIView()
		
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 4
		view.addSubview(stackView)
		stackView.edgesToSuperview()
		
		let colorContainerView = UIView()
		let colorView = UIView()
		colorView.backgroundColor = clinicLabelList.color.color(
			for: traitCollection.userInterfaceStyle
		)
		colorView.height(8)
		colorView.widthToHeight(of: colorView)
		colorView.clipsToBounds = true
		colorView.layer.cornerRadius = 4
		colorContainerView.addSubview(colorView)
		colorView.horizontalToSuperview()
		colorView.centerYToSuperview()
		stackView.addArrangedSubview(colorContainerView)
		
		let label = UILabel()
		label.text = clinicLabelList.title
		label <~ Style.Label.secondarySubhead
		label.numberOfLines = 1
		stackView.addArrangedSubview(label)
		
		return view
	}
	
	func setupSpacerView()
	{
		let spacerView = UIView()
		spacerView.height(4)
		stackView.addArrangedSubview(spacerView)
	}
	
	func setupNameLabel()
	{
		nameLabel.text = clinic.title
		stackView.addArrangedSubview(nameLabel)
	}
	
	func setupCopyButton()
	{
		copyButton <~ Style.RoundedButton.primaryButtonSmallWithoutBorder
		copyButton.setImage(
			.Icons.grayCopy
				.resized(newWidth: 12)?,
			for: .normal
		)
		copyButton.contentEdgeInsets = UIEdgeInsets(
			top: 2,
			left: 2.75,
			bottom: 2,
			right: 2.75
		)
		copyButton.width(16)
		copyButton.heightToWidth(of: copyButton)
		
		copyButton.addTarget(self, action: #selector(tapCopyButton), for: .touchUpInside)
	}
	
	@objc func tapCopyButton()
	{
		UIPasteboard.general.string = clinic.address
		
		showStateInfoBanner(
			title: NSLocalizedString("common_copied", comment: ""),
			description: "",
			hasCloseButton: false,
			iconImage: .Icons.tick
				.tintedImage(withColor: .Icons.iconAccent)
				.withAlignmentRectInsets(insets(-4)),
			titleFont: Style.Font.text,
			appearance: .standard
		)
	}
	
	func setupAddressContainerView()
	{
		addressContainerView.backgroundColor = .clear
		addressLabel.text = clinic.address
		addressContainerView.addSubview(addressLabel)
		addressLabel.edgesToSuperview(excluding: .trailing)
		addressContainerView.addSubview(copyButton)
		copyButton.size(.init(width: 16, height: 16))
		copyButton.centerYToSuperview()
		copyButton.leadingToTrailing(
			of: addressLabel,
			offset: 4
		)
		copyButton.trailingToSuperview(relation: .equalOrLess)
		stackView.addArrangedSubview(addressContainerView)
		let tap = UITapGestureRecognizer(
			target: self,
			action: #selector(tapCopyButton)
		)
		addressContainerView.addGestureRecognizer(tap)
	}
	
	func setupOpeningHoursLabel(serviceHours: String)
	{
		stackView.addArrangedSubview(
			createOpeningHoursLabel(text: serviceHours)
		)
	}
	
	func createOpeningHoursLabel(text: String) -> UILabel
	{
		let label = UILabel()
		label.text = text
		label <~ Style.Label.primaryCaption1
		label.numberOfLines = 1
		
		return label
	}
	
	func setupCollectionView(metroList: [ClinicMetro])
	{
		containerCollectionView.addSubview(collectionView)
		collectionView.edgesToSuperview()
		let heightConstraint = collectionView.height(20)
		tagCollectionViewHeightConstraint = heightConstraint
		stackView.addArrangedSubview(containerCollectionView)
		containerCollectionView.isHidden = metroList.isEmpty
		tagCollectionViewHeightConstraint?.constant = getHeightCollectionView(
			metroList: metroList
		)
	}
	
	private func getHeightCollectionView(metroList: [ClinicMetro]) -> CGFloat {
		var height: CGFloat = Constants.tagViewHeight
		var collectionViewWidth = Constants.defaultWidthCollection
		let spaceBetweenSection: CGFloat = 4
		let spaceBetweenCell = spaceBetweenSection
		var countSection: Int = 1
		
		metroList.forEach { metro in
			let widthTag = metro.title.width(
				withConstrainedHeight: 15,
				font: Style.Font.text
			)
			
			let remainderWidthCell = collectionViewWidth - (spaceBetweenCell * CGFloat(countSection)) - widthTag
			
			if remainderWidthCell > 0 {
				collectionViewWidth = remainderWidthCell
				countSection += 1
			}
			else {
				countSection = countSection == 1 ? countSection + 1 : countSection
				height += Constants.tagViewHeight + spaceBetweenSection
				collectionViewWidth = Constants.defaultWidthCollection - widthTag - (spaceBetweenCell * CGFloat(countSection))
				countSection = 1
			}
		}
		
		return height + spaceBetweenSection
	}
}

extension ClinicInformationView
{
	// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		(clinic.metroList ?? []).count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
	{
		let cell = collectionView.dequeueReusableCell(
			ClinicMetroCollectionViewCell.id,
			indexPath: indexPath
		)
		
		cell.setup(
			metro: (clinic.metroList ?? [])[indexPath.item]
		)

		return cell
	}
	
	struct Constants {
		static let tagViewHeight: CGFloat = 20
		static let widthScreen = UIScreen.main.bounds.width
		static let defaultWidthCollection: CGFloat = widthScreen - 66
	}
}
