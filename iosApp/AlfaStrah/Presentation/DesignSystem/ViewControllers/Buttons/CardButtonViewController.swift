//
//  CardButtonViewController.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 15.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class CardButtonViewController: ViewController {
    struct Input {
        let title: String
    }

    var input: Input!

    private let scrollView: UIScrollView = .init()
    private let scrollContentView: UIView = .init()
    private lazy var rootStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        title = input.title
        view.backgroundColor = Style.Color.background

        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(rootStackView)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: scrollView, in: view) +
            NSLayoutConstraint.fill(view: scrollContentView, in: scrollView) +
            NSLayoutConstraint.fill(view: rootStackView, in: scrollContentView, margins: Style.Margins.defaultInsets) +
                [ scrollContentView.widthAnchor.constraint(equalTo: view.widthAnchor) ]
        )

        let icon = UIImage(named: "icon-europrotocol-add-participant")
        let cardButton = CardHorizontalButton()
        let cardTitle = NSLocalizedString("design_system_add_new_element", comment: "")
        cardButton.set(title: cardTitle, icon: icon)

        let cardVerticalButton = CardVerticalButton()
        let cardVerticalTitle = NSLocalizedString("design_system_add_new_element", comment: "")
        cardVerticalButton.set(title: cardVerticalTitle, icon: icon)
        cardVerticalButton.tapHandler = { print("cardVerticalButton did tap") }

        rootStackView.addArrangedSubview(CardView(contentView: cardButton))
        rootStackView.addArrangedSubview(CardView(contentView: cardVerticalButton))
    }
}
