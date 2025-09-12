//
//  DmsCostRecoveryApplicationPreviewViewController.swift
//  AlfaStrah
//
//  Created by vit on 16.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class DmsCostRecoveryApplicationPreviewViewController: UIViewController {
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentStackView: UIStackView!
    @IBOutlet private var actionButtonsStackView: UIStackView!
    
    struct Output {
        let applicationPreview: () -> Void
        let editApplication: () -> Void
        let confirmApplication: () -> Void
    }
    
    var output: Output!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
		view.backgroundColor = .Background.backgroundContent
        addApplicationDocumentPreviewSection()
        addNoticeSection()
        
        addActionButton(
            title: NSLocalizedString("dms_cost_recovery_return_to_application_form", comment: ""),
            selector: #selector(backToApplicationFormButtonTap),
            style: Style.RoundedButton.oldOutlinedButtonSmall
        )
        
        addActionButton(
            title: NSLocalizedString("dms_cost_recovery_confirm_application", comment: ""),
            selector: #selector(confirmApplicationButtonTap),
            style: Style.RoundedButton.oldPrimaryButtonSmall
        )
        
        actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
        actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 18, right: 18)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if scrollView.contentInset.bottom != actionButtonsStackView.bounds.height {
            scrollView.contentInset.bottom = actionButtonsStackView.bounds.height
        }
    }
    
    private func addApplicationDocumentPreviewSection() {
        let containerView = UIView()
        let applicationDocumentPreviewView = DocumentCardView()

        applicationDocumentPreviewView.configure(
            title: NSLocalizedString("dms_cost_recovery_application", comment: ""),
			iconImage: .Icons.documentDownload.tintedImage(withColor: .Icons.iconAccent),
            tapHandler: output.applicationPreview
        )
        
        containerView.addSubview(applicationDocumentPreviewView.embedded(hasShadow: true))

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: applicationDocumentPreviewView,
                in: containerView,
                margins: UIEdgeInsets(top: 6, left: 18, bottom: 24, right: 18)
            )
        )
        contentStackView.addArrangedSubview(containerView)
    }
        
    private func addNoticeSection() {
        let noticeContainer = UIView()
        let noticeLabel = UILabel()
        noticeLabel <~ Style.Label.secondaryText
        noticeLabel.numberOfLines = 0
        noticeLabel.text = NSLocalizedString("dms_cost_recovery_application_preview_notice", comment: "")
        noticeContainer.addSubview(noticeLabel)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: noticeLabel,
                in: noticeContainer,
                margins: UIEdgeInsets(top: 0, left: 18, bottom: 24, right: 18)
            )
        )
        contentStackView.addArrangedSubview(noticeContainer)
    }
    
    private func addActionButton(title: String, selector: Selector, style: Style.RoundedButton.ColoredButton) {
        let actionButton = RoundEdgeButton()
        actionButton <~ style
                
        actionButton.setTitle(title, for: .normal)
        actionButton.addTarget(self, action: selector, for: .touchUpInside)
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
        ])
        
        actionButtonsStackView.addArrangedSubview(actionButton)
    }
    
    @objc func confirmApplicationButtonTap(_ sender: UIButton) {
        output.confirmApplication()
    }
    
    @objc func backToApplicationFormButtonTap(_ sender: UIButton) {
        output.editApplication()
    }
    
    struct Constants {
        static let buttonHeight: CGFloat = 48
    }
}
