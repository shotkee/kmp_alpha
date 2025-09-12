//
//  ValueCardViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit

class ValueCardViewController: ViewController {
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
        let placeholder: String
        let value: String?
        let error: String?
        let icon: ValueCardView.IconPositionStyle
        let stateAppearance: ValueCardView.StateAppearance
        let isEnabled: Bool
    }

    // swiftlint:disable:next function_body_length
    private func setupUI() {
        [
            CardDataSource(
                cardType: "Enabled empty",
                title: "Title",
                placeholder: "Placeholder",
                value: nil,
                error: nil,
                icon: .rightArrow,
                stateAppearance: .regular,
                isEnabled: true
            ),
            CardDataSource(
                cardType: "Enabled empty error",
                title: "Title",
                placeholder: "Placeholder",
                value: nil,
                error: "Error message",
                icon: .rightArrow,
                stateAppearance: .regular,
                isEnabled: true
            ),
            CardDataSource(
                cardType: "Enabled empty long placeholder",
                title: "Title",
                placeholder: "Placeholder placeholder placeholder placeholder placeholder placeholder",
                value: nil,
                error: nil,
                icon: .rightArrow,
                stateAppearance: .regular,
                isEnabled: true
            ),
            CardDataSource(
                cardType: "Enabled empty top icon",
                title: "Title",
                placeholder: "Placeholder",
                value: nil,
                error: nil,
                icon: .top(UIImage(named: "right_arrow_icon_gray")),
                stateAppearance: .regular,
                isEnabled: true
            ),
            CardDataSource(
                cardType: "Disabled empty",
                title: "Title",
                placeholder: "Placeholder",
                value: nil,
                error: nil,
                icon: .rightArrow,
                stateAppearance: .regular,
                isEnabled: false
            ),
            CardDataSource(
                cardType: "Enabled filled",
                title: "Title",
                placeholder: "Placeholder",
                value: "Value",
                error: nil,
                icon: .rightArrow,
                stateAppearance: .regular,
                isEnabled: true
            ),
            CardDataSource(
                cardType: "Enabled filled long value",
                title: "Title",
                placeholder: "Placeholder",
                value: "Value value value value value value value value value value",
                error: nil,
                icon: .rightArrow,
                stateAppearance: .regular,
                isEnabled: true
            ),
            CardDataSource(
                cardType: "Enabled filled with error",
                title: "Title",
                placeholder: "Placeholder",
                value: "Value",
                error: "Ошибка нескольких полей: номер полиса ОСАГО, дата создания полиса" +
                "Ошибка нескольких полей: номер полиса ОСАГО, дата создания полиса" +
                "Ошибка нескольких полей: номер полиса ОСАГО, дата создания полиса" +
                "Ошибка нескольких полей: номер полиса ОСАГО, дата создания полиса",
                icon: .rightArrow,
                stateAppearance: .regular,
                isEnabled: true
            ),
            CardDataSource(
                cardType: "Disabled filled",
                title: "Title",
                placeholder: "Placeholder",
                value: "Value",
                error: nil,
                icon: .rightArrow,
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

            let cardView = ValueCardView()
            cardView.set(
                title: $0.title,
                placeholder: $0.placeholder,
                value: $0.value,
                error: $0.error,
                icon: $0.icon,
                stateAppearance: $0.stateAppearance,
                isEnabled: $0.isEnabled
            )
            rootStackView.addArrangedSubview(CardView(contentView: cardView))
        }
    }
}
