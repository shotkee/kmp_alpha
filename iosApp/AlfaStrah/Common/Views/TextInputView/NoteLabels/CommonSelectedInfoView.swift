//
//  CommonSelectedLabelView.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 08.04.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class CommonSelectedInfoView: UIView {
    struct Appearance {
        let textStyle: Style.Label.ColoredLabel

        private enum Constants {
            static let defaultTextStyle = Style.Label.primaryText
        }

        init(textStyle: Style.Label.ColoredLabel = Constants.defaultTextStyle) {
            self.textStyle = textStyle
        }
				
        static let regular = Appearance()
    }

    private lazy var rootStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.alignment = .center
        value.axis = .horizontal
        value.spacing = 18
        return value
    }()

    private lazy var textLabel: UILabel = {
        let value: UILabel = .init(frame: .zero)
        value.textAlignment = .left
        value.numberOfLines = 0
        return value
    }()

    private lazy var selectedImageView: UIImageView = .init(frame: .zero)

	private lazy var separatorView: UIView = {
		let separator = UIView(frame: .zero)
		separator.backgroundColor = .Stroke.divider
        return separator
    }()

    var tapHandler: (() -> Void)?

    private var isSelected: Bool = false

    private var appearance: Appearance = .regular
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
		selectedImageView.contentMode = .center

        addSubview(rootStackView)
        addSubview(separatorView)

        rootStackView.addArrangedSubview(textLabel)
        rootStackView.addArrangedSubview(selectedImageView)

        separatorView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.translatesAutoresizingMaskIntoConstraints = false

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        addGestureRecognizer(tapGestureRecognizer)

        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: topAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            rootStackView.leftAnchor.constraint(equalTo: leftAnchor),
            rootStackView.rightAnchor.constraint(equalTo: rightAnchor),

            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leftAnchor.constraint(equalTo: leftAnchor),
            separatorView.rightAnchor.constraint(equalTo: rightAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            selectedImageView.heightAnchor.constraint(equalToConstant: 24),
            selectedImageView.widthAnchor.constraint(equalToConstant: 24)
        ])

        updateUI()
    }

    private func updateUI() {
        rootStackView.layoutMargins = margins

        textLabel <~ appearance.textStyle
        textLabel.text = text
        textLabel.isHidden = text == nil

		selectedImageView.image = isSelected ? .Icons.tick
			.tintedImage(withColor: .Icons.iconAccent)
			.resized(newWidth: 22) : nil
    }

    func set(
        item: SelectableItem,
        margins: UIEdgeInsets = .zero,
        appearance: Appearance = .regular,
        showSeparator: Bool = false
    ) {
        self.text = item.title
        self.margins = margins
        self.appearance = appearance
        self.separatorView.isHidden = !showSeparator
        self.isSelected = item.isSelected

        updateUI()
    }

    func update(isSelected: Bool) {
        self.isSelected = isSelected
        
        updateUI()
    }
    
    func update(title: String) {
        self.text = title
        
        updateUI()
    }

    @objc private func viewTap() {
        tapHandler?()
        updateUI()
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		let image = selectedImageView.image
		
		selectedImageView.image = image?.tintedImage(withColor: .Icons.iconAccent)
	}
}
