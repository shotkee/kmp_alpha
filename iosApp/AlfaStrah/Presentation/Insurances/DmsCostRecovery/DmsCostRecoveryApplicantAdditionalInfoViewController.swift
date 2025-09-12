//
//  DmsCostRecoveryApplicantAdditionalInfoViewController.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 27.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class DmsCostRecoveryAdditionalInfoViewController: ViewController {
    @IBOutlet private var switchView: RMRStyledSwitch!
    @IBOutlet private var contentStackView: UIStackView!
    @IBOutlet private var actionButtonsStackView: UIStackView!
    private let rfCitizenSectionsView = SectionsCardView()
    private let nonResidentSectionsView = SectionsCardView()
    private let actionButton = RoundEdgeButton()
    
    struct Notify {
        let additionalInfoFilled: (_ filled: Bool) -> Void
    }
    
    private(set) lazy var notify = Notify(
        additionalInfoFilled: { [weak self] filled in
            self?.actionButton.isEnabled = filled
        }
    )
    
    struct Input {
        let additionalInfo: DmsCostRecoveryFlow.AdditionalInfo
    }
    
    var input: Input!
    
    struct Output {
        let kindChanged: (DmsCostRecoveryFlow.AdditionalInfo.Kind) -> Void
        let rfCitizenInfoChanged: (DmsCostRecoveryFlow.AdditionalInfo.RFCitizen) -> Void
        let nonResidentInfoChanged: (DmsCostRecoveryFlow.AdditionalInfo.NonResident) -> Void
        let doneButtonTap: () -> Void
    }
    
    var output: Output!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private var rfCitizen: DmsCostRecoveryFlow.AdditionalInfo.RFCitizen! {
        didSet {
            updateRfCitizenItems()
            output.rfCitizenInfoChanged(rfCitizen)
        }
    }
    
    private var nonResident: DmsCostRecoveryFlow.AdditionalInfo.NonResident! {
        didSet {
            updateNonResidentItems()
            output.nonResidentInfoChanged(nonResident)
        }
    }
    
    private func setup() {
        let additionalInfo = input.additionalInfo
        rfCitizen = additionalInfo.rfCitizen
        nonResident = additionalInfo.nonResident
		view.backgroundColor = .Background.backgroundContent
        
        switchView.style(
            leftTitle: NSLocalizedString("dms_cost_recovery_RF_citizen_title", comment: ""),
            rightTitle: NSLocalizedString("dms_cost_recovery_non_resident_title", comment: ""),
			titleColor: .Text.textPrimary,
			backgroundColor: .Background.backgroundTertiary,
			selectedTitleColor: .Text.textContrast,
			selectedBackgroundColor: .Background.segmentedControlAccent
        )
        
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        
        title = NSLocalizedString("dms_cost_recovery_additional_info", comment: "")
        
        contentStackView.addArrangedSubview(rfCitizenSectionsView)
        updateRfCitizenItems()
        
        contentStackView.addArrangedSubview(nonResidentSectionsView)
        updateNonResidentItems()
        
        let kind = additionalInfo.kind
        switchView.setSelectedIndex(kind.rawValue, animated: false)
        displayTab(kind)
        
        setupActionButton()
    }
    
    private func singleLineItem(
        title: String,
        initialText: @escaping () -> String?,
        prompt: String,
        charsLimit: Int,
        completion: @escaping (String) -> Void
    ) -> SectionsCardView.Item {
        return item(
            title: title,
            initialText: initialText(),
            tapHandler: { [weak self] in
                self?.openSingleLineInputBottomViewController(
                    title: title,
                    prompt: prompt,
                    initialText: initialText(),
                    charsLimit: charsLimit,
                    completion: completion
                )
            }
        )
    }
    
    private func multiLineItem(
        title: String,
        initialText: @escaping () -> String?,
        prompt: String,
        charsLimit: Int,
        autocapitalizationType: UITextAutocapitalizationType = .none,
        completion: @escaping (String) -> Void
    ) -> SectionsCardView.Item {
        return item(
            title: title,
            initialText: initialText(),
            tapHandler: { [weak self] in
                self?.openMultiLineInputBottomViewController(
                    title: title,
                    prompt: prompt,
                    initialText: initialText(),
                    charsLimit: charsLimit,
                    autocapitalizationType: autocapitalizationType,
                    completion: completion
                )
            }
        )
    }
    
    private func item(
        title: String,
        initialText: String?,
        tapHandler: @escaping () -> Void
    ) -> SectionsCardView.Item {
        return .init(
            title: title,
            placeholder: title,
            value: initialText,
            icon: .rightArrow,
            isEnabled: true,
            tapHandler: tapHandler
        )
    }
    
    private func updateRfCitizenItems() {
        let items: [SectionsCardView.Item] = [
            singleLineItem(
                title: NSLocalizedString("dms_cost_recovery_SNILS_title", comment: ""),
                initialText: { [weak self] in
                    return self?.rfCitizen.snils
                },
                prompt: NSLocalizedString("dms_cost_recovery_SNILS_prompt", comment: ""),
                charsLimit: 11,
                completion: { [weak self] snils in
                    self?.nonResident = .init()
                    self?.rfCitizen.snils = snils
                }
            ),
            singleLineItem(
                title: NSLocalizedString("dms_cost_recovery_INN_title", comment: ""),
                initialText: { [weak self] in
                    self?.rfCitizen.inn
                },
                prompt: NSLocalizedString("dms_cost_recovery_INN_prompt", comment: ""),
                charsLimit: 12,
                completion: { [weak self] inn in
                    self?.nonResident = .init()
                    self?.rfCitizen.inn = inn
                }
            )
        ]
        rfCitizenSectionsView.updateItems(items)
    }
    
    private func updateNonResidentItems() {
        let nonResidentItems: [SectionsCardView.Item] = [
            multiLineItem(
                title: NSLocalizedString("dms_cost_recovery_migration_card_number_title", comment: ""),
                initialText: { [weak self] in
                    self?.nonResident.migrationCardNumber
                },
                prompt: NSLocalizedString("dms_cost_recovery_migration_card_number_prompt", comment: ""),
                charsLimit: 50,
                completion: { [weak self] migrationCardNumber in
                    self?.rfCitizen = .init()
                    self?.nonResident.migrationCardNumber = migrationCardNumber
                }
            ),
            multiLineItem(
                title: NSLocalizedString("dms_cost_recovery_residential_address_title", comment: ""),
                initialText: { [weak self] in
                    self?.nonResident.residentialAddress
                },
                prompt: NSLocalizedString("dms_cost_recovery_residential_address_prompt", comment: ""),
                charsLimit: 250,
                autocapitalizationType: .sentences,
                completion: { [weak self] residentialAddress in
                    self?.rfCitizen = .init()
                    self?.nonResident.residentialAddress = residentialAddress
                }
            )
        ]
        nonResidentSectionsView.updateItems(nonResidentItems)
    }
    
    private func setupActionButton() {
        actionButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        
        actionButton.setTitle(
            NSLocalizedString("common_done_button", comment: ""),
            for: .normal
        )
        actionButton.addTarget(self, action: #selector(actionButtonTap), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
        ])
        
        actionButtonsStackView.addArrangedSubview(actionButton)
        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 32, left: 18, bottom: 18, right: 18)

        actionButton.isEnabled = rfCitizen.isFilled || nonResident.isFilled
    }
    
    private func displayTab(_ kind: DmsCostRecoveryFlow.AdditionalInfo.Kind) {
        rfCitizenSectionsView.isHidden = kind != .rfCitizen
        nonResidentSectionsView.isHidden = kind != .nonResident
    }
    
    @IBAction func switchTap(_ sender: RMRStyledSwitch) {
        guard let kind = DmsCostRecoveryFlow.AdditionalInfo.Kind(rawValue: sender.selectedIndex)
        else { return }
        
        displayTab(kind)
        output.kindChanged(kind)
    }
    
    @objc func actionButtonTap(_ sender: UIButton) {
        output.doneButtonTap()
    }
    
    private func openSingleLineInputBottomViewController(
        title: String,
        prompt: String,
        initialText: String?,
        charsLimit: Int,
        completion: @escaping (String) -> Void
    ) {
        let controller = InputBottomViewController()
        container?.resolve(controller)
        
        let input = InputBottomViewController.InputObject(
            text: initialText,
            placeholder: prompt,
            charsLimited: .limited(charsLimit),
            keyboardType: .decimalPad,
            validationRule: [
                LengthValidationRule(maxChars: charsLimit)
            ],
            preventInputOnLimit: true
        )
        controller.input = .init(
            title: title,
            infoText: nil,
            inputs: [input]
        )
        
        controller.output = .init(
            close: { [weak self] in
                self?.dismiss(animated: true)
            },
            done: { [weak self] result in
                let series = result[input.id] ?? ""
                completion(series)
                self?.dismiss(animated: true)
            }
        )
        
        showBottomSheet(contentViewController: controller)
    }
    
    private func openMultiLineInputBottomViewController(
        title: String,
        prompt: String,
        initialText: String?,
        charsLimit: Int,
        autocapitalizationType: UITextAutocapitalizationType = .none,
        completion: @escaping (String) -> Void
    ) {
        let controller = TextAreaInputBottomViewController()
        container?.resolve(controller)
        
        controller.input = .init(
            title: title,
            description: nil,
            textInputTitle: nil,
            textInputPlaceholder: prompt,
            initialText: initialText,
            validationRules: [
                LengthValidationRule(maxChars: charsLimit)
            ],
            showValidInputIcon: false,
            keyboardType: .default,
            autocapitalizationType: autocapitalizationType,
            charsLimited: .limited(charsLimit),
            showMaxCharsLimit: true
        )
        
        controller.output = .init(
            close: { [weak self] in
                self?.dismiss(animated: true)
            },
            text: { [weak self] text in
                completion(text)
                self?.dismiss(animated: true)
            }
        )
        
        showBottomSheet(contentViewController: controller)
    }
    
    struct Constants {
        static let buttonHeight: CGFloat = 48
    }
}
