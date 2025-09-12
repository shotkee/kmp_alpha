//
//  ChatBubbleView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 18.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class ChatBubbleView: UIView {
    var radius: CGFloat = 16
    var direction: Direction = .none
    var createsMaskLayer = true

    var getMessageActions: (() -> MessageActions?)?

    enum Direction {
        case none
        case left
        case right
    }

    init(frame: CGRect, radius: CGFloat, direction: Direction) {
        self.radius = radius
        self.direction = direction

        super.init(frame: frame)

        update()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        update()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        update()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        update()
    }

    func update() {
        if !createsMaskLayer {
            layer.mask = nil
            layer.masksToBounds = false
            return
        }

        let path: UIBezierPath
        switch direction {
            case .none:
                 path = UIBezierPath(
                    roundedRect: bounds,
                    byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
                    cornerRadii: CGSize(width: radius, height: radius)
                )
            case .left:
                path = UIBezierPath(
                    roundedRect: bounds,
                    byRoundingCorners: [.topLeft, .bottomLeft, .bottomRight],
                    cornerRadii: CGSize(width: radius, height: radius)
                )
            case .right:
                path = UIBezierPath(
                    roundedRect: bounds,
                    byRoundingCorners: [.topRight, .bottomLeft, .bottomRight],
                    cornerRadii: CGSize(width: radius, height: radius)
                )
        }

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.masksToBounds = true
        layer.mask = maskLayer
    }

    func getActionMenuItems() -> [UIMenuItem] {
        let messageActions = getMessageActions?()

        var menuItems: [UIMenuItem] = []

        if messageActions?.reply != nil {
            let replyMenuItem = UIMenuItem(
                title: NSLocalizedString("chat_action_reply_to_message", comment: ""),
                action: #selector(reply)
            )
            menuItems.append(replyMenuItem)
        }

        if messageActions?.edit != nil {
            let editMenuItem = UIMenuItem(
                title: NSLocalizedString("chat_action_edit_message", comment: ""),
                action: #selector(edit)
            )
            menuItems.append(editMenuItem)
        }
		
		if messageActions?.copy != nil {
			let copyMenuItem = UIMenuItem(
				title: NSLocalizedString("chat_action_copy_message", comment: ""),
				action: #selector(edit)
			)
			menuItems.append(copyMenuItem)
		}

		if messageActions?.delete != nil {
			let deleteMenuItem = UIMenuItem(
				title: NSLocalizedString("chat_action_delete_message", comment: ""),
				action: #selector(edit)
			)
			menuItems.append(deleteMenuItem)
		}
		
		if messageActions?.retryOperation != nil {
			let retryMenuItem = UIMenuItem(
				title: NSLocalizedString("chat_files_retry_download", comment: ""),
				action: #selector(edit)
			)
			menuItems.append(retryMenuItem)
		}
		
		if messageActions?.downloadAttachment != nil {
			let downloadMenuItem = UIMenuItem(
				title: NSLocalizedString("common_download", comment: ""),
				action: #selector(edit)
			)
			menuItems.append(downloadMenuItem)
		}

        return menuItems
    }

    // MARK: - UIResponder

    override var canBecomeFirstResponder: Bool {
        true
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let messageActions = getMessageActions?()

        switch action {
            case #selector(UIResponderStandardEditActions.copy(_:)):
                return messageActions?.copy != nil
            case #selector(UIResponderStandardEditActions.delete(_:)):
                return messageActions?.delete != nil
            case #selector(ChatBubbleView.reply):
                return messageActions?.reply != nil
            case #selector(ChatBubbleView.edit):
                return messageActions?.edit != nil
            default:
                return false
        }
    }

    // MARK: - UIResponderStandardEditActions

    override func copy(_ sender: Any?) {
        getMessageActions?()?.copy?()
    }

    override func delete(_ sender: Any?) {
        getMessageActions?()?.delete?()
    }

    @objc private func reply() {
        getMessageActions?()?.reply?()
    }

    @objc private func edit() {
        getMessageActions?()?.edit?()
    }
}
