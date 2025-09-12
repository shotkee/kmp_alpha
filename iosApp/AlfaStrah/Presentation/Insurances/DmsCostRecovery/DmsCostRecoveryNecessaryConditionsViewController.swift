//
//  DmsCostRecoveryNecessaryConditionsViewController.swift
//  AlfaStrah
//
//  Created by vit on 29.12.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class DmsCostRecoveryNecessaryConditionsViewController: ViewController {
    enum State {
        case loading
        case failure
        case data(DmsCostRecoveryInstruction)
    }
    
    struct Notify {
        var changed: () -> Void
    }

    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        changed: { [weak self] in
            guard let self = self,
                  self.isViewLoaded
            else { return }

            self.update()
        }
    )
    
    @IBOutlet private var actionButtonsStackView: UIStackView!
    @IBOutlet private var contentStackView: UIStackView!
    @IBOutlet private var scrollView: UIScrollView!
    private let noticeLabel = UILabel()
    private let conditionsStackView = UIStackView()
    private let passToInsurancePlanView = DocumentCardView()
    private let passToInsurancePlanContainerView = UIView()
    
    private var operationStatusView: OperationStatusView = .init(frame: .zero)
        
    struct Input {
        let getState: () -> State
    }
    
    var input: Input!
    
    struct Output {
        var startedForm: () -> Void
        var passToInsurancePlan: (URL) -> Void
        var goToChat: () -> Void
        var retryToGetData: () -> Void
    }
    
    var output: Output!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // update must be placed here because the lottie-animation can only be started from didAppear method
        // https://github.com/airbnb/lottie-ios/issues/510#issuecomment-1092509674
        update()
    }
    
    private func setup() {
        title = NSLocalizedString("dms_cost_recovery", comment: "")
		view.backgroundColor = .Background.backgroundContent
		
        addStartFormButton()
        addNoticeSection()
        addConditionsSection()
        addPassToInsurancePlanSection()
                
        view.addSubview(operationStatusView)
        operationStatusView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: operationStatusView, in: view))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if scrollView.contentInset.bottom != actionButtonsStackView.bounds.height {
            scrollView.contentInset.bottom = actionButtonsStackView.bounds.height
        }
    }
    
    private func addStartFormButton() {
        let startFormButton = RoundEdgeButton()
        startFormButton <~ Style.RoundedButton.oldPrimaryButtonSmall
                
        startFormButton.setTitle(
            NSLocalizedString("dms_cost_recovery_start_form", comment: ""),
            for: .normal
        )
        startFormButton.addTarget(self, action: #selector(startFormTap), for: .touchUpInside)
        startFormButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startFormButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
        ])
        
        actionButtonsStackView.addArrangedSubview(startFormButton)
        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 18, right: 18)
    }
    
    @objc func startFormTap(_ sender: UIButton) {
        output.startedForm()
    }
    
    private func addNoticeSection() {
        let noticeContainer = UIView()
        noticeLabel <~ Style.Label.secondaryCaption1
        noticeLabel.numberOfLines = 0
        noticeContainer.addSubview(noticeLabel)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: noticeLabel,
                in: noticeContainer,
                margins: UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
            )
        )
        contentStackView.addArrangedSubview(noticeContainer)
    }
    
    private func addConditionsSection() {
        let conditionsContainer = UIView()
        contentStackView.addArrangedSubview(conditionsContainer)
        conditionsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let conditionsTitleLabel = UILabel()
        conditionsTitleLabel.text = NSLocalizedString("dms_cost_recovery_necessary_conditions_title", comment: "")
        conditionsContainer.addSubview(conditionsTitleLabel)
        conditionsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        conditionsTitleLabel <~ Style.Label.secondaryHeadline2
        conditionsTitleLabel.numberOfLines = 0
        
        conditionsStackView.translatesAutoresizingMaskIntoConstraints = false
        conditionsStackView.axis = .vertical
        conditionsStackView.layer.cornerRadius = 12
        conditionsStackView.clipsToBounds = true
        conditionsStackView.spacing = 15
        
		conditionsStackView.backgroundColor = .Background.backgroundSecondary
        
        conditionsStackView.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        conditionsStackView.isLayoutMarginsRelativeArrangement = true

        let conditionsStackCardView = CardView(contentView: conditionsStackView)
        conditionsStackCardView.translatesAutoresizingMaskIntoConstraints = false
        conditionsContainer.addSubview(conditionsStackCardView)
        
        NSLayoutConstraint.activate(
            [
                conditionsTitleLabel.topAnchor.constraint(equalTo: conditionsContainer.topAnchor),
                conditionsTitleLabel.rightAnchor.constraint(equalTo: conditionsContainer.rightAnchor, constant: -18),
                conditionsTitleLabel.leadingAnchor.constraint(equalTo: conditionsContainer.leadingAnchor, constant: 18),

                conditionsStackCardView.topAnchor.constraint(equalTo: conditionsTitleLabel.bottomAnchor, constant: 15),
                conditionsStackCardView.rightAnchor.constraint(equalTo: conditionsContainer.rightAnchor, constant: -18),
                conditionsStackCardView.leadingAnchor.constraint(equalTo: conditionsContainer.leadingAnchor, constant: 18),
                conditionsStackCardView.bottomAnchor.constraint(equalTo: conditionsContainer.bottomAnchor),
            ]
        )
    }
    
    private func addPassToInsurancePlanSection() {
        let passToInsurancePlanCardView = CardView(contentView: passToInsurancePlanView)
        
        passToInsurancePlanContainerView.addSubview(passToInsurancePlanCardView)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: passToInsurancePlanCardView,
                in: passToInsurancePlanContainerView,
                margins: UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
            )
        )
        contentStackView.addArrangedSubview(passToInsurancePlanContainerView)
        passToInsurancePlanContainerView.isHidden = true
    }
    
    private func update() {
        switch input.getState() {
            case .loading:
                operationStatusView.isHidden = false
                let state: OperationStatusView.State = .loading(.init(
                    title: NSLocalizedString("dms_cost_recovery_necessary_conditions_loading_text", comment: ""),
                    description: nil,
                    icon: nil
                ))
                operationStatusView.notify.updateState(state)
            case .failure:
                let state: OperationStatusView.State = .info(.init(
                    title: NSLocalizedString("dms_cost_recovery_necessary_conditions_loading_error_title", comment: ""),
                    description: NSLocalizedString("dms_cost_recovery_necessary_conditions_loading_error_description", comment: ""),
                    icon: UIImage(named: "icon-common-failure")
                ))
                
                let buttons: [OperationStatusView.ButtonConfiguration] = [
                    .init(
                        title: NSLocalizedString("common_go_to_chat", comment: ""),
                        isPrimary: false,
                        action: {
                            self.output.goToChat()
                        }
                    ),
                    .init(
                        title: NSLocalizedString("common_retry", comment: ""),
                        isPrimary: true,
                        action: {
                            self.output.retryToGetData()
                        }
                    )
                ]
                operationStatusView.notify.updateState(state)
                operationStatusView.notify.buttonConfiguration(buttons)
            case .data(let info):
                operationStatusView.isHidden = true
                scrollView.isHidden = false
                
                noticeLabel.text = info.notice ?? ""
 
                for view in conditionsStackView.subviews{
                    view.removeFromSuperview()
                }
                
                for condition in info.conditions {
                    let conditionView = DmsCostRecoveryConditionView()
                    conditionView.configure(
                        digit: String(condition.stepNumber),
                        title: condition.title
                    )
                    conditionsStackView.addArrangedSubview(conditionView)
                }
                
                if let insurancePlan = info.insurancePlan {
                    passToInsurancePlanContainerView.isHidden = false
                    passToInsurancePlanView.configure(
                        title: insurancePlan.title,
                        description: insurancePlan.description,
                        iconImage: UIImage(named: "insurance-action-manual") ?? UIImage(),
                        tapHandler: { [weak self] in
                            
                            guard let url = URL(string: insurancePlan.urlPath)
                            else { return }
                            
                            self?.output.passToInsurancePlan(url)
                        }
                    )
                } else {
                    passToInsurancePlanContainerView.isHidden = true
                }
        }
    }
    
    struct Constants {
        static let buttonHeight: CGFloat = 48
    }
}
