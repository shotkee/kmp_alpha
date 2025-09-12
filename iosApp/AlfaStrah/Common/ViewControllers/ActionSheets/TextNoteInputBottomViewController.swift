//
//  TextInputBottomViewController
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 28.10.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

class TextNoteInputBottomViewController: BaseBottomSheetViewController {
    enum Scenario {
        case interactiveSupport
        case accidentEvent
        case editBank
        case osagoParticipantInfo
    }
    
    struct Input {
        let title: String
        let description: String?
        let textInputTitle: String?
        let textInputPlaceholder: String
        let initialText: String?
        let showSeparator: Bool
        let validationRules: [ValidationRule]
        let keyboardType: UIKeyboardType
        let textInputMinHeight: CGFloat?
        let charsLimited: CharsInputLimits
        let tintColor: UIColor
        let isVisibleCharsCount: Bool
        let scenario: Scenario
        
        init(
            title: String,
            description: String?,
            textInputTitle: String?,
            textInputPlaceholder: String,
            initialText: String?,
            showSeparator: Bool,
            validationRules: [ValidationRule],
            keyboardType: UIKeyboardType,
            textInputMinHeight: CGFloat?,
            charsLimited: CharsInputLimits,
            tintColor: UIColor = .Icons.iconAccentThemed,
            isVisibleCharsCount: Bool = true,
            scenario: Scenario
        ) {
            self.title = title
            self.description = description
            self.textInputTitle = textInputTitle
            self.textInputPlaceholder = textInputPlaceholder
            self.initialText = initialText
            self.showSeparator = showSeparator
            self.validationRules = validationRules
            self.keyboardType = keyboardType
            self.textInputMinHeight = textInputMinHeight
            self.charsLimited = charsLimited
            self.tintColor = tintColor
            self.isVisibleCharsCount = isVisibleCharsCount
            self.scenario = scenario
        }
    }

    struct Output {
        let close: () -> Void
        let text: (String) -> Void
    }

    var output: Output!
    var input: Input!

    private lazy var textInputView: CommonNoteView = .init(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        closeTapHandler = output.close
        primaryTapHandler = { [unowned self] in
            guard self.textInputView.isValid else { return }

            self.output.text(textInputView.currentText ?? "")
        }
    }

    override func setupUI() {
        super.setupUI()

        set(title: input.title)
        set(infoText: input.description ?? "")
        set(views: [ textInputView ])

        if let height = input.textInputMinHeight {
            textInputView.translatesAutoresizingMaskIntoConstraints = false
            textInputView.heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true
        }

        textInputView.set(
            title: input.textInputTitle,
            note: input.initialText ?? "",
            placeholder: input.textInputPlaceholder,
            margins: UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0),
            showSeparator: input.showSeparator,
            keyboardType: input.keyboardType,
            validationRules: input.validationRules,
            maxCharacterCount: input.charsLimited
        )

        textInputView.textViewDidBecomeActiveCallback = { [weak self] _ in
            guard let self = self
            else { return }
            
            self.updateStateUIСomponents()
        }

        textInputView.textViewChangedCallback = { [weak self] _ in
            guard let self = self
            else { return }
            
            self.textInputView.validate()
            self.updateStateUIСomponents()
        }

        animationWhileTransition = { [weak self] in
            self?.textInputView.becomeActive()
        }
    }
    
    func updateStateUIСomponents() {
        switch self.input.scenario {
            case .interactiveSupport:
                self.set(
                    charsCounter: .enteredOutOfMax(
                        numEnteredChars: self.textInputView.currentText?.count ?? 0,
                        maxChars: self.input.charsLimited.value
                    )
                )
            case .accidentEvent,
                 .editBank,
                 .osagoParticipantInfo:
                self.set(
                    charsLeftCounter: self.textInputView.charsLeftCounter,
                    isVisible: self.input.isVisibleCharsCount
                )
        }
        self.set(doneButtonEnabled: self.textInputView.isValid)
    }
}
