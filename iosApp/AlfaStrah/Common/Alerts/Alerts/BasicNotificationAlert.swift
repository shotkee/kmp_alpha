//
//  BasicNotificationAlert.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 27/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

class BasicNotificationAlert: NSObject, NotificationAlert {
    var action: (() -> Void)?
    var hideAction: (() -> Void)?
    var important: Bool {
        false
    }
    var unique: Bool {
        false
    }

    private(set) var view: UIView = UIView()
    private(set) var label: UILabel = UILabel()
    var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    private var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    private var swipeGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer()

    private(set) var sound: String?

    var textColor: UIColor {
        Style.Color.Palette.white
    }

    private var attributedText: NSAttributedString?

    @objc init(title: String? = nil, text: String, sound: String? = nil, action: (() -> Void)? = nil) {
        self.sound = sound
        self.action = action

        super.init()

        setupUI()
        setupContent(title: title, text: text)
        updateContent()
    }

    private func setupContent(title: String? = nil, text: String) {
        let attributedText = NSMutableAttributedString()

        if let title = title {
            var titleStyle = Style.TextAttributes.taskAlertTitle
            titleStyle[.foregroundColor] = textColor
            attributedText.append("\(title)\n" <~ titleStyle)
        }

        var textStyle = Style.TextAttributes.taskAlertText
        textStyle[.foregroundColor] = textColor
        attributedText.append(text <~ textStyle)

        self.attributedText = attributedText
    }

    func setupUI() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Style.Color.Palette.black
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .vertical)
        view.addSubview(label)

        let line = HairLineView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.bottomRight = true
        view.addSubview(line)

        let margin = Style.Margins.default

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: margin).with(priority: .required - 1),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin).with(priority: .required - 1),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin).with(priority: .required - 1),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin).with(priority: .required - 1),
            line.heightAnchor.constraint(equalToConstant: 1),
            line.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            line.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        tapGesture.addTarget(self, action: #selector(tap))
        view.addGestureRecognizer(tapGesture)

        swipeGesture.direction = .up
        swipeGesture.addTarget(self, action: #selector(swipe))
        view.addGestureRecognizer(swipeGesture)
    }

    @objc private func tap() {
        hideAction?()
        action?()
    }

    @objc private func swipe() {
        hideAction?()
    }

    private func updateContent() {
        label.attributedText = attributedText
    }
}
