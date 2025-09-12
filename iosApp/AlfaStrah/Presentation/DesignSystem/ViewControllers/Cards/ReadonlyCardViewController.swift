//
//  ReadonlyCardViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 21.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class ReadonlyCardViewController: ViewController {
    private let scrollView: UIScrollView = .init()
    private let scrollContentView: UIView = .init()
    private let rootStackView: UIStackView = .init()

    struct Input {
        let title: String
    }

    var input: Input!

    override func viewDidLoad() {
        super.viewDidLoad()

        commonSetup()
        setupUI()
    }

    private func commonSetup() {
        title = input.title

        view.backgroundColor = Style.Color.Palette.white
        scrollView.backgroundColor = .clear
        scrollContentView.backgroundColor = .clear

        rootStackView.alignment = .fill
        rootStackView.axis = .vertical
        rootStackView.distribution = .fill
        rootStackView.spacing = 0

        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollContentView.addSubview(rootStackView)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(view: scrollView, in: view) +
            NSLayoutConstraint.fill(view: scrollContentView, in: scrollView) +
            NSLayoutConstraint.fill(view: rootStackView, in: scrollContentView, margins: Style.Margins.defaultInsets) +
            [ scrollContentView.widthAnchor.constraint(equalTo: view.widthAnchor) ]
        )
    }

    private struct CardDataSource {
        let cardType: String
        let title: String
        let value: String
        let icon: UIImage?
        let appearance: ReadonlyValueCardView.Appearance
    }

    private func setupUI() {
        [
            CardDataSource(
                cardType: "Filled",
                title: "Title",
                value: "Value",
                icon: UIImage(named: "icon-checkmark-red-small"),
                appearance: .regular
            ),
            CardDataSource(
                cardType: "Filled long value",
                title: "Title",
                value: "Value value value value value value value value value value value value value value value value value value",
                icon: UIImage(named: "icon-checkmark-red-small"),
                appearance: .regular
            ),
        ].forEach {
            rootStackView.addArrangedSubview(spacer(24))

            let cardTypeTitle = UILabel()
            cardTypeTitle.text = $0.cardType
            cardTypeTitle <~ Style.Label.secondaryCaption1
            rootStackView.addArrangedSubview(cardTypeTitle)
            rootStackView.addArrangedSubview(spacer(6))

            let cardView = ReadonlyValueCardView()
            cardView.set(
                title: $0.title,
                value: $0.value,
                icon: $0.icon,
                appearance: $0.appearance
            )
            rootStackView.addArrangedSubview(CardView(contentView: cardView))
        }
    }
}
