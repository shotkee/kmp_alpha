//
//  RateOperatorViewController.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 31.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import TinyConstraints
import Legacy

class RateOperatorViewController: ViewController,
								  RateOperatorCompletionHandler {
    struct Input {
        let operatorInfo: Operator
		let newScore: Int?
    }

    struct Output {
        let confirm: (Int, String?) -> Void
        let completion: (Result<(), Error>) -> Void
    }

    private enum Constants {
        static let maxStars = 5
    }

    var input: Input!
    var output: Output!

    private let contentStackView = UIStackView()
	private let descriptionContainer = UIView()
	private lazy var confirmButtonBottomConstraint: Constraint = {
		return confirmButton.bottomToSuperview(offset: -8, usingSafeArea: true)
	}()
	
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let ratingStackView = UIStackView()
    private let rateDescriptionLabel = UILabel()
    private var confirmButton = RoundEdgeButton()
    private var commentNoteView = NoteView()
    private let keyboardBehavior = KeyboardBehavior()
    private var starButtons: [UIButton] = []
    private var comment: String?
    private var selectedRating: Int = 0 {
        didSet {
            guard selectedRating != oldValue else { return }

            updateUI()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        avatarImageView.layer.cornerRadius = avatarImageView.frame.width * 0.5
    }

    private func setupUI() {
        title = NSLocalizedString("chat_rate_screen_title", comment: "")
		
		view.backgroundColor = .Background.backgroundContent
		
		view.addSubview(contentStackView)
		
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = .zero
		contentStackView.alignment = .center
		contentStackView.distribution = .fill
		contentStackView.axis = .vertical
		contentStackView.spacing = 0
		contentStackView.backgroundColor = .clear
		
		contentStackView.leadingToSuperview(offset: 18)
		contentStackView.trailingToSuperview(offset: 18)
		contentStackView.centerXToSuperview()
		contentStackView.centerYToSuperview(offset: -60)
		
		avatarImageView.height(96)
		avatarImageView.widthToHeight(of: avatarImageView)
		avatarImageView.sd_setImage(
			with: input.operatorInfo.getAvatarURL(),
			placeholderImage: .Icons.alfaInCircle.resized(newWidth: 96)?.tintedImage(withColor: .Icons.iconAccent)
		)
		avatarImageView.backgroundColor = .Icons.iconContrast
        avatarImageView.contentMode = .scaleAspectFill
		avatarImageView.layer.masksToBounds = true
		contentStackView.addArrangedSubview(avatarImageView)
		
		contentStackView.addArrangedSubview(spacer(12))
		
        nameLabel.text = input.operatorInfo.getName()
		nameLabel.numberOfLines = 1
		nameLabel <~ Style.Label.primaryHeadline1
		contentStackView.addArrangedSubview(nameLabel)
		
		contentStackView.addArrangedSubview(spacer(24))
		
		ratingStackView.isLayoutMarginsRelativeArrangement = true
		ratingStackView.layoutMargins = .zero
		ratingStackView.alignment = .fill
		ratingStackView.distribution = .fill
		ratingStackView.axis = .horizontal
		ratingStackView.spacing = 12
		ratingStackView.backgroundColor = .clear
		
		(0..<Constants.maxStars).forEach { _ in
			let button = UIButton(type: .custom)
			self.starButtons.append(button)
			button.translatesAutoresizingMaskIntoConstraints = false
			button.height(42)
			button.widthToHeight(of: button)
			button.setImage(
				.Icons.star.resized(newWidth: 42)?.tintedImage(withColor: .Icons.iconSecondary),
				for: .normal
			)
			button.setImage(
				.Icons.star.resized(newWidth: 42)?.tintedImage(withColor: .Icons.iconAccent),
				for: .selected
			)
			button.addTarget(self, action: #selector(starTap(_:)), for: .touchUpInside)
			ratingStackView.addArrangedSubview(button)
		}
		
		contentStackView.addArrangedSubview(ratingStackView)
		
        rateDescriptionLabel <~ Style.Label.primaryText
		rateDescriptionLabel.numberOfLines = 0
		descriptionContainer.addSubview(rateDescriptionLabel)
		rateDescriptionLabel.edgesToSuperview(insets: UIEdgeInsets(top: 9, left: 0, bottom: 0, right: 0))
		descriptionContainer.isHidden = true
		
		contentStackView.addArrangedSubview(descriptionContainer)
		
		contentStackView.addArrangedSubview(spacer(24))
			
		let commentNoteContainerView = UIView()
		commentNoteContainerView.backgroundColor = .Background.fieldBackground
		commentNoteContainerView.layer.cornerRadius = 10
		commentNoteContainerView.layer.masksToBounds = true
		contentStackView.addArrangedSubview(commentNoteContainerView)
		commentNoteContainerView.widthToSuperview()
		
        commentNoteView.textView.font = Style.Font.text
        commentNoteView.textView.textContainer.lineBreakMode = .byTruncatingHead
		commentNoteView.textView.backgroundColor = .clear
		commentNoteView.textView.showsHorizontalScrollIndicator = false
        commentNoteView.setPlaceholderLabelStyle(Style.Label.tertiaryText)
        commentNoteView.placeholderText = NSLocalizedString("chat_rate_screen_leave_comment_text", comment: "")
        commentNoteView.textViewChangedCallback = { [unowned self] textView in
            self.comment = textView.text
        }
		
		commentNoteView.set(minHeight: 90)
		commentNoteView.noteMaxLength = 200
		commentNoteContainerView.addSubview(commentNoteView)
		commentNoteView.edgesToSuperview(insets: insets(12))
		
		confirmButton <~ Style.RoundedButton.primaryButtonSmall
		confirmButton.setTitle(NSLocalizedString("common_confirm", comment: ""), for: .normal)
		confirmButton.isEnabled = false
		confirmButton.addTarget(self, action: #selector(confirmTap), for: .touchUpInside)
		
		view.addSubview(confirmButton)
		confirmButton.leadingToSuperview(offset: 18)
		confirmButton.trailingToSuperview(offset: 18)
		confirmButton.height(48)
		confirmButtonBottomConstraint.isActive = true
		
		if let score = input.newScore {
			selectedRating = score
		}
    }
		
    private func updateUI() {
        for (index, button) in starButtons.enumerated() {
            button.isSelected = index < selectedRating
        }
        confirmButton.isEnabled = selectedRating > 0

        rateDescriptionLabel.text = NSLocalizedString("chat_rate_description", comment: "")
		
		descriptionContainer.isHidden = false
    }

    @objc private func containerTap(_ sender: UITapGestureRecognizer) {
        commentNoteView.textView.resignFirstResponder()
    }

    @objc private func confirmTap(_ sender: UIButton) {
        output.confirm(selectedRating, comment)
    }

    @objc private func starTap(_ sender: UIButton) {
        guard let starIndex = starButtons.firstIndex(of: sender) else { return }

        selectedRating = starIndex + 1
        updateUI()
    }

    // MARK: - RateOperatorCompletionHandler
    func onSuccess() {
        DispatchQueue.main.async {
            self.output.completion(.success(()))
        }
    }

    func onFailure(error: Error) {
        DispatchQueue.main.async {
            self.output.completion(.failure(error))
        }
    }
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		updateTheme()
	}
	
	private func updateTheme() {
		avatarImageView.sd_setImage(
			with: input.operatorInfo.getAvatarURL(),
			placeholderImage: .Icons.alfaInCircle
				.resized(newWidth: 96)?
				.tintedImage(withColor: .Icons.iconAccent)
		)
		
		starButtons.forEach {
			$0.setImage(
				.Icons.star.resized(newWidth: 42)?.tintedImage(withColor: .Icons.iconSecondary),
				for: .normal
			)
			$0.setImage(
				.Icons.star.resized(newWidth: 42)?.tintedImage(withColor: .Icons.iconAccent),
				for: .selected
			)
		}
	}
}
