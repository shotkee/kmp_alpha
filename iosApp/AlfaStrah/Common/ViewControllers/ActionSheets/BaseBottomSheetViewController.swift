//
//  BaseBottomSheetViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 21.10.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

enum CharsInputLimits {
    case limited(Int)
    case unlimited

    var value: Int {
        switch self {
            case .limited(let limitValue):
                return limitValue
            case .unlimited:
                return Int.max
        }
    }

    var isNeedIndicatorShow: Bool {
        switch self {
            case .limited:
                return true
            case .unlimited:
                return false
        }
    }
}

enum CharsCounter
{
    case remaining(numLeftChars: Int)
    case enteredOutOfMax(numEnteredChars: Int, maxChars: Int)
}

class BaseBottomSheetViewController: ViewController, ActionSheetContentViewController {
    // MARK: Enum Style

    enum FooterStyle {
        case keyboard
        case actions(primaryButtonTitle: String, secondaryButtonTitle: String?)
        case empty

        static let picker: FooterStyle = .actions(
            primaryButtonTitle: NSLocalizedString("common_done_button", comment: ""),
            secondaryButtonTitle: nil
        )
    }

    // MARK: UI Components

    private lazy var backgroundView: UIView = {
        let value: UIView = .init(frame: .zero)
        value.backgroundColor = .Background.backgroundModal

        return value
    }()

    private lazy var rootStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.axis = .vertical
        value.alignment = .fill
        value.distribution = .fill
        value.spacing = 16

        return value
    }()

    private lazy var headerStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.axis = .vertical
        value.alignment = .leading
        value.distribution = .fill
        value.spacing = 16

        return value
    }()

    private lazy var inputStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.axis = .vertical
        value.alignment = .fill
        value.distribution = .fill
        value.spacing = 0

        return value
    }()

    private lazy var footerStackView: UIStackView = {
        let value: UIStackView = .init(frame: .zero)
        value.axis = .vertical
        value.alignment = .fill
        value.distribution = .fill
        value.spacing = 9

        return value
    }()

    private lazy var toolBarView: UIView = .init(frame: .zero)

    private lazy var titleLabel: UILabel = {
        let value: UILabel = .init(frame: .zero)
        value.numberOfLines = 0
		value <~ Style.Label.primaryTitle1

        return value
    }()

    private lazy var infoLabel: UILabel = {
        let value: UILabel = .init(frame: .zero)
        value.numberOfLines = 0
        value.isHidden = true
        value <~ Style.Label.secondaryText

        return value
    }()

    private lazy var charsLeftCounterLabel: UILabel = {
        let value: UILabel = .init(frame: .zero)
        value <~ Style.Label.tertiaryCaption1

        return value
    }()

    private lazy var closeButton: UIButton = {
        let value: UIButton = .init(frame: .zero)
        value.setImage(UIImage.Icons.cross, for: .normal)
        value.tintColor = .Icons.iconAccentThemed
        value.addTarget(self, action: #selector(closeTap), for: .touchUpInside)

        return value
    }()

    private lazy var toolBarDoneButton: RoundEdgeButton = {
        let value: RoundEdgeButton = .init(frame: .zero)

        value.setTitle(NSLocalizedString("common_done_button", comment: ""), for: .normal)
        value <~ Style.RoundedButton.redTitle
        value.addTarget(self, action: #selector(primaryTap), for: .touchUpInside)
        value.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)

        return value
    }()

    private lazy var pickerPrimaryButton: RoundEdgeButton = {
        let value: RoundEdgeButton = .init(frame: .zero)
        value.setTitle(NSLocalizedString("common_done_button", comment: ""), for: .normal)
        value.addTarget(self, action: #selector(primaryTap), for: .touchUpInside)
        value <~ Style.RoundedButton.oldPrimaryButtonSmall

        return value
    }()

    private lazy var pickerSecondaryButton: RoundEdgeButton = {
        let value: RoundEdgeButton = .init(frame: .zero)
        value.addTarget(self, action: #selector(secondaryTap), for: .touchUpInside)
        value <~ Style.RoundedButton.oldOutlinedButtonSmall

        return value
    }()

    // MARK: Private Variables

    private var style: FooterStyle = .keyboard

    // MARK: Handlers

    var animationWhileTransition: (() -> Void)?
    var closeTapHandler: (() -> Void)?
    var primaryTapHandler: (() -> Void)?
    var secondaryTapHandler: (() -> Void)?

    // MARK: Init

    override func viewDidLoad() {
        super.viewDidLoad()

        commonSetup()
        updateFooterStackUI()
		
		setupUI()
    }

    // MARK: Setup UI

    private func commonSetup() {
		view.backgroundColor = .Background.backgroundModal
		
        view.addSubview(backgroundView)
        backgroundView.addSubview(rootStackView)
        backgroundView.addSubview(closeButton)

        toolBarView.addSubview(charsLeftCounterLabel)
        toolBarView.addSubview(toolBarDoneButton)

        rootStackView.addArrangedSubview(headerStackView)
		rootStackView.addArrangedSubview(inputStackView)
		rootStackView.setCustomSpacing(
			32,
			after: inputStackView
		)
        rootStackView.addArrangedSubview(footerStackView)

        // This constrains view height in case if no other views are added as inputs
        let zeroHeightView = UIView()
        zeroHeightView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        inputStackView.addArrangedSubview(zeroHeightView)

        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(infoLabel)

        footerStackView.addArrangedSubview(toolBarView)
        footerStackView.addArrangedSubview(pickerSecondaryButton)
        footerStackView.addArrangedSubview(pickerPrimaryButton)

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        toolBarDoneButton.translatesAutoresizingMaskIntoConstraints = false
        charsLeftCounterLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			
            rootStackView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -18),
            rootStackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -18),
            rootStackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 18),

            closeButton.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: -10),
            closeButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -8),
            closeButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.widthAnchor.constraint(equalToConstant: 44),

            toolBarDoneButton.bottomAnchor.constraint(equalTo: toolBarView.bottomAnchor),
            toolBarDoneButton.trailingAnchor.constraint(equalTo: toolBarView.trailingAnchor),
            toolBarDoneButton.heightAnchor.constraint(equalToConstant: 24),

            charsLeftCounterLabel.bottomAnchor.constraint(equalTo: toolBarView.bottomAnchor),
            charsLeftCounterLabel.leadingAnchor.constraint(equalTo: toolBarView.leadingAnchor),
            charsLeftCounterLabel.heightAnchor.constraint(equalToConstant: 24),
            charsLeftCounterLabel.trailingAnchor.constraint(lessThanOrEqualTo: toolBarDoneButton.leadingAnchor),

            toolBarView.heightAnchor.constraint(equalToConstant: 24),

            pickerPrimaryButton.heightAnchor.constraint(equalToConstant: 48),
            pickerSecondaryButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    func setupUI() {}

    private func updateFooterStackUI() {
        switch style {
            case .keyboard:
                toolBarView.isHidden = false
                pickerPrimaryButton.isHidden = true
                pickerSecondaryButton.isHidden = true
            case .actions(let primaryTitle, let secondaryTitle):
                pickerPrimaryButton.setTitle(primaryTitle, for: .normal)
                pickerSecondaryButton.setTitle(secondaryTitle, for: .normal)
                toolBarView.isHidden = true
                pickerPrimaryButton.isHidden = false
                pickerSecondaryButton.isHidden = secondaryTitle == nil
            case .empty:
                toolBarView.isHidden = true
                pickerPrimaryButton.isHidden = true
                pickerSecondaryButton.isHidden = true
        }
    }

    // MARK: Set Actions

    func set(title: String) {
        titleLabel.text = title
    }

    func set(style: FooterStyle) {
        self.style = style
        updateFooterStackUI()
    }
    
    func set(infoText: String) {
        infoLabel.isHidden = infoText.isEmpty
        infoLabel.text = infoText
    }
    
    func set(attributedInfoText: NSAttributedString) {
        infoLabel.isHidden = attributedInfoText.string.isEmpty
        self.infoLabel.attributedText = attributedInfoText
    }

    func set(doneButtonEnabled: Bool) {
        toolBarDoneButton.isEnabled = doneButtonEnabled
        pickerPrimaryButton.isEnabled = doneButtonEnabled
    }

    func set(charsLeftCounter: Int?, isVisible: Bool = true ) {
        charsLeftCounterLabel.isHidden = (charsLeftCounter == nil || !isVisible)
        charsLeftCounterLabel.text = "\(charsLeftCounter ?? 0)"
    }

    func set(charsCounter: CharsCounter?)
    {
        switch charsCounter
        {
            case .none:
                charsLeftCounterLabel.isHidden = true

            case .remaining(let numLeftChars):
                charsLeftCounterLabel.isHidden = false
                charsLeftCounterLabel.text = "\(numLeftChars)"

            case .enteredOutOfMax(let numEnteredChars, let maxChars):
                charsLeftCounterLabel.isHidden = false
                charsLeftCounterLabel.text = "\(numEnteredChars)/\(maxChars)"
        }
    }

    func set(views: [UIView]) {
        inputStackView.subviews.forEach { $0.removeFromSuperview() }
        views.forEach { inputStackView.addArrangedSubview($0) }
        inputStackView.isHidden = views.isEmpty
    }

    func add(view: UIView) {
        inputStackView.addArrangedSubview(view)
        inputStackView.isHidden = false
    }
    
    func add(views: [UIView]) {
        views.forEach { inputStackView.addArrangedSubview($0) }
        inputStackView.isHidden = views.isEmpty
    }

    // MARK: Tap Actions

    @objc private func closeTap() {
        closeTapHandler?()
    }

    @objc private func primaryTap() {
        primaryTapHandler?()
    }

    @objc private func secondaryTap() {
        secondaryTapHandler?()
   }
}
