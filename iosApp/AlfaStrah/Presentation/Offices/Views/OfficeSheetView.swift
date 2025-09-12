//
//  OfficeSheetView.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 01.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

final class OfficeSheetView: UIView {
    // Constants
    private enum Constants {
        static let rootStackViewInsets: UIEdgeInsets = .init(top: 20, left: 18, bottom: 0, right: 18)
        static var metroIcon: UIImage? = .Icons.metro.tintedImage(withColor: .Icons.iconSecondary)
        static var timeIcon: UIImage? = .Icons.clock.tintedImage(withColor: .Icons.iconSecondary)
        static let separatorColor: UIColor = .Stroke.divider
        static let separatorSize: CGSize = .init(width: 1, height: 12)
        static let addressStackViewSpacing: CGFloat = 4
        static let kmText = NSLocalizedString("common_distance_unit_km_to", comment: "")
        static let mText = NSLocalizedString("common_distance_unit_m_to", comment: "")
        static let metroStackViewSpacing: CGFloat = 12
        static let iconImageSize: CGSize = .init(width: 20, height: 20)
        static let timeStackViewSpacing: CGFloat = 12
    }

    private enum Styles {
        static let addressLabelStyle = Style.Label.primaryHeadline1
        static let distanceLabelStyle = Style.Label.secondaryText
        static let metroLabelStyle = Style.Label.secondaryText
        static let workTimeLabelStyle = Style.Label.primaryText
        static let headerStyle = Style.Label.primaryHeadline1
    }

    // Views
    
    private lazy var metroImageView: UIImageView = {
        let imageView: UIImageView = .init(frame: .zero)
        imageView.accessibilityIdentifier = #function
        imageView.image = Constants.metroIcon ?? UIImage()
        imageView.contentMode = .center
        imageView.backgroundColor = .clear
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        return imageView
    }()
    
    private lazy var timeImageView: UIImageView = {
        let imageView: UIImageView = .init(frame: .zero)
        imageView.accessibilityIdentifier = #function
        imageView.image = Constants.timeIcon ?? UIImage()
        imageView.contentMode = .center
        imageView.backgroundColor = .clear
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        return imageView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.Icons.cross, for: .normal)
        button.tintColor = .Icons.iconAccentThemed
        button.addTarget(
            self,
            action: #selector(onCloseButton),
            for: .touchUpInside
        )
        return button
    }()
    
    @objc private func onCloseButton() {
        onClose?()
    }
    
    private lazy var routeButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(onRouteButton), for: .touchUpInside)
        button.setTitle(NSLocalizedString("office_action_route", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldPrimaryButtonSmall
        return button
    }()
    
    @objc private func onRouteButton() {
        onRoute?()
    }
    
    private lazy var detailsButton: RoundEdgeButton = {
        let button: RoundEdgeButton = .init(frame: .zero)
        button.addTarget(self, action: #selector(onDetailsButton), for: .touchUpInside)
        button.setTitle(NSLocalizedString("common_details", comment: ""), for: .normal)
        button <~ Style.RoundedButton.oldOutlinedButtonSmall
        return button
    }()
    
    @objc private func onDetailsButton() {
        onDetails?()
    }
    
    // Stacks

    private lazy var rootStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.backgroundColor = .clear
        stack.accessibilityIdentifier = #function
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 16
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = Constants.rootStackViewInsets
        return stack
    }()
    
    private lazy var topStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.accessibilityIdentifier = #function
        stack.axis = .horizontal
        stack.alignment = .top
        stack.spacing = 12
        return stack
    }()
    
    private lazy var addressStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.accessibilityIdentifier = #function
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = Constants.addressStackViewSpacing
        return stack
    }()

    private lazy var metroStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.accessibilityIdentifier = #function
        stack.alignment = .top
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = Constants.metroStackViewSpacing
        return stack
    }()
    
    private lazy var metroStringsStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.accessibilityIdentifier = #function
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    private lazy var timeStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.accessibilityIdentifier = #function
        stack.axis = .horizontal
        stack.alignment = .top
        stack.distribution = .fill
        stack.spacing = Constants.timeStackViewSpacing
        return stack
    }()
    
    private lazy var timeStringsStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.accessibilityIdentifier = #function
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    private lazy var actionsButtonsStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.accessibilityIdentifier = #function
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    // Labels

    private lazy var addressLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.accessibilityIdentifier = #function
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private lazy var distanceLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.accessibilityIdentifier = #function
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var metroHeaderLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.text = NSLocalizedString("office_metro", comment: "")
        label.accessibilityIdentifier = #function
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var metroLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.accessibilityIdentifier = #function
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var workTimeHeaderLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.text = NSLocalizedString("info_open_hours", comment: "")
        label.accessibilityIdentifier = #function
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var workTimeLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.accessibilityIdentifier = #function
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    // MARK: Init

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }
    
    var onClose: (() -> Void)?
    var onRoute: (() -> Void)?
    var onDetails: (() -> Void)?
    
    // MARK: Builders

    private func setupUI() {
        clipsToBounds = false
        backgroundColor = .Background.backgroundContent
        
        addSubview(rootStackView)
        setupRootStack()
        
        addressLabel <~ Styles.addressLabelStyle
        distanceLabel <~ Styles.distanceLabelStyle
        metroHeaderLabel <~ Styles.headerStyle
        metroLabel <~ Styles.metroLabelStyle
        workTimeHeaderLabel <~ Styles.headerStyle
        workTimeLabel <~ Styles.workTimeLabelStyle
    }
    
    private func setupRootStack() {
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: rootStackView,
                in: self,
                margins: .init(
                    top: 0,
                    left: 0,
                    bottom: 15,
                    right: 0
                )
            )
        )
        
        rootStackView.addArrangedSubview(topStackView)
        setupTopStack()
        rootStackView.addArrangedSubview(metroStackView)
        setupMetroStack()
        rootStackView.addArrangedSubview(timeStackView)
        setupTimeStack()
        rootStackView.addArrangedSubview(actionsButtonsStackView)
        setupButtonsStack()
    }
    
    private func setupTopStack() {
        topStackView.addArrangedSubview(addressStackView)
        topStackView.addArrangedSubview(closeButton)
        setupAddressView()
    }
    
    private func setupAddressView() {
        addressStackView.bottomAnchor
            .constraint(equalTo: topStackView.bottomAnchor)
            .isActive = true
        
        addressStackView.addArrangedSubview(addressLabel)
        addressStackView.addArrangedSubview(distanceLabel)
    }

    private func setupMetroStack() {
        metroStackView.addArrangedSubview(metroImageView)
        metroStackView.addArrangedSubview(metroStringsStackView)
        setupMetroStringsStack()
        
        metroImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            metroImageView.heightAnchor.constraint(equalToConstant: Constants.iconImageSize.height),
            metroImageView.widthAnchor.constraint(equalToConstant: Constants.iconImageSize.width),
            metroStringsStackView.bottomAnchor.constraint(equalTo: metroStackView.bottomAnchor)
        ])
        rootStackView.setCustomSpacing(8, after: metroStackView)
    }
    
    private func setupMetroStringsStack() {
        metroStringsStackView.addArrangedSubview(metroHeaderLabel)
        metroStringsStackView.addArrangedSubview(metroLabel)
    }
    
    private func setupTimeStack() {
        timeStackView.addArrangedSubview(timeImageView)
        timeStackView.addArrangedSubview(timeStringsStackView)
        setupTimeStringsStack()
        
        timeImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeImageView.heightAnchor.constraint(equalToConstant: Constants.iconImageSize.height),
            timeImageView.widthAnchor.constraint(equalToConstant: Constants.iconImageSize.width),
            timeStringsStackView.bottomAnchor.constraint(equalTo: timeStackView.bottomAnchor)
        ])
    }
    
    private func setupTimeStringsStack() {
        timeStringsStackView.addArrangedSubview(workTimeHeaderLabel)
        timeStringsStackView.addArrangedSubview(workTimeLabel)
    }
    
    private func setupButtonsStack() {
        actionsButtonsStackView.addArrangedSubview(routeButton)
        actionsButtonsStackView.addArrangedSubview(detailsButton)
        
        rootStackView.setCustomSpacing(12, after: actionsButtonsStackView)
    }

    // MARK: Методы

    func set(
        address: String,
        distance: Double?,
        metros: [String]
    ) {
        addressLabel.text = TextHelper.html(from: address).string
        let distanceText = makeDistanceText(from: distance)
        distanceLabel.text = distanceText
        distanceLabel.isHidden = distanceText.isEmpty

        metroStackView.isHidden = metros.isEmpty
        metroLabel.text = metros.joined(separator: ", ")

        timeStackView.isHidden = true
    }

    func set(office: Office) {
        addressLabel.text = TextHelper.html(from: office.address).string
        distanceLabel.text = makeDistanceText(from: office.distance)

        if let metros = office.metro, !metros.isEmpty {
            metroStackView.isHidden = false
            metroLabel.text = metros.joined(separator: ", ")
        } else {
            metroStackView.isHidden = true
        }

        workTimeLabel.text = office.serviceHours
        
        layoutIfNeeded()
    }

    private func makeDistanceText(from distance: Double?) -> String {
        guard let officeDistance = distance else { return "" }

        return officeDistance / 1000 < 1
            ? String(format: Constants.mText, officeDistance.rounded())
            : String(format: Constants.kmText, (officeDistance / 1000).rounded())
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    
        let metroIconImage = Constants.metroIcon
        let timeIconImage = Constants.timeIcon
        
        Constants.metroIcon = metroIconImage?.tintedImage(withColor: .Icons.iconSecondary)
        Constants.timeIcon = timeIconImage?.tintedImage(withColor: .Icons.iconSecondary)
        
        routeButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        detailsButton <~ Style.RoundedButton.oldOutlinedButtonSmall
    }
}
