//
//  ClinicSheetView.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 15.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import TinyConstraints

class ClinicSheetView: UIView
{
    private let treatmentsLabel = createTreatmentsLabel()
    private let titleLabel = createTitleLabel()
    private let addressLabel = createAddressLabel()
    private let serviceHoursLabel = createServiceHoursLabel()
    
    var onClose: (() -> Void)?
    var onDetails: (() -> Void)?
    var onConfirmAppointment: (() -> Void)?
    
    private let detailsButton = RoundEdgeButton()
    private let confirmAppointmentButton = RoundEdgeButton()
    
    init()
    {
        super.init(frame: .zero)
        
        buildUI()
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func display(_ clinic: Clinic)
    {
		treatmentsLabel.text = clinic.serviceList.joined(separator: " / ")
        titleLabel.text = clinic.title
        addressLabel.text = clinic.address
        serviceHoursLabel.text = clinic.serviceHours
    }
    
    private func buildUI()
    {
        backgroundColor = .Background.backgroundContent
        
        let closeButton = createCloseButton()
        addSubview(closeButton)
        closeButton.topToSuperview(offset: 24)
        closeButton.trailingToSuperview(offset: 18)
        closeButton.setHugging(
            .required,
            for: .horizontal
        )
        closeButton.setCompressionResistance(
            .required,
            for: .horizontal
        )
        
        let topInfoStackView = UIStackView()
        topInfoStackView.axis = .vertical
        topInfoStackView.spacing = 8
        addSubview(topInfoStackView)
        topInfoStackView.topToSuperview(offset: 24)
        topInfoStackView.leadingToSuperview(offset: 18)
        topInfoStackView.trailingToLeading(of: closeButton)
        topInfoStackView.addArrangedSubview(treatmentsLabel)
        topInfoStackView.addArrangedSubview(titleLabel)
        topInfoStackView.addArrangedSubview(addressLabel)
        
        let serviceHoursStackView = UIStackView()
        serviceHoursStackView.axis = .vertical
        serviceHoursStackView.spacing = 8
        addSubview(serviceHoursStackView)
        serviceHoursStackView.topToBottom(
            of: topInfoStackView,
            offset: 24
        )
        serviceHoursStackView.leadingToSuperview(offset: 18)
        serviceHoursStackView.trailingToSuperview(offset: 18)
        serviceHoursStackView.addArrangedSubview(Self.createServiceHoursHeaderLabel())
        serviceHoursStackView.addArrangedSubview(serviceHoursLabel)
        
        let buttonsStackView = UIStackView()
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 12
        addSubview(buttonsStackView)
        buttonsStackView.topToBottom(
            of: serviceHoursStackView,
            offset: 24
        )
        buttonsStackView.leadingToSuperview(offset: 18)
        buttonsStackView.trailingToSuperview(offset: 18)
        buttonsStackView.bottomToSuperview()
        
        setupDetailsButton()
        setupConfirmAppointmentButton()
        buttonsStackView.addArrangedSubview(detailsButton)
        buttonsStackView.addArrangedSubview(confirmAppointmentButton)
    }
    
    private func createCloseButton() -> UIButton {
        let closeButton = UIButton(type: .system)
        closeButton.setImage(.Icons.cross, for: .normal)
        closeButton.tintColor = .Icons.iconAccentThemed
        
        closeButton.addTarget(
            self,
            action: #selector(onCloseButton),
            for: .touchUpInside
        )
        
        return closeButton
    }
        
    @objc private func onCloseButton() {
        onClose?()
    }
    
    private static func createTreatmentsLabel() -> UILabel {
        let treatmentsLabel = UILabel()
        treatmentsLabel.numberOfLines = 0
        treatmentsLabel <~ Style.Label.secondarySubhead
        
        return treatmentsLabel
    }
    
    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel <~ Style.Label.primaryHeadline1
        
        return titleLabel
    }
    
    private static func createAddressLabel() -> UILabel {
        let addressLabel = UILabel()
        addressLabel.numberOfLines = 0
        addressLabel <~ Style.Label.primaryText
        
        return addressLabel
    }
    
    private static func createServiceHoursHeaderLabel() -> UILabel {
        let serviceHoursHeaderLabel = UILabel()
        serviceHoursHeaderLabel.text = NSLocalizedString("info_open_hours", comment: "")
        serviceHoursHeaderLabel <~ Style.Label.primaryHeadline1
        
        return serviceHoursHeaderLabel
    }
    
    private static func createServiceHoursLabel() -> UILabel {
        let serviceHoursLabel = UILabel()
        serviceHoursLabel.numberOfLines = 0
        serviceHoursLabel <~ Style.Label.primaryText
        
        return serviceHoursLabel
    }
    
    private func setupDetailsButton() {
        detailsButton.setTitle(
            NSLocalizedString("common_details", comment: ""),
            for: .normal
        )
        detailsButton <~ Style.RoundedButton.oldOutlinedButtonSmall
        
        detailsButton.addTarget(
            self,
            action: #selector(onDetailsButton),
            for: .touchUpInside
        )
    }
    
    @objc private func onDetailsButton() {
        onDetails?()
    }
    
    private func setupConfirmAppointmentButton() {
        confirmAppointmentButton.setTitle(
            NSLocalizedString("clinic_confirm_online_appointment", comment: ""),
            for: .normal
        )
        confirmAppointmentButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        
        confirmAppointmentButton.addTarget(
            self,
            action: #selector(onConfirmAppointmentButton),
            for: .touchUpInside
        )
    }
    
    @objc private func onConfirmAppointmentButton() {
        onConfirmAppointment?()
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    
        detailsButton <~ Style.RoundedButton.oldOutlinedButtonSmall
		confirmAppointmentButton <~ Style.RoundedButton.oldPrimaryButtonSmall
    }
}
