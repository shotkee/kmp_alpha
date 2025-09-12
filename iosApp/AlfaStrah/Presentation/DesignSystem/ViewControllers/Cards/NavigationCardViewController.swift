//
//  NavigationCardViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 21.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class NavigationCardViewController: ViewController {
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
        let subtitle: String
        let icon: UIImage?
        let stateAppearance: NavigationCardView.StateAppearance
        let isEnabled: Bool
    }

    private func setupUI() {
        [
            CardDataSource(
                cardType: "Enabled filled",
                title: "Title",
                subtitle: "Subtitle",
                icon: UIImage(named: "right_arrow_icon_gray"),
                stateAppearance: .regular,
                isEnabled: true
            ),
            CardDataSource(
                cardType: "Enabled filled long",
                title: "Title",
                subtitle: "Subtitle subtitle subtitle subtitle subtitle subtitle subtitle subtitle subtitle subtitle subtitle" +
                " subtitle subtitle subtitle subtitle subtitle subtitle subtitle subtitle subtitle subtitle subtitle",
                icon: UIImage(named: "right_arrow_icon_gray"),
                stateAppearance: .regular,
                isEnabled: true
            ),
            CardDataSource(
                cardType: "Disabled filled",
                title: "Title",
                subtitle: "Subtitle",
                icon: UIImage(named: "right_arrow_icon_gray"),
                stateAppearance: .regular,
                isEnabled: false
            ),
        ].forEach {
            rootStackView.addArrangedSubview(spacer(24))

            let cardTypeTitle = UILabel()
            cardTypeTitle.text = $0.cardType
            cardTypeTitle <~ Style.Label.secondaryCaption1
            rootStackView.addArrangedSubview(cardTypeTitle)
            rootStackView.addArrangedSubview(spacer(6))

            let cardView = NavigationCardView()
            cardView.set(
                title: $0.title,
                subtitle: $0.subtitle,
                icon: $0.icon,
                stateAppearance: $0.stateAppearance,
                isEnabled: $0.isEnabled
            )
            rootStackView.addArrangedSubview(CardView(contentView: cardView))
        }
    }
}
