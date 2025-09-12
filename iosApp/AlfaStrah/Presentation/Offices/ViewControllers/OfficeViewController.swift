//
//  OfficeViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 19/11/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy
import CoreLocation

final class OfficeViewController: ViewController, UITextViewDelegate {
    private struct Field {
        let title: String?
        let text: String
    }

    struct Input {
        let office: Office
    }

    struct Output {
        let routeTap: (CLLocationCoordinate2D, _ title: String?) -> Void
        let routeInAnotherApp: (CLLocationCoordinate2D, _ title: String?) -> Void
        let phoneTap: (Phone) -> Void
        let phonesTap: ([Phone]) -> Void
    }

    var input: Input!
    var output: Output!

    private let stackView = UIStackView()
    @IBOutlet private var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    // MARK: - Setup UI
    private func setup() {
        view.backgroundColor = .Background.backgroundContent
        
        title = NSLocalizedString("office_title", comment: "")
        
        scrollView.contentInset.bottom = Constants.buttonHeight + 12
        scrollView.scrollIndicatorInsets.bottom = scrollView.contentInset.bottom

        stackView.subviews.forEach { $0.removeFromSuperview() }

        let office = input.office

        let mapView = MapInfoView.fromNib()
        mapView.configureForCoordinate(office.coordinate.clLocationCoordinate)
        scrollView.addSubview(mapView)
        mapView.top(to: scrollView)
        mapView.leading(to: view)
        mapView.trailing(to: view)
        
        let sheetView = UIView()
        let containerView = sheetView.embedded(hasShadow: true, shadowStyle: .elevation1)
        scrollView.addSubview(containerView)
        containerView.topToBottom(of: mapView, offset: -12)
        containerView.edgesToSuperview(excluding: .top)
        containerView.width(to: view)
        
        let addressInfoView = OfficeInfoView(frame: .zero, margins: .zero)
        addressInfoView.hideShadow = true
        addressInfoView.cornerSide = .top
        addressInfoView.color = .Background.backgroundContent
        containerView.addSubview(addressInfoView)
        addressInfoView.set(
            address: office.address,
            distance: office.distance,
            marginForView: .zero
        )
        addressInfoView.setInternalMargins(margins: .init(top: 20, left: 18, bottom: 8, right: 18))
        addressInfoView.setAddressLabelStyle(style: Style.Label.primaryHeadline1)
        addressInfoView.accessibilityIdentifier = "addressInfoView"
        addressInfoView.edgesToSuperview(excluding: .bottom)
        
        containerView.addSubview(stackView)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .zero
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.backgroundColor = .clear
        
        stackView.topToBottom(of: addressInfoView)
        stackView.edgesToSuperview(excluding: .top)

        addMetroSection(with: office)
        addWorkHoursSection(with: office)
        addPhonesSection(with: office)
        addSpecializationsSection(with: office)
        addCardPaymentSection(with: office)
        addServicesSection(with: office)
        addClaimsSection(with: office)
        addAdvertTextSection(with: office)
        addAdditionalContactsSection(with: office)
        addSpecialConditionsSection(with: office)
        addCampaignsSection(with: office)
        addButtonSection(office)
    }
        
    private func addMetroSection(with office: Office) {
        if let metros = office.metro, !metros.isEmpty {
            let metroInfoView = OfficeDescriptionView()
            let metroText = metros.joined(separator: ", ")
            let metroField = Field(title: NSLocalizedString("office_metro", comment: ""), text: metroText)
            let metroTextBlock = CommonInfoView.TextBlock(text: metroText) { [weak self, weak metroInfoView] in
                guard let self, let metroInfoView
                else { return }
                self.copyField(metroField, from: metroInfoView)
            }
            metroInfoView.accessibilityIdentifier = "workHoursInfoView"
            metroInfoView.set(
                title: metroField.title,
                blocks: [ metroTextBlock ],
                icon: .Icons.metro.tintedImage(withColor: .Icons.iconSecondary)
            )
            stackView.addArrangedSubview(metroInfoView)
        }
    }
    
    private func addPhonesSection(with office: Office) {
        if !office.phones.isEmpty {
            let phoneInfoView = OfficeDescriptionView()
            let textBlocks = office.phones.map { phone in
                CommonInfoView.TextBlock(text: phone.humanReadable) { [weak self] in
                    self?.output.phoneTap(phone)
                }
            }
            
            phoneInfoView.set(
                title: NSLocalizedString("info_phone", comment: ""),
                blocks: textBlocks,
                icon: .Icons.call.tintedImage(withColor: .Icons.iconSecondary),
                textStyle: Style.Label.accentText
            )

            phoneInfoView.accessibilityIdentifier = "phoneInfoView"
            stackView.addArrangedSubview(phoneInfoView)
        }
    }
    
    private func addWorkHoursSection(with office: Office) {
        let workHoursInfoView = OfficeDescriptionView()
        let workHoursInfoField = Field(title: NSLocalizedString("info_open_hours", comment: ""), text: office.serviceHours)
        let workHoursTextBlock = CommonInfoView.TextBlock(text: office.serviceHours) { [weak self, weak workHoursInfoView] in
            guard let self, let workHoursInfoView
            else { return }
            self.copyField(workHoursInfoField, from: workHoursInfoView)
        }
        workHoursInfoView.accessibilityIdentifier = "workHoursInfoView"
        workHoursInfoView.set(
            title: workHoursInfoField.title,
            blocks: [ workHoursTextBlock ],
            icon: .Icons.clock.tintedImage(withColor: .Icons.iconSecondary)
        )
        stackView.addArrangedSubview(workHoursInfoView)
    }
    
    private func addCardPaymentSection(with office: Office) {
        let cardPaymentAvailableInfoView = OfficeDescriptionView()
        let cardPaymentInfoField = Field(
            title: NSLocalizedString("office_card_pay_title", comment: ""),
            text: NSLocalizedString(office.cardPaymentAvailable ? "office_card_pay_accepted" : "office_card_pay_not_accepted", comment: "")
        )
        let cardPaymentTextBlock = CommonInfoView.TextBlock(
            text: cardPaymentInfoField.text
        ) { [weak self, weak cardPaymentAvailableInfoView] in
            guard let self, let cardPaymentAvailableInfoView
            else { return }
            self.copyField(cardPaymentInfoField, from: cardPaymentAvailableInfoView)
        }
        cardPaymentAvailableInfoView.set(
            title: cardPaymentInfoField.title,
            blocks: [ cardPaymentTextBlock ],
            icon: .Icons.bankCard.tintedImage(withColor: .Icons.iconSecondary)
        )
        stackView.addArrangedSubview(cardPaymentAvailableInfoView)
    }
 
    private func addSpecializationsSection(with office: Office) {
        var textBlocks: [ CommonInfoView.TextBlock ] = []
        office.services.forEach { textBlocks.append(.init(text: $0)) }

        if !textBlocks.isEmpty {
            let servicesInfoView = OfficeDescriptionView()
            servicesInfoView.set(
                title: NSLocalizedString("info_office_services", comment: ""),
                blocks: textBlocks,
                icon: .Icons.badge.tintedImage(withColor: .Icons.iconSecondary)
            )
            let field = Field(
                title: NSLocalizedString("info_office_services", comment: ""),
                text: textBlocks.map { $0.text }
                    .joined(separator: "\n")
            )
            let action = { [weak self, weak servicesInfoView] in
                guard let self, let servicesInfoView
                else { return }
                self.copyField(field, from: servicesInfoView)
            }
            textBlocks.forEach { $0.tapCallback = action }
            servicesInfoView.accessibilityIdentifier = "servicesInfoView"
            stackView.addArrangedSubview(servicesInfoView)
        }
    }
    
    private func addServicesSection(with office: Office) {
        let servicesInfoView = OfficeDescriptionView()
        var textBlocks: [ CommonInfoView.TextBlock ] = []
        var texts: [String] = []
        if office.purchaseActive {
            let text = NSLocalizedString("office_purchase_active_text", comment: "")
            texts.append(text)
            textBlocks.append(.init(text: text))
        }
        if office.damageClaimAvailable {
            let text = NSLocalizedString("office_damage_claim_available_text", comment: "")
            texts.append(text)
            textBlocks.append(.init(text: text))
        }
        if office.osagoClaimAvailable {
            let text = NSLocalizedString("office_osago_claim_available_text", comment: "")
            texts.append(text)
            textBlocks.append(.init(text: text))
        }
        if office.telematicsInstallAvailable {
            let text = NSLocalizedString("office_telematics_install_available_text", comment: "")
            texts.append(text)
            textBlocks.append(.init(text: text))
        }
        if !textBlocks.isEmpty {
            let field = Field(title: NSLocalizedString("office_services_title", comment: ""), text: texts.reduce("") { $0 + "\n" + $1 })
            let action = { [weak self, weak servicesInfoView] in
                guard let self, let servicesInfoView
                else { return }
                self.copyField(field, from: servicesInfoView)
            }
            textBlocks.forEach { $0.tapCallback = action }
            servicesInfoView.set(
                title: field.title,
                blocks: textBlocks,
                icon: .Icons.shieldHeart.tintedImage(withColor: .Icons.iconSecondary)
            )
            servicesInfoView.accessibilityIdentifier = "servicesInfoView"
            stackView.addArrangedSubview(servicesInfoView)
        }
    }

    private func addClaimsSection(with office: Office) {
        if office.damageClaimAvailable {
            let damageClaimAvailableView = OfficeDescriptionView()
            let damageClaimCleanText = (TextHelper.html(from: office.damageClaimText ?? "")).string
            let damageClaimField = Field(
                title: NSLocalizedString("office_damage_claim_available_title", comment: ""),
                text: damageClaimCleanText
            )
            let damageClaimTextBlock = CommonInfoView.TextBlock(
                text: damageClaimField.text
            ) { [weak self, weak damageClaimAvailableView] in
                guard let self, let damageClaimAvailableView
                else { return }
                self.copyField(damageClaimField, from: damageClaimAvailableView)
            }
            damageClaimAvailableView.set(
                title: damageClaimField.title,
                blocks: [ damageClaimTextBlock ],
                icon: .Icons.tickInCircle.tintedImage(withColor: .Icons.iconSecondary)
            )
            damageClaimAvailableView.accessibilityIdentifier = "damageClaimAvailableView"
            stackView.addArrangedSubview(damageClaimAvailableView)
        }

        if office.osagoClaimAvailable {
            let osagoClaimAvailableView = OfficeDescriptionView()
            let osagoClaimCleanText = TextHelper.html(from: office.osagoClaimText ?? "").string
            let osagoClaimField = Field(
                title: NSLocalizedString("office_osago_claim_available_title", comment: ""),
                text: osagoClaimCleanText
            )
            let osagoClaimTextBlock = CommonInfoView.TextBlock(
                text: osagoClaimField.text
            ) { [weak self, weak osagoClaimAvailableView] in
                guard let self, let osagoClaimAvailableView
                else { return }
                self.copyField(osagoClaimField, from: osagoClaimAvailableView)
            }
            osagoClaimAvailableView.set(
                title: osagoClaimField.title,
                blocks: [ osagoClaimTextBlock ],
                icon: .Icons.car.tintedImage(withColor: .Icons.iconSecondary)
            )
            osagoClaimAvailableView.accessibilityIdentifier = "osagoClaimAvailableView"
            stackView.addArrangedSubview(osagoClaimAvailableView)
        }
    }

    private func addAdvertTextSection(with office: Office) {
        if let advertText = office.advertText, !advertText.isEmpty {
            let advertInfoView = OfficeDescriptionView()
            let advertField = Field(
                title: NSLocalizedString("office_advert_title", comment: ""),
                text: TextHelper.html(from: advertText).string
            )
            let advertTextBlock = CommonInfoView.TextBlock(
                text: advertField.text
            ) { [weak self, weak advertInfoView] in
                guard let self, let advertInfoView
                else { return }
                self.copyField(advertField, from: advertInfoView)
            }

            advertInfoView.set(
                title: advertField.title,
                blocks: [ advertTextBlock ],
                icon: .Icons.warnInfo.tintedImage(withColor: .Icons.iconSecondary)
            )
            
            stackView.addArrangedSubview(advertInfoView)
        }
    }

    private func addAdditionalContactsSection(with office: Office) {
        if let additionalContacts = office.additionalContacts, !additionalContacts.isEmpty {
            let additionalContactsHtmlText = TextHelper.html(from: additionalContacts).string
            let additionalContactsInfoView = OfficeDescriptionView()
            let additionalContactsField = Field(
                title: NSLocalizedString("office_additional_contacts_title", comment: ""),
                text: additionalContactsHtmlText
            )
            let additionalContactsTextBlock = CommonInfoView.TextBlock(
                text: additionalContactsField.text
            ) { [weak self, weak additionalContactsInfoView] in
                guard let self, let additionalContactsInfoView
                else { return }
                self.copyField(additionalContactsField, from: additionalContactsInfoView)
            }

            additionalContactsInfoView.set(
                title: nil,
                blocks: [ additionalContactsTextBlock ],
                icon: .Icons.documentInfo.tintedImage(withColor: .Icons.iconSecondary)
            )
            additionalContactsInfoView.accessibilityIdentifier = "additionalContactsInfoView"
            stackView.addArrangedSubview(additionalContactsInfoView)
        }
    }

    private func addSpecialConditionsSection(with office: Office) {
        if let specialConditions = office.specialConditions, !specialConditions.isEmpty {
            let specialConditionsHtmlText = TextHelper.html(from: specialConditions).string
            let specialConditionsField = Field(
                title: NSLocalizedString("office_special_conditions_title", comment: ""),
                text: specialConditionsHtmlText
            )
            let specialConditionsInfoView = OfficeDescriptionView()
            let specialConditionsTextBlock = CommonInfoView.TextBlock(
                text: specialConditionsField.text
            ) { [weak self, weak specialConditionsInfoView] in
                guard let self, let specialConditionsInfoView
                else { return }
                self.copyField(specialConditionsField, from: specialConditionsInfoView)
            }
            specialConditionsInfoView.set(
                title: specialConditionsField.title,
                blocks: [ specialConditionsTextBlock ],
                icon: .Icons.star.tintedImage(withColor: .Icons.iconSecondary)
            )
            specialConditionsInfoView.accessibilityIdentifier = "specialConditionsInfoView"
            stackView.addArrangedSubview(specialConditionsInfoView)
        }
    }

    private func addCampaignsSection(with office: Office) {
        if let campaigns = office.campaigns, !campaigns.isEmpty {
            let campaignsHtmlText = TextHelper.html(from: campaigns).string
            let campaignsField = Field(title: NSLocalizedString("info_campaigns", comment: ""), text: campaignsHtmlText)
            let campaignsInfoView = OfficeDescriptionView()
            let campaignsTextBlock = CommonInfoView.TextBlock(
                text: campaignsHtmlText
            ) { [weak self, weak campaignsInfoView] in
                guard let self, let campaignsInfoView
                else { return }
                self.copyField(campaignsField, from: campaignsInfoView)
            }
            campaignsInfoView.set(
                title: campaignsField.title,
                blocks: [ campaignsTextBlock ],
                icon: .Icons.discount.tintedImage(withColor: .Icons.iconSecondary)
            )
            campaignsInfoView.accessibilityIdentifier = "campaignsInfoView"
            stackView.addArrangedSubview(campaignsInfoView)
        }
    }

    private func addButtonSection(_ office: Office) {
        let whiteBackground = UIView()
        whiteBackground.backgroundColor = .clear

        let plotRouteButton = RoundEdgeButton()
        plotRouteButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        plotRouteButton.setTitle(NSLocalizedString("office_route_button", comment: ""), for: .normal)
        plotRouteButton.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        
        view.addSubview(whiteBackground)
        whiteBackground.addSubview(plotRouteButton)
        
        whiteBackground.translatesAutoresizingMaskIntoConstraints = false
        plotRouteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            whiteBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            whiteBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            whiteBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            whiteBackground.topAnchor.constraint(equalTo: plotRouteButton.topAnchor),
            plotRouteButton.leadingAnchor.constraint(equalTo: whiteBackground.leadingAnchor, constant: 18),
            plotRouteButton.trailingAnchor.constraint(equalTo: whiteBackground.trailingAnchor, constant: -18),
            plotRouteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            plotRouteButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
    
    @objc private func tapButton() {
        output.routeInAnotherApp(input.office.coordinate.clLocationCoordinate, input.office.address)
    }

    private func copyField(_ field: Field, from view: UIView) {
        let alerController = UIAlertController(
            title: field.title,
            message: nil,
            preferredStyle: .actionSheet
        )
        alerController.addAction(
            UIAlertAction(
                title: NSLocalizedString("common_copy", comment: ""),
                style: .default
            ) { _ in
                UIPasteboard.general.string = field.text
            }
        )
        alerController.addAction(
            UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .destructive, handler: nil)
        )
        if let popoverController = alerController.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = view.bounds
        }
        present(alerController, animated: true, completion: nil)
    }

    // MARK: UITextViewDelegate
    func textView(
        _ textView: UITextView,
        shouldInteractWith url: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        LocalDocumentViewer.open(url, from: self)
        return true
    }
    
    private enum Constants {
        static let buttonHeight: CGFloat = 48
    }
}
