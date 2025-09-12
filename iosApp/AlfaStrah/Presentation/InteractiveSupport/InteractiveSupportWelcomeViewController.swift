//
//  InteractiveSupportWelcomeViewController.swift
//  AlfaStrah
//
//  Created by vit on 21.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Legacy
import TinyConstraints

class InteractiveSupportWelcomeViewController: ViewController, ActionSheetContentViewController {
    var animationWhileTransition: (() -> Void)?
    
    struct Input {
        let onboardingStartScreenData: InteractiveSupportStartScreenData
        let flowStartScreenPresentationType: InteractiveSupportFlow.FlowStartScreenPresentationType
        let appear: () -> Void
    }

    struct Output {
        let action: () -> Void
        let close: () -> Void
    }

    var input: Input!
    var output: Output!
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
		button.setImage(.Icons.cross, for: .normal)
		button.tintColor = .Icons.iconAccentThemed
        button.addTarget(self, action: #selector(closeTap), for: .touchUpInside)

        return button
    }()
    
    private lazy var actionButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 9
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 32, left: 18, bottom: 18, right: 18)
        
        return stackView
    }()
        
    private let containerView = UIView()
    private let backgroundImageView = UIImageView()
    private let contentStackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let startButton = RoundEdgeButton()

    override func viewDidLoad() {
        super.viewDidLoad()
                
		view.backgroundColor = .Background.backgroundContent
        
        setupUI()
        
        switch input.flowStartScreenPresentationType {
            case .fromSheet:
				view.backgroundColor = .Background.backgroundModal
                setupForSheetPresentation()
            case .fullScreen:
                setupToFullScreenPresentation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        input.appear()
    }
    
    private func setupUI() {
        view.addSubview(actionButtonsStackView)
        actionButtonsStackView.bottomToSuperview(usingSafeArea: true)
        actionButtonsStackView.leadingToSuperview()
        actionButtonsStackView.trailingToSuperview()
        
        startButton.setTitle(input.onboardingStartScreenData.buttonTitle, for: .normal)
        startButton.addTarget(self, action: #selector(startTap), for: .touchUpInside)
        startButton <~ Style.RoundedButton.oldPrimaryButtonSmall
        startButton.height(48)
        
        actionButtonsStackView.addArrangedSubview(startButton)
    }
    
    private func setupForSheetPresentation() {
        view.addSubview(closeButton)
        closeButton.topToSuperview()
        closeButton.trailingToSuperview(offset: 18)
        
        view.addSubview(containerView)
        containerView.topToBottom(of: closeButton, offset: Constants.is7IphoneOrLess ? 0 : 9)
        containerView.bottomToTop(of: actionButtonsStackView)
        containerView.leadingToSuperview()
        containerView.trailingToSuperview()
        
        containerView.addSubview(backgroundImageView)
		backgroundImageView.contentMode = .scaleAspectFit
        backgroundImageView.topToSuperview()
		backgroundImageView.trailingToSuperview(offset: Constants.trailingOnboardingImageConstant)
		backgroundImageView.leadingToSuperview(offset: Constants.leadingOnboardingImageConstant)
		let scale = Constants.is7IphoneOrLess ? 0.9 : 1
		let image = UIImage.Illustrations.backgroundOnboarding
		backgroundImageView.width(scale * image.size.width ?? 0)
		backgroundImageView.height(scale * image.size.height ?? 0)
		backgroundImageView.image = image
        
        containerView.addSubview(contentStackView)
        contentStackView.topToBottom(of: backgroundImageView)
        contentStackView.leadingToSuperview()
        contentStackView.trailingToSuperview()
        contentStackView.bottomToSuperview()
        
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.spacing = 15
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(
            top: Constants.is7IphoneOrLess ? 12 : 18,
            left: 18,
            bottom: 18,
            right: 18
        )
        
        contentStackView.addArrangedSubview(titleLabel)
        titleLabel.numberOfLines = 0
        titleLabel <~ Style.Label.primaryTitle1
        titleLabel.text = input.onboardingStartScreenData.title
        
        contentStackView.addArrangedSubview(descriptionLabel)
        descriptionLabel.numberOfLines = 0
        descriptionLabel <~ Style.Label.primaryText
        descriptionLabel.text = input.onboardingStartScreenData.text
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
    }
    
    private func setupToFullScreenPresentation() {
        view.addSubview(closeButton)
        closeButton.topToSuperview(offset: 10, usingSafeArea: true)
        closeButton.leadingToSuperview(offset: 18)
        
        view.addSubview(containerView)
        containerView.topToBottom(of: closeButton, offset: 9)
        containerView.bottomToTop(of: actionButtonsStackView)
        containerView.leadingToSuperview()
        containerView.trailingToSuperview()
        
        let backgroundImageContainerView = UIView()
        containerView.addSubview(backgroundImageContainerView)
        backgroundImageContainerView.edges(to: containerView, excluding: .bottom)
        
        backgroundImageContainerView.addSubview(backgroundImageView)
		backgroundImageView.contentMode = .scaleAspectFit
		backgroundImageView.centerYToSuperview()
		backgroundImageView.trailingToSuperview(offset: Constants.trailingOnboardingImageConstant)
		backgroundImageView.leadingToSuperview(offset: Constants.leadingOnboardingImageConstant)
		backgroundImageView.image = .Illustrations.backgroundOnboarding

        containerView.addSubview(contentStackView)
        contentStackView.topToBottom(of: backgroundImageContainerView)
        contentStackView.leadingToSuperview()
        contentStackView.trailingToSuperview()
        contentStackView.bottomToSuperview()
        
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.spacing = 15
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(
            top: 40,
            left: 18,
            bottom: 18,
            right: 18
        )
        
        contentStackView.addArrangedSubview(titleLabel)
        titleLabel.numberOfLines = 0
        titleLabel <~ Style.Label.primaryTitle1
        titleLabel.text = input.onboardingStartScreenData.title
        
        contentStackView.addArrangedSubview(descriptionLabel)
        descriptionLabel.numberOfLines = 0
        descriptionLabel <~ Style.Label.primaryText
        descriptionLabel.text = input.onboardingStartScreenData.text
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
    }
    
    @objc private func closeTap() {
        output.close()
    }
    
    @objc private func startTap() {
        output.action()
    }
    
    struct Constants {
        static let is7IphoneOrLess: Bool = UIScreen.main.bounds.height <= 667.0
		static let trailingOnboardingImageConstant: CGFloat = 25
		static let leadingOnboardingImageConstant: CGFloat = 53
    }
}
