//
//  NotificationCell
//  AlfaStrah
//
//  Created by Igor Bulyga on 11.08.15.
//  Copyright (c) 2015 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class NotificationCell: UITableViewCell {
    static let id: Reusable<NotificationCell> = .fromClass()
        
    private let contentStackView = UIStackView()
    private let containerView = UIView()
    private let stateView = UIView()
    private let titleTextView = UITextView()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let actionButton = RoundEdgeButton()
    
    private var moreHandler: (() -> Void)?
    private var actionHandler: (() -> Void)?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        formatter.locale = AppLocale.currentLocale
        return formatter
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    func setup() {
		selectionStyle = .none
		
		clipsToBounds = false
		contentView.clipsToBounds = false
		backgroundColor = .clear
		contentView.backgroundColor = .clear
        
        setupContainerView()
        setupContentStackView()
        setupStateView()
        setupTitleView()
        setupDescriptionView()
        setupDateView()
        setupActionButton()
    }
    
    private func setupContainerView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.backgroundColor = .Background.backgroundSecondary

        let cardView = containerView.embedded(
            margins: UIEdgeInsets(top: 7, left: 18, bottom: 7, right: 18),
            hasShadow: true,
            cornerRadius: 10
        )
        
        contentView.addSubview(cardView)
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: cardView, in: contentView)
        )
    }
    
    private func setupContentStackView() {
        contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = insets(15)
        contentStackView.spacing = 6
        contentStackView.axis = .vertical
        
        containerView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: contentStackView, in: containerView)
        )
    }

    private func setupStateView() {
        stateView.translatesAutoresizingMaskIntoConstraints = false

		stateView.backgroundColor = .Pallete.accentRed
        stateView.layer.cornerRadius = 3
        stateView.clipsToBounds = true

        titleTextView.addSubview(stateView)

        NSLayoutConstraint.activate([
            stateView.leadingAnchor.constraint(equalTo: titleTextView.leadingAnchor),
            stateView.heightAnchor.constraint(equalToConstant: Constants.stateMarkWidth),
            stateView.widthAnchor.constraint(equalTo: stateView.heightAnchor, multiplier: 1)
        ])
    }
    
    private func setupTitleView() {
        titleTextView.textContainer.lineFragmentPadding = .zero
        titleTextView.textContainerInset = .zero
        titleTextView.contentInset = .zero
		titleTextView.backgroundColor = .clear

        titleTextView <~ Style.TextView.primaryHeadline1
        titleTextView.isScrollEnabled = false
        titleTextView.isEditable = false
        titleTextView.isSelectable = false
        titleTextView.isUserInteractionEnabled = false
                
        contentStackView.addArrangedSubview(titleTextView)
    }
    
    private func setupDescriptionView() {
        descriptionLabel <~ Style.Label.primaryCaption1
        descriptionLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(descriptionLabel)
        contentStackView.addArrangedSubview(spacer(3))
    }
    
    private func setupDateView() {
        dateLabel <~ Style.Label.secondaryCaption1
        dateLabel.numberOfLines = 0
        contentStackView.addArrangedSubview(dateLabel)
        contentStackView.addArrangedSubview(spacer(12))
    }
    
    private func setupActionButton() {
        actionButton <~ Style.RoundedButton.redBackground
                
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
        ])
        
        contentStackView.addArrangedSubview(actionButton)
    }
    
    @objc private func moreTap() {
        moreHandler?()
    }
    
    @objc private func actionTap() {
        actionHandler?()
    }
    
    func set(
        notification: BackendNotification,
        showMore: @escaping () -> Void,
        showMoreButton: Bool,
        action: @escaping () -> Void,
        showActionButton: Bool
    ) {
        titleTextView.text = notification.title
        
        let descriptionText = notification.description
        
        setupNotificationCellText(notification, text: descriptionText)
        setupNotificationCellButton(notification, showMoreButton: showMoreButton, showActionButton: showActionButton)

        dateLabel.text = dateFormatter.string(from: notification.date)

        switch notification.status {
            case .read:
                appearance = .read
            case .unread:
                appearance = .unread
        }
        
        moreHandler = showMoreButton ? showMore : nil
        actionHandler = showActionButton ? action : nil
    }
    
    private func setupNotificationCellText(_ notification: BackendNotification, text: String) {

        descriptionLabel.text = text
                
        if text.count >= Constants.descriptionCharactersLimit {
            let index = text.index( text.startIndex, offsetBy: Constants.descriptionCharactersLimit)
            descriptionLabel.text = text[..<index].appending("...")
        }
        
        titleTextView.sizeToFit()
    }
    
    private func setupNotificationCellButton(_ notification: BackendNotification, showMoreButton: Bool, showActionButton: Bool) {
        if showMoreButton {
            actionButton.setTitle(
                NSLocalizedString("notifications_info_button_more_title", comment: ""),
                for: .normal
            )
            actionButton.addTarget(self, action: #selector(moreTap), for: .touchUpInside)
            actionButton.isHidden = false
        } else {
            if let action = notification.action,
               showActionButton {
                actionButton.addTarget(self, action: #selector(actionTap), for: .touchUpInside)
                actionButton.setTitle(action.title, for: .normal)
                actionButton.isHidden = false
            } else {
                actionButton.isHidden = true
            }
        }
    }
    
    func setIsRead() {
        appearance = .read
    }
    
    private var appearance: Appearance = .unread {
        didSet {
            updateUI()
        }
    }
    
    // MARK: Appearance
    struct Appearance {
        let titleColor: UIColor
        let descriptionColor: UIColor
        let statusIsVisible: Bool
                
        static let read: Appearance = Appearance(
			titleColor: .Text.textSecondary,
			descriptionColor: .Text.textSecondary,
            statusIsVisible: false
        )
        static let unread: Appearance = Appearance(
			titleColor: .Text.textPrimary,
			descriptionColor: .Text.textPrimary,
            statusIsVisible: true
        )
    }
        
    private func updateUI() {
        titleTextView.textColor = appearance.titleColor
        descriptionLabel.textColor = appearance.descriptionColor
        
        stateView.isHidden = !appearance.statusIsVisible
        
        if appearance.statusIsVisible {
            var offset: CGFloat = 0
                        
            if let pointSize = titleTextView.font?.pointSize {
                offset = pointSize / 2.0
            }
            
            NSLayoutConstraint.activate([
                titleTextView.firstBaselineAnchor.constraint(equalTo: stateView.centerYAnchor, constant: offset)
            ])
            
            var stateViewHeight: CGFloat = 1
            
            if let lineHeight = titleTextView.font?.lineHeight {
                stateViewHeight = lineHeight
            }
            
            let excludePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: Constants.stateMarkWidth + 6, height: stateViewHeight))
            
            titleTextView.textContainer.exclusionPaths.append(excludePath)
        } else {
            titleTextView.textContainer.exclusionPaths.removeAll()
        }
    }
	    
    struct Constants {
        static let descriptionCharactersLimit = 86
        static let stateMarkWidth: CGFloat = 6
        static let buttonHeight: CGFloat = 36
    }
}
