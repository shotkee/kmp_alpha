//
//  CommonUserAgreementView
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 09.12.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

class CommonUserAgreementView: UIView, UITextViewDelegate {
    private let checkboxButton: CommonCheckboxButton = .init()
    private let agreementTermsTextView: UITextView = .init()

    var userConfirmedAgreement: Bool {
        checkboxButton.isSelected
    }

    struct Output {
        var userAgreementChanged: (Bool) -> Void
    }

    private var output: Output?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    private func setup() {
        backgroundColor = .clear
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .top
        stackView.spacing = 9
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: stackView, in: self))

        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        checkboxButton.setContentHuggingPriority(
            .required,
            for: .horizontal
        )
        checkboxButton.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )
        checkboxButton.addTarget(self, action: #selector(checkButtonTap(_:)), for: .touchUpInside)
        stackView.addArrangedSubview(checkboxButton)

        agreementTermsTextView.translatesAutoresizingMaskIntoConstraints = false
        agreementTermsTextView.textContainerInset = .zero
        NSLayoutConstraint.activate([
            agreementTermsTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 5)
        ])
        agreementTermsTextView.isEditable = false
        agreementTermsTextView.isScrollEnabled = false
        agreementTermsTextView.delegate = self
        stackView.addArrangedSubview(agreementTermsTextView)
        
        agreementTermsTextView.backgroundColor = .clear
        agreementTermsTextView.linkTextAttributes = [ .foregroundColor: UIColor.Text.textLink ]

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: agreementTermsTextView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: agreementTermsTextView.bottomAnchor)
        ])
    }
    
    private var links: [ LinkArea ] = []

    func set(
        text: String,
        userInteractionWithTextEnabled: Bool = true,
        links: [ LinkArea ],
        handler: Output
    ) {
        self.links = links
        let termsString = (text <~ Style.TextAttributes.normalText).mutable
        for link in links {
            let rangeOfLink = NSString(string: termsString.string)
                .range(of: link.text)
            termsString.addAttributes(
                [ .link: link.absoluteString ],
                range: rangeOfLink
            )
        }
        
        agreementTermsTextView.attributedText = termsString
        agreementTermsTextView.sizeToFit()
        output = handler
        
        agreementTermsTextView.isUserInteractionEnabled = userInteractionWithTextEnabled
    }
    
    func resetConfirmation() {
        checkboxButton.isSelected = false
        output?.userAgreementChanged(checkboxButton.isSelected)
    }

    @objc private func checkButtonTap(_ sender: UIButton) {
        checkboxButton.isSelected.toggle()
        output?.userAgreementChanged(checkboxButton.isSelected)
    }

    // MARK: - UITextViewDelegate

    func textView(
        _ textView: UITextView,
        shouldInteractWith url: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        let link = links.first { $0.absoluteString == url.absoluteString }
        link?.tapHandler(link?.link)
        return false
    }
}
