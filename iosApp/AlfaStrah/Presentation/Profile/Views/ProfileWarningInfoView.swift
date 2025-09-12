//
//  InfoView.swift
//  AlfaStrah
//
//  Created by vit on 14.03.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class ProfileWarningInfoView: UIView, UITextViewDelegate {
    private let infoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionTextView = UITextView()
    
    private var tapHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupUI()
    }
    
    private func setupUI() {
        addSubview(infoImageView)
        addSubview(titleLabel)
        addSubview(descriptionTextView)
        
        infoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel <~ Style.Label.primaryHeadline3
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        let text = NSLocalizedString("edit_profile_info_card_view_description", comment: "")
        let attributedText = (text <~ Style.TextAttributes.normalText).mutable
        let selectedString = NSLocalizedString("edit_profile_info_card_view_description_selection", comment: "")
        let rangeOfLink = NSString(string: attributedText.string).range(of: selectedString)
        attributedText.addAttributes( [ .link: "", .underlineStyle: NSUnderlineStyle.single.rawValue], range: rangeOfLink)
		
		descriptionTextView.linkTextAttributes = [ .foregroundColor: UIColor.Text.textLink ]
		
        descriptionTextView.attributedText = attributedText
		descriptionTextView.backgroundColor = .clear
        descriptionTextView.delegate = self
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.isEditable = false
        descriptionTextView.sizeToFit()
        
		infoImageView.image = .Icons.info.tintedImage(withColor: .Icons.iconAccent).resized(newWidth: 16)
		infoImageView.contentMode = .center
        titleLabel.text = NSLocalizedString("edit_profile_info_card_view_title", comment: "")
        
        NSLayoutConstraint.activate([
            infoImageView.topAnchor.constraint(equalTo: topAnchor),
            infoImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            infoImageView.heightAnchor.constraint(equalToConstant: 24),
            infoImageView.heightAnchor.constraint(equalTo: infoImageView.widthAnchor, multiplier: 1.0),
            titleLabel.leadingAnchor.constraint(equalTo: infoImageView.trailingAnchor, constant: 3),
            titleLabel.centerYAnchor.constraint(equalTo: infoImageView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            descriptionTextView.topAnchor.constraint(greaterThanOrEqualTo: infoImageView.bottomAnchor, constant: 3),
            descriptionTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descriptionTextView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func textView(
        _ textView: UITextView,
        shouldInteractWith url: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        tapHandler?()
        return false
    }
    
    func set(tapHandler: @escaping () -> Void) {
        self.tapHandler = tapHandler
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		updateTheme()
	}
	
	private func updateTheme() {
		let iconImage = infoImageView.image
		
		infoImageView.image = iconImage?.tintedImage(withColor: .Icons.iconAccent)
	}
}
