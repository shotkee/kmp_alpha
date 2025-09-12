//
//  AccountHeaderView.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/4/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import TinyConstraints

class AccountHeaderView: UIView {
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var editButton: UIButton!
	private var demoButton = RoundEdgeButton()
    private var onTap: (() -> Void)?
    private var onEditTap: (() -> Void)?
	private var onDemoTap: (() -> Void)?
    private var account: Account?

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    func configure(
        _ account: Account?,
        onTap: @escaping () -> Void,
        onEditTap: @escaping () -> Void,
		onDemoTap: @escaping () -> Void
    ) {
        self.onTap = onTap
        self.onEditTap = onEditTap
		self.onDemoTap = onDemoTap
        
        guard account != self.account
        else { return }

        self.account = account

        nameLabel.attributedText = makeAttributedNameString(account?.fullName)
    }
	
	private func setupDemoButton()
	{
		let demoButton = RoundEdgeButton()
		demoButton <~ Style.RoundedButton.primaryWhiteButtonLarge
		demoButton.setTitle(
			NSLocalizedString("demo_title", comment: ""),
			for: .normal
		)
		demoButton.setImage(
			.Icons.hint
				.resized(newWidth: 24)?
				.tintedImage(withColor: .Icons.iconBlack),
			for: .normal
		)
		demoButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
		demoButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
		demoButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
		demoButton.contentEdgeInsets = UIEdgeInsets(
			top: 3.5,
			left: 0,
			bottom: 3.5,
			right: 8
		)
		demoButton.addTarget(self, action: #selector(demoButtonTap), for: .touchUpInside)
		demoButton.height(33)
		demoButton.width(75)
		self.demoButton = demoButton
		
		demoButton.isHidden = !isDemoMode
		editButton.isHidden = isDemoMode
	}
	
	@objc private func demoButtonTap()
	{
		onDemoTap?()
	}

    private func setupUI() {
        backgroundColor = .clear
        nameLabel <~ Style.Label.primaryHeadline1
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
		setupDemoButton()
		self.addSubview(demoButton)
		demoButton.edgesToSuperview(
			excluding: .left,
			insets: .init(
				top: 8.5,
				left: 0,
				bottom: 8.5,
				right: 18
			)
		)
		demoButton.leftToRight(of: nameLabel, offset: 10)
    }
	
	// MARK: - Dark Theme Support
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		demoButton.removeFromSuperview()
		setupDemoButton()
		self.addSubview(demoButton)
		demoButton.edgesToSuperview(
			excluding: .left,
			insets: .init(
				top: 8.5,
				left: 0,
				bottom: 8.5,
				right: 18
			)
		)
		demoButton.leftToRight(of: nameLabel, offset: 10)
	}

    private func makeAttributedNameString(_ text: String?) -> NSAttributedString? {
        guard let text = text else { return nil }

        var attributes = Style.TextAttributes.datesLabelText
        attributes[.paragraphStyle] = Style.Paragraph.withLineHeight(21)
        return NSAttributedString(string: text, attributes: attributes)
    }

    @IBAction private func editTap(_ sender: UIButton) {
        onEditTap?()
    }
    
    @IBAction func userNameTap(_ sender: UITapGestureRecognizer) {
        onTap?()
    }
}
