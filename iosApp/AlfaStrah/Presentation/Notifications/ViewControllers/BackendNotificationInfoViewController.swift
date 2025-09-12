//
//  BackendNotificationInfoViewController.swift
//  AlfaStrah
//
//  Created by vit on 11.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import MapKit
import Legacy

class BackendNotificationInfoViewController: ViewController {
    private struct Field {
        var title: String?
        var subtitle: String?
    }
    
    struct Input {
        let notification: BackendNotification
        let showActionButtonIsNeeded: (_ notification: BackendNotification) -> Bool
    }

    struct Output {
        var action: (BackendNotification) -> Void
    }

    var input: Input!
    var output: Output!

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let actionButton = RoundEdgeButton()
    private let actionButtonsStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("notifications_info_title", comment: "")
		view.backgroundColor = .Background.backgroundContent
        
        setupScrollView()
        setupContentStackView()
        setupActionButtonStackView()
    
        update()
    }

    @objc func actionButtonTap(_ sender: UIButton) {
        output.action(input.notification)
    }

    private func update() {
        let notification = input.notification
        
        setupMessage(notification: notification)
        
        if let action = notification.action,
           input.showActionButtonIsNeeded(notification)
        {
            actionButton.setTitle(
                action.title,
                for: .normal
            )
            
            setupActionButton()
            actionButtonsStackView.isHidden = false
        } else {
            actionButtonsStackView.isHidden = true
        }
    }
    
    private func setupActionButton() {
        actionButton <~ Style.RoundedButton.oldPrimaryButtonSmall
                
        actionButton.addTarget(self, action: #selector(actionButtonTap), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
        ])
        
        actionButtonsStackView.addArrangedSubview(actionButton)
    }

    private func setupMessage(notification: BackendNotification) {
        let view = NotificationInfoMessageView()
        view.set(date: notification.date, title: notification.title, content: notification.description)
        contentStackView.addArrangedSubview(view)
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: scrollView, in: view))
    }
    
    private func setupContentStackView() {
        scrollView.addSubview(contentStackView)
        
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.axis = .vertical
        contentStackView.spacing = 18
        contentStackView.backgroundColor = .clear
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: contentStackView, in: scrollView) +
            [ contentStackView.widthAnchor.constraint(equalTo: view.widthAnchor) ]
        )
    }
    
    private func setupActionButtonStackView() {
         view.addSubview(actionButtonsStackView)
         
         actionButtonsStackView.isLayoutMarginsRelativeArrangement = true
         actionButtonsStackView.layoutMargins = UIEdgeInsets(top: 32, left: 18, bottom: 18, right: 18)
         actionButtonsStackView.alignment = .fill
         actionButtonsStackView.distribution = .fill
         actionButtonsStackView.axis = .vertical
         actionButtonsStackView.spacing = 0
         actionButtonsStackView.backgroundColor = .clear
         
         actionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
         
         NSLayoutConstraint.activate([
             actionButtonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             actionButtonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             actionButtonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
         ])
    }
    
    struct Constants {
        static let buttonHeight: CGFloat = 48
    }
}
