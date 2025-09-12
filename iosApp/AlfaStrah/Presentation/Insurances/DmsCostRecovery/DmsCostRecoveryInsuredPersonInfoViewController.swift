//
//  DmsCostRecoveryInsuredPersonInfoViewController.swift
//  AlfaStrah
//
//  Created by vit on 29.12.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit

class DmsCostRecoveryInsuredPersonInfoViewController: ViewController {
    enum State {
        case data
        case loading
        case failure
        case success
    }
    
    struct Notify {
        var updateWithState: (_ state: State) -> Void
        let insuredPersonSelected: (DmsCostRecoveryInsuredPerson) -> Void
        let isInsuranceEventFilled: (_ filled: Bool) -> Void
        let stepDataFilled: (_ filled: Bool) -> Void
    }

    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        updateWithState: { [weak self] state in
            guard let self = self,
                  self.isViewLoaded
            else { return }

            self.update(with: state)
        },
        insuredPersonSelected: { [weak self] selectedPerson in
            self?.fillDetails(from: selectedPerson)
        },
        isInsuranceEventFilled: { [weak self] filled in
            self?.setEventSelectionState(filled: filled)
        },
        stepDataFilled: { [weak self] filled in
            self?.nextButton.isEnabled = filled
        }
    )
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentStackView: UIStackView!
    @IBOutlet private var actionButtonsStackView: UIStackView!
    private let nextButton = RoundEdgeButton()
    
    private let sectionView = SectionsCardView()
    private let insuredPesonSelectionView = TitledValueCardView()
    private let eventSelectionView = TitledValueCardView()
    
    private var operationStatusView: OperationStatusView = .init(frame: .zero)
    
    struct Input {
        let insuredPersons: [DmsCostRecoveryInsuredPerson]
        let selectedInsuredPerson: DmsCostRecoveryInsuredPerson?
        let insuranceEventApplicationInfoFilled: Bool
        let stepDataFilled: Bool
    }

    var input: Input!
    
    struct Output {
        let applyForm: () -> Void
        let formSentSuccessCallback: () -> Void
        let previousStep: () -> Void
        let retryToGetData: () -> Void
        let showInsuredPersonSelection: () -> Void
        let showInsuranceEvent: () -> Void
    }
    
    var output: Output!
    
    let birthdayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setup()
        
        setEventSelectionState(filled: input.insuranceEventApplicationInfoFilled)
        nextButton.isEnabled = input.stepDataFilled
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        update(with: .data)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if scrollView.contentInset.bottom != actionButtonsStackView.bounds.height {
            scrollView.contentInset.bottom = actionButtonsStackView.bounds.height
        }
    }
    
    private func setup() {
		view.backgroundColor = .Background.backgroundContent
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        
        insuredPesonSelectionView.set(
            title: NSLocalizedString("dms_cost_recovery_insured_person_personal_info_request", comment: ""),
            subTitle: NSLocalizedString("dms_cost_recovery_insured_person_personal_info", comment: ""),
            placeholder: NSLocalizedString("dms_cost_recovery_default_info_empty_state", comment: ""),
            value: {
                if let initialSelectedPerson = input.selectedInsuredPerson {
                    return initialSelectedPerson.fullname
                } else {
                    return input.insuredPersons.count == 1 ? input.insuredPersons[0].fullname : nil
                }
            }(),
            icon: input.insuredPersons.count == 1 ? .empty : .rightArrow,
            isRequiredField: true
        )
        insuredPesonSelectionView.tapHandler = input.insuredPersons.count == 1 ? nil : output.showInsuredPersonSelection
        contentStackView.addArrangedSubview(insuredPesonSelectionView)
        
        if let initialSelectedPerson = input.selectedInsuredPerson {
            fillDetails(from: initialSelectedPerson)
        } else {
            if input.insuredPersons.count == 1,
               let insuredPerson = input.insuredPersons.first {
                fillDetails(from: insuredPerson)
            } else {
                sectionView.isHidden = true
            }
        }
        
        contentStackView.addArrangedSubview(sectionView)
        
        eventSelectionView.set(
            title: NSLocalizedString("dms_cost_recovery_insured_person_event_request", comment: ""),
            subTitle: NSLocalizedString("dms_cost_recovery_insured_person_event", comment: ""),
            placeholder: NSLocalizedString("dms_cost_recovery_default_info_empty_state", comment: ""),
            isRequiredField: true
        )
        eventSelectionView.tapHandler = output.showInsuranceEvent
        contentStackView.addArrangedSubview(eventSelectionView)
        
        addApplyFormButton()
        
        view.addSubview(operationStatusView)
        operationStatusView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: operationStatusView, in: view))
    }
    
    private func update(with state: State) {
        switch state {
            case .loading:
                operationStatusView.isHidden = false
                let state: OperationStatusView.State = .loading(.init(
                    title: NSLocalizedString("dms_cost_recovery_insured_person_application_loading_text", comment: ""),
                    description: nil,
                    icon: nil
                ))
                operationStatusView.notify.updateState(state)
            case .failure:
                let state: OperationStatusView.State = .info(.init(
                    title: NSLocalizedString("dms_cost_recovery_insured_preson_application_loading_error", comment: ""),
                    description: NSLocalizedString("dms_cost_recovery_insured_person_application_error_description", comment: ""),
                    icon: UIImage(named: "icon-common-failure")
                ))
                
                let buttons: [OperationStatusView.ButtonConfiguration] = [
                    .init(
                        title: NSLocalizedString("dms_cost_recovery_insured_person_application_loading_error_previous_step", comment: ""),
                        isPrimary: false,
                        action: {
                            self.output.previousStep()
                            self.operationStatusView.isHidden = true
                        }
                    ),
                    .init(
                        title: NSLocalizedString("common_retry", comment: ""),
                        isPrimary: true,
                        action: {
                            self.output.retryToGetData()
                            self.operationStatusView.isHidden = true
                        }
                    )
                ]
                operationStatusView.notify.updateState(state)
                operationStatusView.notify.buttonConfiguration(buttons)
            case .data:
                operationStatusView.isHidden = true
                scrollView.isHidden = false
            case .success:
                let state: OperationStatusView.State = .info(.init(
                    title: NSLocalizedString("common_success", comment: ""),
                    description: NSLocalizedString("dms_cost_recovery_insured_person_application_necessary_to_confirm", comment: ""),
					icon: .Icons.tick.resized(newWidth: 54)?.withRenderingMode(.alwaysTemplate)
                ))
                operationStatusView.notify.updateState(state)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    // since lottie animation can start only from didAppear of UIViewController
                    // its necessary to reset controller to data loading, to avoid previous state visibility
                    self.operationStatusView.isHidden = true
                    let state: OperationStatusView.State = .loading(.init(
                        title: NSLocalizedString("dms_cost_recovery_insured_person_application_loading_text", comment: ""),
                        description: nil,
                        icon: nil
                    ))
                    self.operationStatusView.notify.updateState(state)
                    self.output.formSentSuccessCallback()
                }
        }
    }
    
    private func addApplyFormButton() {
        nextButton <~ Style.RoundedButton.oldPrimaryButtonSmall
                
        nextButton.setTitle(
            NSLocalizedString("dms_cost_recovery_insured_person_application_confirm_title", comment: ""),
            for: .normal
        )
        nextButton.addTarget(self, action: #selector(applyFormButtonTap), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
        ])
        
        actionButtonsStackView.addArrangedSubview(nextButton)
        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 32, left: 18, bottom: 18, right: 18)
    }
    
    private func fillDetails(from insuredPerson: DmsCostRecoveryInsuredPerson) {
        insuredPesonSelectionView.updateValue(insuredPerson.fullname)
        
        let items: [SectionsCardView.Item] = [
            SectionsCardView.Item(
                title: NSLocalizedString("dms_cost_recovery_insured_person_birthday_title", comment: ""),
                placeholder: "",
                value: birthdayDateFormatter.string(from: insuredPerson.birthday),
                icon: .empty,
                isEnabled: true,
                tapHandler: nil
            ),
            SectionsCardView.Item(
                title: NSLocalizedString("dms_cost_recovery_insured_person_policy_number_title", comment: ""),
                placeholder: "",
                value: insuredPerson.policyNumber,
                icon: .empty,
                isEnabled: true,
                tapHandler: nil
            )
        ]
        sectionView.updateItems(items)
        sectionView.isHidden = false
    }
    
    private func setEventSelectionState(filled: Bool) {
        eventSelectionView.updateValue(
            filled
                ? NSLocalizedString("dms_cost_recovery_default_info_filled_state", comment: "")
                : nil
        )
    }
        
    @objc func applyFormButtonTap(_ sender: UIButton) {
        output.applyForm()
    }
    
    struct Constants {
        static let buttonHeight: CGFloat = 48
    }
}
