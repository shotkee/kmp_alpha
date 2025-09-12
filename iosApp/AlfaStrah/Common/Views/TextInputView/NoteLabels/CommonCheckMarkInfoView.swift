//
//  CommonCheckMarkInfoView.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 26.03.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class CommonCheckMarkInfoView: UIView {
    struct Appearance {
        let titleStyle: Style.Label.ColoredLabel
        let textStyle: Style.Label.ColoredLabel

        private enum Constants {
            static let defaultTitleStyle = Style.Label.primaryHeadline3
            static let defaultTextStyle = Style.Label.secondaryText
        }

        init(
            titleStyle: Style.Label.ColoredLabel = Constants.defaultTitleStyle,
            textStyle: Style.Label.ColoredLabel = Constants.defaultTextStyle
        ) {
            self.titleStyle = titleStyle
            self.textStyle = textStyle
        }

        static let bold = Appearance()
    }

    private lazy var rootStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .top
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = 20

        return stack
    }()

    private lazy var contentStackView: UIStackView = {
        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 4

        return stack
    }()

    private lazy var titleLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.numberOfLines = 0

        return label
    }()

    private lazy var textLabel: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.numberOfLines = 0

        return label
    }()

    private lazy var checkboxButton: CommonCheckboxButton = {
        let checkboxButton = CommonCheckboxButton()
		checkboxButton.addTarget(self, action: #selector(checkButtonTap(_:)), for: .touchUpInside)

        return checkboxButton
    }()

    var tapHandler: (() -> Void)?

    var isChecked: Bool {
        checkboxButton.isSelected
    }

    private var appearance: Appearance = .bold
    private var title: String?
    private var text: String?
    private var margins: UIEdgeInsets = .zero

    // MARK: Init

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonSetup()
    }

    private func commonSetup() {
		backgroundColor = .clear

        addSubview(rootStackView)

        let stack: UIStackView = .init(frame: .zero)
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 0

        let spacerView = UIView()
        spacerView.backgroundColor = .clear
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        stack.addArrangedSubview(spacerView)
        stack.addArrangedSubview(checkboxButton)

        rootStackView.addArrangedSubview(stack)
        rootStackView.addArrangedSubview(contentStackView)

        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(textLabel)

        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(checkButtonTap(_:)))
        addGestureRecognizer(tapGestureRecognizer)

        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: topAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            rootStackView.leftAnchor.constraint(equalTo: leftAnchor),
            rootStackView.rightAnchor.constraint(equalTo: rightAnchor),

            checkboxButton.heightAnchor.constraint(equalToConstant: 24),
            checkboxButton.widthAnchor.constraint(equalToConstant: 24)
        ])

        updateUI()
    }

    private func updateUI() {
        rootStackView.layoutMargins = margins

        titleLabel <~ appearance.titleStyle
        titleLabel.text = title
        titleLabel.isHidden = title == nil

        textLabel <~ appearance.textStyle
        textLabel.text = text
        textLabel.isHidden = text == nil
    }

    func set(
        title: String?,
        text: String,
        margins: UIEdgeInsets = .zero,
        appearance: Appearance = .bold
    ) {
        self.title = title
        self.text = text
        self.margins = margins
        self.appearance = appearance

        updateUI()
    }

    @objc private func checkButtonTap(_ sender: UIButton) {
        checkboxButton.isSelected.toggle()
        tapHandler?()
    }

    @objc private func viewTap() {
        checkboxButton.isSelected.toggle()
        tapHandler?()
    }
}
