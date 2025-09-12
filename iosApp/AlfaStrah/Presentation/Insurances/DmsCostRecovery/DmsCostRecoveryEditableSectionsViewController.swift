//
//  DmsCostRecoveryEditableSectionsViewController.swift
//  AlfaStrah
//
//  Created by vit on 12.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class DmsCostRecoveryEditableSectionsViewController: ViewController {
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var contentStackView: UIStackView!
    @IBOutlet private var actionButtonsStackView: UIStackView!
    private let sectionsView = SectionsCardView()
    private let actionButton = RoundEdgeButton()
    
    struct Notify {
        var updateItems: (_ filled: Bool) -> Void
    }

    // swiftlint:disable:next trailing_closure
    private(set) lazy var notify = Notify(
        updateItems: { [weak self] filled in
            guard let self = self
            else { return }
            self.sectionsView.updateItems(self.input.items())
            self.actionButton.isEnabled = filled
        }
    )
    
    struct Input {
        let title: String
        let filled: Bool
        let items: () -> [SectionsCardView.Item]
    }
    
    var input: Input!
    
    struct Output {
        let actionButtonTap: () -> Void
    }
    
    var output: Output!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
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
        
        title = input.title
        
        sectionsView.updateItems(input.items())

        contentStackView.addArrangedSubview(sectionsView)
        
        setupActionButton()
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
        
        self.actionButton.isEnabled = input.filled
    }
    
    @objc func actionButtonTap(_ sender: UIButton) {
        output.actionButtonTap()
    }
    
    struct Constants {
        static let buttonHeight: CGFloat = 48
    }
}
