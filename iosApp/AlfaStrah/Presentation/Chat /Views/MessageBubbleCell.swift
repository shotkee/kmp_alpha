//
//  MessageBubbleCell
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 17.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

/// Table view cell for message bubble.
class MessageBubbleCell: MessageCell,
						 ImageLoaderDependency,
						 ChatServiceDependency,
						 UIContextMenuInteractionDelegate {
	var chatService: ChatService!
    private(set) var message: Message?
    private(set) var isMine: Bool = false
    private(set) var showAvatar: Bool = false
    private(set) var showName: Bool = false
    private(set) var showStatus: Bool = false
    private(set) var showSelection: Bool = false
    private(set) var getMessageActions: (() -> MessageActions?)?
    
    private(set) var linkAction: ((URL) -> (Void))?

    var imageLoader: ImageLoader!

    private lazy var avatarView: NetworkImageView = NetworkImageView()
    let nameLabel: UILabel = UILabel()
    let bubbleView: ChatBubbleView = ChatBubbleView()
    let statusImageView: UIImageView = UIImageView()
    let timeLabel: UILabel = UILabel()
	let errorLabel: UILabel = UILabel()

    private(set) var bubbleInsets: UIEdgeInsets = .zero

    private enum Constants {
        static let edgeInsets: UIEdgeInsets = UIEdgeInsets(
            top: 0,
            left: Style.Margins.default,
            bottom: 0,
            right: Style.Margins.default
        )
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupContextMenu()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setup() {
        super.setup()

        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.contentMode = .scaleAspectFill
        avatarView.backgroundColor = .clear
        avatarView.placeholder = .Icons.alfaInCircle.tintedImage(withColor: .Icons.iconAccent)
		
		avatarView.layer.cornerRadius = avatarView.bounds.width * 0.5
		avatarView.layer.masksToBounds = true

        contentView.addSubview(avatarView)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.clipsToBounds = true
        bubbleView.isUserInteractionEnabled = true
        contentView.addSubview(bubbleView)

        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(statusImageView)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timeLabel)
		
		errorLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(errorLabel)
		errorLabel <~ Style.Label.accentText
    }

    override func layoutSubviews() {
        super.layoutSubviews()

		avatarView.layer.cornerRadius = avatarView.bounds.width * 0.5
    }

    /// Sets up cell model.
    func set(
        message: Message?,
        isMine: Bool,
        showAvatar: Bool,
        showName: Bool,
        showStatus: Bool,
        getMessageActions: (() -> MessageActions?)?,
        linkAction: ((URL) -> Void)? = nil
    ) {
        let needsLayout = self.isMine != isMine
            || self.showAvatar != showAvatar
            || self.showName != showName
            || self.showStatus != showStatus

        self.message = message
        self.isMine = isMine
        self.showStatus = showStatus
        self.showName = showName
        self.showAvatar = showAvatar
        self.getMessageActions = getMessageActions
        self.linkAction = linkAction

        if needsLayout {
            layout()
        }
        dynamicStylize()
        update()

        bubbleView.getMessageActions = getMessageActions
    }
	
    private func setupContextMenu() {
        if #available(iOS 13.0, *) {
            addContextMenuInteraction()
        } else {
            addGestureRecognizerForShowingMenu()
        }
    }

    @available(iOS 13.0, *)
    private func addContextMenuInteraction() {
        let interaction = UIContextMenuInteraction(delegate: self)
        bubbleView.addInteraction(interaction)
    }

    // MARK: - UIContextMenuInteractionDelegate
    @available(iOS 13.0, *)
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let messageActions = getMessageActions?()
        else { return nil }

        var menuActions: [UIMenuElement] = []

        if let replyActionCallback = messageActions.reply {
            let replyAction = UIAction(
                title: NSLocalizedString("chat_action_reply_to_message", comment: ""),
                image: UIImage(systemName: "arrow.turn.up.left")
            ) { _ in
                replyActionCallback()
            }
            menuActions.append(replyAction)
        }

        if let copyActionCallback = messageActions.copy {
            let copyAction = UIAction(
                title: NSLocalizedString("chat_action_copy_message", comment: ""),
                image: UIImage(systemName: "square.on.square")
            ) { _ in
                copyActionCallback()
            }
            menuActions.append(copyAction)
        }

        if let editActionCallback = messageActions.edit {
            let editAction = UIAction(
                title: NSLocalizedString("chat_action_edit_message", comment: ""),
                image: UIImage(systemName: "square.and.pencil")
            ) { _ in
                editActionCallback()
            }
            menuActions.append(editAction)
        }

        if let deleteActionCallback = messageActions.delete {
            let deleteAction = UIAction(
                title: NSLocalizedString("chat_action_delete_message", comment: ""),
                image: UIImage(systemName: "trash")
            ) { _ in
                deleteActionCallback()
            }
            menuActions.append(deleteAction)
        }
		
		if let retryActionCallback = messageActions.retryOperation {
			if let message = self.message {
				let retryAction: UIAction
				if chatService.fileAttachment(for: message) != nil {
					retryAction = UIAction(
						title: NSLocalizedString("chat_files_retry_upload", comment: ""),
						image: UIImage(systemName: "square.and.arrow.up")
					) { _ in
						retryActionCallback()
					}
				} else {
					retryAction = UIAction(
						title: NSLocalizedString("chat_files_retry_download", comment: ""),
						image: UIImage(systemName: "square.and.arrow.down")
					) { _ in
						retryActionCallback()
					}
				}
				
				menuActions.append(retryAction)
			}
		}
		
		if let downloadActionCallback = messageActions.downloadAttachment {
			let downloadAction = UIAction(
				title: NSLocalizedString("common_download", comment: ""),
				image: UIImage(systemName: "square.and.arrow.down")
			) { _ in
				downloadActionCallback()
			}
			menuActions.append(downloadAction)
		}

        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { _ in
                UIMenu(
                    title: "",
                    children: menuActions
                )
            }
        )
    }

    private func addGestureRecognizerForShowingMenu() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(longPressHandler)
        )
        bubbleView.addGestureRecognizer(longPressGestureRecognizer)
    }

    @objc func longPressHandler(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began,
            let bubbleSuperview = bubbleView.superview
        else { return }

        _ = bubbleView.becomeFirstResponder()

        UIMenuController.shared.menuItems = bubbleView.getActionMenuItems()

        UIMenuController.shared.setTargetRect(bubbleView.frame, in: bubbleSuperview)
        UIMenuController.shared.setMenuVisible(true, animated: true)
    }

    static func hideFloatingMenuIfNeeded() {
        if #available(iOS 13.0, *) {} else {
            if UIMenuController.shared.isMenuVisible {
                UIMenuController.shared.setMenuVisible(false, animated: true)
            }
        }
    }

    override func staticStylize() {
        super.staticStylize()

        avatarView.backgroundColor = .Icons.iconContrast
        nameLabel <~ Style.Label.primaryCaption1
        timeLabel <~ Style.Label.secondaryCaption1
    }

    override func dynamicStylize() {
        super.dynamicStylize()

        bubbleView.backgroundColor = isMine ? .Background.backgroundAccent : .Background.backgroundTertiary
		avatarView.alpha = showAvatar ? 1 : 0
    }

    /// Updates UI.
    func update() {
        // Avatar
        avatarView.imageLoader = imageLoader
        avatarView.imageUrl = message?.getSenderAvatarFullURL()

        // Name
        nameLabel.text = message?.getSenderName()
        nameLabel.isHidden = !showName

        // Status
        if showStatus {
            switch message?.getSendStatus() {
                case .sending?:
                    statusImageView.image = UIImage(named: "icon-chat-sending-status")
                case .sent?:
                    if message?.isReadByOperator() ?? false {
                        statusImageView.image = UIImage(named: "icon-chat-read-status")
                    } else {
                        statusImageView.image = UIImage(named: "icon-chat-sent-status")
                    }
                case nil:
                    statusImageView.image = nil
            }
        }

        // Time
        timeLabel.text = (message?.getTime()).map(AppLocale.chatDateString)
    }

    // MARK: - Layout
	var bubbleMaxWidth: CGFloat = UIScreen.main.bounds.width * 2 / 3

    override func layout() {
        super.layout()

        layoutAvatar()
        layoutBubble()
        layoutContent()
    }

    /// Updates avatar layout.
    func layoutAvatar() {
        let width = avatarView.widthAnchor.constraint(equalToConstant: 42)
        let height = avatarView.heightAnchor.constraint(equalToConstant: 42)
        let horizontal = isMine
            ? avatarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.edgeInsets.right)
            : avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.edgeInsets.left)
        let vertical = avatarView.topAnchor.constraint(equalTo: bubbleView.topAnchor)

        add(constraints: [ width, height, horizontal, vertical ])
    }

    /// Updates message bubble layout.
    func layoutBubble() {
        bubbleView.radius = 10
        bubbleView.direction = isMine ? .left : .right

        let minWidth = bubbleView.widthAnchor.constraint(greaterThanOrEqualToConstant: 16)
        let minHeight = bubbleView.heightAnchor.constraint(greaterThanOrEqualToConstant: 32)

        let top: NSLayoutConstraint
        let leading: NSLayoutConstraint
        let trailing: NSLayoutConstraint

        if isMine {
            if showAvatar {
                trailing = bubbleView.trailingAnchor.constraint(equalTo: avatarView.leadingAnchor, constant: -5)
            } else {
                trailing = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.edgeInsets.right)
            }
            leading = bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: bubbleMaxWidth)
        } else {
			leading = bubbleView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 5)
            trailing = bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: bubbleMaxWidth)
        }
        if showName {
            top = bubbleView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5)
        } else {
            top = bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5)
        }

        let nameTop = nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3)
        let nameLeading: NSLayoutConstraint = nameLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor)
        let nameTrailing: NSLayoutConstraint = nameLabel.trailingAnchor.constraint(greaterThanOrEqualTo: bubbleView.trailingAnchor)

        let timeTop: NSLayoutConstraint = timeLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 5)
        let bottom: NSLayoutConstraint = timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        let timeHorizontal: NSLayoutConstraint
        if isMine {
            timeHorizontal = timeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor)
        } else {
            timeHorizontal = timeLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor)
        }

        let statusHorizontal: NSLayoutConstraint
        let statusYCenter = statusImageView.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor)
        if isMine {
            statusHorizontal = statusImageView.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor)
        } else {
            statusHorizontal = statusImageView.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor)
        }
		
		let errorHorizontal: NSLayoutConstraint
		let errorYCenter = errorLabel.centerYAnchor.constraint(equalTo: statusImageView.centerYAnchor)
		if isMine {
			errorHorizontal = errorLabel.trailingAnchor.constraint(equalTo: statusImageView.leadingAnchor, constant: -8)
		} else {
			errorHorizontal = errorLabel.leadingAnchor.constraint(equalTo: statusImageView.trailingAnchor, constant: 8)
		}
		
        add(constraints: [
            minHeight, minWidth, leading, trailing, top, bottom,
            nameTop, nameLeading, nameTrailing,
            timeTop, timeHorizontal,
            statusHorizontal, statusYCenter,
			errorHorizontal, errorYCenter
        ])
    }

    /// Updates content layout.
    func layoutContent() {}
    
    private var animationCounter: Int = 0
    
    func playAnimation(count: Int, completion: @escaping () -> Void) {
        flickerAnimation(count: count) { _ in
            completion()
        }
    }
    
    private func flickerAnimation(count: Int, completion: @escaping (Bool) -> Void) {
        animationCounter += 1
        
        if animationCounter <= count {
            let flickerHalfPeriodDuration = 0.25
            
            self.contentView.alpha = 1
            
            UIView.animate(
                withDuration: flickerHalfPeriodDuration,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.contentView.alpha = 0
                }
            ) { [weak self] _ in
                UIView.animate(
                    withDuration: flickerHalfPeriodDuration,
                    delay: 0,
                    options: .curveEaseOut,
                    animations: {
                        self?.contentView.alpha = 1
                    }
                ) { [weak self] _ in
                    self?.flickerAnimation(count: count, completion: completion)
                }
            }
        } else {
            animationCounter = 0
            completion(true)
        }
    }
    
    // MARK: - Dark Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        avatarView.placeholder = .Icons.alfaInCircle.tintedImage(withColor: .Icons.iconAccent).roundedImage
    }
}
