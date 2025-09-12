//
//  ClinicViewController.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 17/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy
import CoreLocation

final class ClinicViewController: ViewController {
    enum Kind {
        case clinicInfo(Clinic, fullInfo: Bool)
        case createAppointment(Clinic, fullInfo: Bool)
    }

    struct Input {
        var kind: Kind
        var showConfirmButton: Bool
    }

    struct Output {
        var confirmAppointment: () -> Void
        var linkTap: (URL) -> Void
        var routeTap: (CLLocationCoordinate2D, _ title: String?) -> Void
        var routeInAnotherApp: (CLLocationCoordinate2D, _ title: String?) -> Void
        var phoneTap: (Phone) -> Void
        var phonesTap: ([Phone]) -> Void
    }

    var input: Input!
    var output: Output!

    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var actionButtonsStackView: UIStackView!
    @IBOutlet private var bottomGradientView: GradientView!
    private var buttonsStackView = UIStackView()

    private var clinic: Clinic {
        switch input.kind {
            case .clinicInfo(let clinic, _):
                return clinic
            case .createAppointment(let clinic, _):
                return clinic
        }
    }

    private var fullInfo: Bool {
        switch input.kind {
            case .clinicInfo(_, let fullInfo):
                return fullInfo
            case .createAppointment(_, let fullInfo):
                return fullInfo
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    // MARK: - Setup UI
    private func setup() {
		view.backgroundColor = .Background.backgroundContent
		
        title = NSLocalizedString("clinic_title", comment: "")

        addButtonsSection(clinic)

        bottomGradientView.update()
        stackView.subviews.forEach { $0.removeFromSuperview() }

        let mapView = MapInfoView.fromNib()
        mapView.configureForCoordinate(clinic.coordinate.clLocationCoordinate)
        stackView.addArrangedSubview(mapView)

        let titleInfoView = CommonInfoView.fromNib()
        titleInfoView.set(
            title: nil,
            textBlocks: [ CommonInfoView.TextBlock(text: clinic.title) ],
            appearance: .newMediumWithoutSeparator
        )
        stackView.addArrangedSubview(titleInfoView)

        let addressInfoView = CommonInfoView.fromNib()
        addressInfoView.set(
            title: NSLocalizedString("info_open_address", comment: ""),
            textBlocks: [ CommonInfoView.TextBlock(text: clinic.address) ],
            appearance: .newRegularWithoutSeparator
        )
        stackView.addArrangedSubview(addressInfoView)

        if !(clinic.phoneList ?? []).isEmpty {
            let textBlocks = (clinic.phoneList ?? []).map { phone in
                CommonInfoView.TextBlock(text: phone.humanReadable) { [weak self] in
                    self?.output.phoneTap(phone)
                }
            }
            let phoneInfoView = CommonInfoView.fromNib()
            phoneInfoView.set(
                title: NSLocalizedString("info_phone_long", comment: ""),
                textBlocks: textBlocks,
                appearance: .newRegularWithoutSeparator
            )
            stackView.addArrangedSubview(phoneInfoView)
        }

        let workHoursInfoView = CommonInfoView.fromNib()
        workHoursInfoView.set(
            title: NSLocalizedString("info_open_hours", comment: ""),
            textBlocks: [ CommonInfoView.TextBlock(text: clinic.serviceHours) ],
            appearance: .newRegularWithoutSeparator
        )
        stackView.addArrangedSubview(workHoursInfoView)

        if let webAddress = clinic.url {
            let webAddressInfoView = CommonInfoView.fromNib()
            let textBlock = CommonInfoView.TextBlock(text: webAddress.absoluteString) { [weak self] in
                self?.output.linkTap(webAddress)
            }
            webAddressInfoView.set(
                title: NSLocalizedString("info_site", comment: ""),
                textBlocks: [ textBlock ],
                appearance: .newRegularLinkWithoutSeparator
            )
            stackView.addArrangedSubview(webAddressInfoView)
        }

        if !clinic.serviceList.isEmpty {
            let textBlocks = clinic.serviceList
                .map
            {
                CommonInfoView.TextBlock(
					text: $0
                )
            }

            let treatmentsInfoView = CommonInfoView.fromNib()
            treatmentsInfoView.set(
                title: NSLocalizedString("info_clinic_treatments", comment: ""),
                textBlocks: textBlocks,
                appearance: .newRegularWithoutSeparator
            )
            stackView.addArrangedSubview(treatmentsInfoView)
        }

        addAppointmentSection()
		
		setupBottomGradientView()
    }
	
	private func setupBottomGradientView() {
		bottomGradientView.startPoint = CGPoint(x: 0.0, y: 0.1)
		bottomGradientView.endPoint = CGPoint(x: 0.0, y: 0.0)

		bottomGradientView.startColor = .Background.backgroundContent
		bottomGradientView.endColor = .Background.backgroundContent.withAlphaComponent(0)
		bottomGradientView.update()
	}

    private func addAppointmentSection() {
		let title = clinic.buttonAction == .appointmentOnline
			? "clinic_confirm_online_appointment"
			: "clinic_confirm_appointment"
		addConfirmAppointmentButton(title: title)
    }
    
    private func addDisclaimer(description: String) {
        let disclaimerContainer = UIView(frame: .zero)
        let disclaimerLabel = UILabel(frame: .zero)
        disclaimerLabel <~ Style.Label.secondaryText
        disclaimerLabel.numberOfLines = 0
        disclaimerLabel.text = NSLocalizedString(description, comment: "")
        disclaimerContainer.addSubview(disclaimerLabel)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: disclaimerLabel,
                in: disclaimerContainer,
                margins: UIEdgeInsets(top: 10, left: 18, bottom: 24, right: 18)
            )
        )
        stackView.addArrangedSubview(disclaimerContainer)
    }

    private func addConfirmAppointmentButton(title: String) {
        let confirmAppointmentButton = RoundEdgeButton()
        confirmAppointmentButton <~ Style.RoundedButton.oldPrimaryButtonSmall
                
        confirmAppointmentButton.setTitle(
            NSLocalizedString(title, comment: ""),
            for: .normal
        )
        confirmAppointmentButton.addTarget(self, action: #selector(confirmAppointmentTap), for: .touchUpInside)
        confirmAppointmentButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            confirmAppointmentButton.heightAnchor.constraint(equalToConstant: 48),
        ])
        actionButtonsStackView.addArrangedSubview(confirmAppointmentButton)
        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
    }
    
    private func addButtonsSection(_ clinic: Clinic) {
        let goToButton = CardVerticalButton()
        goToButton.set(
            title: NSLocalizedString("info_clinic_route_button", comment: ""),
            icon: UIImage(named: "icon-route-2")
        )
        goToButton.tapHandler = { [weak self] in self?.output.routeInAnotherApp(clinic.coordinate.clLocationCoordinate, clinic.address) }

        let callButton = CardVerticalButton()
        callButton.set(
            title: NSLocalizedString("info_clinic_call_button", comment: ""),
            icon: UIImage(named: "icon-phone-2")
        )
        callButton.tapHandler = { [weak self] in self?.output.phonesTap(clinic.phoneList ?? []) }

        buttonsStackView.backgroundColor = .clear
        buttonsStackView.accessibilityIdentifier = "buttonsStackView"
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 9
        buttonsStackView.distribution = .fillEqually
        
        if !clinic.address.isEmpty {
            buttonsStackView.addArrangedSubview(CardView(contentView: goToButton))
        }
        
        if !(clinic.phoneList ?? []).isEmpty {
            buttonsStackView.addArrangedSubview(CardView(contentView: callButton))
        }
        
        actionButtonsStackView.addArrangedSubview(buttonsStackView)
    }

    // MARK: - Actions
    @IBAction func confirmAppointmentTap(_ sender: UIButton) {
        output.confirmAppointment()
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateTheme()
	}
	
	private func updateTheme() {
		bottomGradientView.startColor = .Background.backgroundContent
		bottomGradientView.endColor = .Background.backgroundContent.withAlphaComponent(0)
		bottomGradientView.update()
	}
}
